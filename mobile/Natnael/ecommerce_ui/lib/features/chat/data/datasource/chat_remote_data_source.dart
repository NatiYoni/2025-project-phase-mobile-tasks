import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../core/error/exceptions.dart';
import '../../../../core/session/current_user.dart';
import '../model/chat_model.dart';
import '../model/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<void> initSocket(String token);
  Future<List<ChatModel>> getChats();
  Future<ChatModel> getChatById(String chatId);
  Future<List<MessageModel>> getMessages(String chatId);
  Future<ChatModel> initiateChat(String userId);
  Future<void> deleteChat(String chatId);
  Stream<MessageModel> getMessagesStream();
  Future<void> sendMessage({required String chatId, required String content});
  void joinChat(String chatId);
  void disposeSocket();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  // Unified base URL (user confirmed this is correct for both REST & socket)
  static const String API_BASE_URL = 'https://g5-flutter-learning-path-be-tvum.onrender.com';
  static const String SOCKET_BASE_URL = API_BASE_URL;
  static const bool _verboseSocket = true; // flip to false to quiet logs

  final http.Client client;
  late IO.Socket socket;
  final StreamController<MessageModel> _messageStreamController = StreamController<MessageModel>.broadcast();
  String? _token;
  // Cache of chatId -> participant user ids for quick membership validation
  final Map<String, Set<String>> _chatParticipants = {};

  ChatRemoteDataSourceImpl({required this.client});

  @override
  Future<void> initSocket(String token) async {
    _token = token;
    try {
      socket = IO.io(SOCKET_BASE_URL, <String, dynamic>{
        'transports': <String>['websocket'],
        'autoConnect': true,
        'forceNew': true,
        // Socket.IO v4 preferred auth object (backend middleware often reads handshake.auth.token)
        'auth': {
          'token': token,
        },
        // Keep a single clear header copy (if backend inspects headers instead of auth)
        'extraHeaders': {
          'Authorization': 'Bearer $token',
        },
        // Minimal query (avoid noise)
        'query': {
          'token': token,
        },
      });

      socket.connect();
      socket.onConnect((_) {
        final tLen = token.length;
        print('[Socket] connected id=${socket.id} tokenLen=$tLen transport=${socket.io.engine?.transport?.name}');
        if (_verboseSocket) {
          try {
            final decoded = _decodeJwtPayload(token);
            print('[Socket][jwt] payloadKeys=${decoded.keys.toList()} idField=${decoded['_id'] ?? decoded['id'] ?? decoded['sub']}');
          } catch (e) {
            print('[Socket][jwt] decode failed: $e');
          }
        }
      });
      socket.onDisconnect((_) => print('[Socket] disconnected'));
      socket.onConnectError((err) => print('[Socket] connect error: $err'));
      socket.onError((err) => print('[Socket] error: $err'));
      socket.onReconnect((_) => print('[Socket] reconnected'));
      socket.onReconnectAttempt((attempt) => print('[Socket] reconnect attempt #$attempt'));
      try {
        socket.onAny((event, data) {
          if (!_verboseSocket) return;
          String preview;
            try {
              preview = data is String ? data : jsonEncode(data);
              if (preview.length > 120) preview = preview.substring(0,120)+'…';
            } catch (_) { preview = data.toString(); }
          print('[Socket][onAny] event=$event data=$preview');
        });
      } catch (_) {}

      socket.on('message:received', (raw) async {
        dynamic data = raw;
        try {
          if (data is String) data = jsonDecode(data);
          if (data is Map) {
            if (data['chat'] is String) {
              try {
                final chatModel = await getChatById(data['chat']);
                data['chat'] = chatModel.toJson();
              } catch (e) {
                if (kDebugMode) print('[Socket] failed to fetch chat by id ${data['chat']}: $e');
              }
            }
            if (kDebugMode) {
              try {
                final chatId = (data['chat'] is Map) ? data['chat']['_id'] : data['chatId'];
                print('[Socket] message:received chatId=$chatId content=${data['content']}');
              } catch (_) {}
            }
            _messageStreamController.add(MessageModel.fromJson(Map<String, dynamic>.from(data)));
          }
        } catch (e) {
          if (kDebugMode) print('[Socket] message parse error: $e');
        }
      });

      socket.on('message:delivered', (raw) {
        dynamic data = raw;
        try {
          if (data is String) data = jsonDecode(data);
          if (data is Map) {
            _messageStreamController.add(MessageModel.fromJson(Map<String, dynamic>.from(data)));
          }
        } catch (e) {
          if (kDebugMode) print('[Socket] delivered parse error: $e');
        }
      });
    } catch (e) {
      throw SocketException(e.toString());
    }
  }

  @override
  void disposeSocket() {
    try {
      if (!_messageStreamController.isClosed) {
        _messageStreamController.close();
      }
    } catch (_) {}
    try { socket.dispose(); } catch (_) {}
    _token = null;
  }

  Future<T> _performRequest<T>(
    Future<http.Response> Function(Map<String, String> headers) request, {
    required int successStatusCode,
    required T Function(dynamic data) fromJson,
  }) async {
    if (_token == null) throw const SocketException('Token not available.');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
    try {
      final response = await request(headers);
      if (response.statusCode == successStatusCode) {
        if (response.body.isEmpty) return fromJson(null);
        final jsonResponse = jsonDecode(response.body);
        if (kDebugMode) {
          final preview = response.body.length > 300 ? response.body.substring(0, 300) + '...' : response.body;
          print('[ChatRemoteDataSource][_performRequest] status=$successStatusCode bodyPreview=$preview');
        }
        return fromJson(jsonResponse['data']);
      }
      throw ServerException();
    } on SocketException {
      rethrow;
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteChat(String chatId) => _performRequest(
        (headers) => client.delete(Uri.parse('$API_BASE_URL/api/v3/chats/$chatId'), headers: headers),
        successStatusCode: 200,
        fromJson: (_) => {},
      );

  @override
  Future<ChatModel> getChatById(String chatId) => _performRequest(
        (headers) => client.get(Uri.parse('$API_BASE_URL/api/v3/chats/$chatId'), headers: headers),
        successStatusCode: 200,
        fromJson: (data) => ChatModel.fromJson(data),
      );

  @override
  Future<List<ChatModel>> getChats() => _performRequest(
        (headers) => client.get(Uri.parse('$API_BASE_URL/api/v3/chats'), headers: headers),
        successStatusCode: 200,
        fromJson: (data) {
          final list = (data as List).map((c) => ChatModel.fromJson(c)).toList();
          // Diagnostic log: show all chatIds and participants
          if (kDebugMode) {
            for (final chat in list) {
              print('[ChatRemoteDataSource][DIAG] chatId=${chat.chatId} user1=${chat.user1.id} user2=${chat.user2.id}');
            }
          }
          // Filter to only chats the current user participates in
          if (CurrentUser.id != null) {
            final filtered = list.where((chat) {
              final u1 = chat.user1.id;
              final u2 = chat.user2.id;
              final include = (u1 == CurrentUser.id) || (u2 == CurrentUser.id);
              if (include) {
                _chatParticipants[chat.chatId] = {if (u1 != null) u1, if (u2 != null) u2};
              }
              return include;
            }).toList();
            if (kDebugMode && filtered.length != list.length) {
              print('[ChatRemoteDataSource] Filtered chats: kept=${filtered.length} dropped=${list.length - filtered.length} (membership)');
            }
            return filtered;
          } else {
            // Populate cache anyway
            for (final chat in list) {
              final u1 = chat.user1.id; final u2 = chat.user2.id;
              _chatParticipants[chat.chatId] = {if (u1 != null) u1, if (u2 != null) u2};
            }
            return list;
          }
        },
      );

  @override
  Future<List<MessageModel>> getMessages(String chatId) {
    if (kDebugMode) print('[ChatRemoteDataSource] Fetching messages for chatId=$chatId');
    return _performRequest(
  (headers) => client.get(Uri.parse('$API_BASE_URL/api/v3/chats/$chatId/messages'), headers: headers),
      successStatusCode: 200,
      fromJson: (data) {
        dynamic rawList;
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['messages'] is List) {
          rawList = data['messages'];
        } else if (data is Map && data['data'] is List) {
          rawList = data['data'];
        } else if (data is Map && data['messages'] is Map && data['messages']['docs'] is List) {
          rawList = data['messages']['docs'];
        } else if (data is Map && data['chat'] is Map && data['chat']['messages'] is List) {
          rawList = data['chat']['messages'];
        } else if (data is Map && data['chat'] is Map && data['chat']['messages'] is Map && data['chat']['messages']['docs'] is List) {
          rawList = data['chat']['messages']['docs'];
        } else {
          rawList = <dynamic>[];
        }
        final list = (rawList as List)
            .whereType<dynamic>()
            .map((m) => MessageModel.fromJson((m as Map).cast<String, dynamic>()))
            .toList();
        if (kDebugMode) print('[ChatRemoteDataSource] Parsed messages count=${list.length} for chatId=$chatId');
        return list;
      },
    );
  }

  @override
  Stream<MessageModel> getMessagesStream() => _messageStreamController.stream;

  @override
  Future<ChatModel> initiateChat(String userId) => _performRequest(
        (headers) => client.post(
          Uri.parse('$API_BASE_URL/api/v3/chats'),
          headers: headers,
          body: jsonEncode({'userId': userId}),
        ),
        successStatusCode: 201,
        fromJson: (data) => ChatModel.fromJson(data),
      );

  @override
  Future<void> sendMessage({required String chatId, required String content}) async {
    if (CurrentUser.id == null) {
      print('[Socket][ERROR] Cannot send message, CurrentUser.id is null.');
      throw ServerException();
    }
    if (content.trim().isEmpty) {
      print('[Socket][WARN] Ignoring blank message');
      throw ServerException();
    }
    if (!(socket.connected)) {
      print('[Socket][WARN] send attempted while disconnected. connected=${socket.connected}');
      throw ServerException();
    }
    // Membership and chatId validation
    Set<String>? participants = _chatParticipants[chatId];
    if (participants == null) {
      // Try to fetch & update cache once
      try {
        final chat = await getChatById(chatId);
        final u1 = chat.user1.id; final u2 = chat.user2.id;
        _chatParticipants[chatId] = {if (u1 != null) u1, if (u2 != null) u2};
        participants = _chatParticipants[chatId];
      } catch (_) {
        print('Chat not found in backend. Please select a valid chat.');
        throw ServerException();
      }
    }
    if (participants == null || !participants.contains(CurrentUser.id)) {
      print('You are not a participant in this chat or chatId is invalid.');
      throw ServerException();
    }
    // Participant diagnostics
    final chatParticipantSet = _chatParticipants[chatId];
    print('[SEND][DIAG] chatId=$chatId currentUser=${CurrentUser.id} participants=$chatParticipantSet');
    final payload = {
      'chatId': chatId,
      'content': content,
      'type': 'text',
    };
    print('[SEND][DIAG] payload=${payload.toString()}');
    final completer = Completer<void>();
    bool completed = false;
    Timer? timeout;

    void safeComplete([Object? error]) {
      if (completed) return; completed = true; timeout?.cancel();
      if (error != null) {
        if (!completer.isCompleted) completer.completeError(error);
      } else {
        if (!completer.isCompleted) completer.complete();
      }
    }

    // Single-use listeners
    late void Function(dynamic) exceptionListener;
    exceptionListener = (dynamic data) {
      try { socket.off('exception', exceptionListener); } catch (_) {}
      if (kDebugMode) print('[Socket][SEND] exception -> $data');
      safeComplete(ServerException());
    };
    socket.on('exception', exceptionListener);

    // Try three payload variants, one after another, stopping after first success
    final variants = [
      payload,
      {'chat': chatId, 'content': content, 'type': 'text'},
      {'chatId': chatId, 'content': content},
    ];
    bool sent = false;
    for (final v in variants) {
      final completer = Completer<void>();
      bool completed = false;
      Timer? timeout;
      late void Function(dynamic) exceptionListener;
      exceptionListener = (dynamic data) {
        try { socket.off('exception', exceptionListener); } catch (_) {}
        print('[Socket][SEND] exception -> $data');
        if (!completed) { completed = true; timeout?.cancel(); completer.completeError(ServerException()); }
      };
      socket.on('exception', exceptionListener);
      try {
        socket.emitWithAck('message:send', v, ack: (data) {
          print('[Socket] ACK message:send data=$data');
          if (!completed) { completed = true; timeout?.cancel(); completer.complete(); }
        });
      } catch (e) {
        print('[Socket][ERROR] emitWithAck failed: $e');
        try { socket.emit('message:send', v); } catch (e2) { print('[Socket][ERROR] emit fallback failed: $e2'); }
      }
      timeout = Timer(const Duration(seconds: 6), () {
        print('[Socket][WARN] send timeout chatId=$chatId');
        if (!completed) { completed = true; completer.completeError(ServerException()); }
      });
      try {
        await completer.future;
        sent = true;
        try { socket.off('exception', exceptionListener); } catch (_) {}
        break;
      } catch (_) {
        try { socket.off('exception', exceptionListener); } catch (_) {}
        // Continue to next variant
      }
    }
    if (!sent) {
      throw ServerException();
    }
  }

  @override
  void joinChat(String chatId) {
    try {
      // Use a single canonical join event; multiple variants can confuse backend metrics.
      socket.emit('join', {'chatId': chatId});
      if (kDebugMode) print('[Socket] join sent chatId=$chatId');
    } catch (e) {
      if (kDebugMode) print('[Socket][ERROR] join failed: $e');
    }
  }

  // Decode JWT payload (debug only)
  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) throw const FormatException('Invalid JWT');
    String normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) { normalized += '='; }
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

}