import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';



// Core
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

// Data source (for socket lifecycle)
import '../../../authentication/domain/entity/authentication.dart';
import '../../data/datasource/chat_remote_data_source.dart';

// Domain entities
import '../../domain/entity/chat.dart';
import '../../domain/entity/message.dart';

// Use cases
import '../../domain/usecase/delete_chat_usecase.dart' as delete_chat_uc;
import '../../domain/usecase/get_chats_usecase.dart';
import '../../domain/usecase/get_message_stream_usecase.dart';
import '../../domain/usecase/get_messages_usecase.dart' as get_messages_uc;
import '../../domain/usecase/initiate_chat_usecase.dart' as initiate_chat_uc;
import '../../domain/usecase/send_message_usecase.dart' as send_message_uc;
import '../../../authentication/domain/usecase/get_all_users_usecase.dart' as get_all_users_uc;
import '../../../../core/session/current_user.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRemoteDataSource remoteDataSource; // for init / dispose socket & direct send
  final GetChatsUsecase getChatsUsecase;
  final get_messages_uc.GetMessagesUsecase getMessagesUsecase;
  final GetMessagesStreamUsecase getMessagesStreamUsecase;
  final initiate_chat_uc.InitiateChatUsecase initiateChatUsecase;
  final delete_chat_uc.DeleteChatUsecase deleteChatUsecase;
  final send_message_uc.SendMessageUsecase sendMessageUsecase;
  final get_all_users_uc.GetAllUsersUsecase? getAllUsersUsecase; // optional so existing registrations won't break

  StreamSubscription? _messageSub;
  // Buffer messages that arrive before history load to prevent loss
  final Map<String, List<Message>> _earlyMessages = {};
  bool _socketInitialized = false;
  bool _isLoadingChats = false;
  static const int _maxBufferedPerChat = 30;
  List<Chat> _cachedChats = [];
  List<Authentication>? _pendingUsers; // store users fetched before chats load
  final Set<String> _pendingTempMessageIds = {}; // track optimistic message ids

  ChatBloc({
    required this.remoteDataSource,
    required this.getChatsUsecase,
    required this.getMessagesUsecase,
    required this.getMessagesStreamUsecase,
    required this.initiateChatUsecase,
    required this.deleteChatUsecase,
    required this.sendMessageUsecase,
    this.getAllUsersUsecase,
  }) : super(ChatInitial()) {
    on<InitializeSocketEvent>(_onInitSocket);
    on<GetChatsEvent>(_onGetChats);
  on<RefreshChatsEvent>(_onRefreshChats);
    on<GetMessagesEvent>(_onGetMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<InitiateChatEvent>(_onInitiateChat);
    on<DeleteChatEvent>(_onDeleteChat);
    on<_MessageReceivedEvent>(_onMessageReceived);
  on<LoadUsersEvent>(_onLoadUsers);
  on<ShutdownChatEvent>(_onShutdown);
  on<MarkChatReadEvent>(_onMarkChatRead);
  }

  Future<void> _onInitSocket(InitializeSocketEvent event, Emitter<ChatState> emit) async {
    if (_socketInitialized) return; // guard against duplicate inits
    emit(SocketInitializing());
    try {
      await remoteDataSource.initSocket(event.token);
      _socketInitialized = true;
      // Start listening to message stream (domain stream returns Either)
      _messageSub?.cancel();
      _messageSub = getMessagesStreamUsecase()
          .listen((either) => either.fold(
                (fail) => addError(fail, StackTrace.current),
                (msg) => add(_MessageReceivedEvent(msg)),
              ));
      emit(SocketReady());
    } catch (e) {
      emit(SocketError(e.toString()));
    }
  }

  Future<void> _onGetChats(GetChatsEvent event, Emitter<ChatState> emit) async {
    if (_isLoadingChats) return;
    _isLoadingChats = true;
    List<Authentication> existingUsers = [];
    if (state is ChatsLoaded) existingUsers = (state as ChatsLoaded).users;
    emit(ChatsLoading());
    try {
      final result = await getChatsUsecase(NoParams());
      result.fold(
        (f) => emit(ChatOperationFailure(_mapFailure(f))),
        (chats) {
          final enriched = List<Chat>.from(chats);
          _earlyMessages.forEach((chatId, msgs) {
            if (!enriched.any((c) => c.chatId == chatId) && msgs.isNotEmpty) {
              final first = msgs.last;
              enriched.add(first.chat.copyWith(
                lastMessageContent: first.content,
                lastMessageAt: first.createdAt ?? DateTime.now(),
                unreadCount: msgs.length,
              ));
            }
          });
          enriched.sort((a, b) {
            final atA = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final atB = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return atB.compareTo(atA);
          });
          if (enriched.isEmpty) {
            // ignore: avoid_print
            print('[ChatBloc] Loaded 0 chats');
          } else {
            // ignore: avoid_print
            print('[ChatBloc] Loaded chats count=${enriched.length}');
          }
          _cachedChats = enriched;
          final usersToEmit = _pendingUsers ?? existingUsers;
          emit(ChatsLoaded(List<Chat>.from(_cachedChats), users: usersToEmit));
          _pendingUsers = null;
        },
      );
    } finally {
      _isLoadingChats = false;
    }
  }

  Future<void> _onRefreshChats(RefreshChatsEvent event, Emitter<ChatState> emit) async {
    if (_isLoadingChats) return;
    _isLoadingChats = true;
    final previous = state;
    try {
      final result = await getChatsUsecase(NoParams());
      result.fold(
        (f) => emit(ChatOperationFailure(_mapFailure(f))),
        (chats) {
          List<Authentication> existingUsers = [];
          if (previous is ChatsLoaded) existingUsers = previous.users;
          final enriched = List<Chat>.from(chats);
            _earlyMessages.forEach((chatId, msgs) {
              if (!enriched.any((c) => c.chatId == chatId) && msgs.isNotEmpty) {
                final first = msgs.last;
                enriched.add(first.chat.copyWith(
                  lastMessageContent: first.content,
                  lastMessageAt: first.createdAt ?? DateTime.now(),
                  unreadCount: msgs.length,
                ));
              }
            });
          enriched.sort((a, b) {
            final atA = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final atB = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return atB.compareTo(atA);
          });
          _cachedChats = enriched;
          final usersToEmit = _pendingUsers ?? existingUsers;
          emit(ChatsLoaded(List<Chat>.from(_cachedChats), users: usersToEmit));
          _pendingUsers = null;
        },
      );
      if (state is ChatOperationFailure && previous is ChatsLoaded) {
        emit(previous); // fallback
      }
    } finally {
      _isLoadingChats = false;
    }
  }

  Future<void> _onLoadUsers(LoadUsersEvent event, Emitter<ChatState> emit) async {
    if (getAllUsersUsecase == null) return;
    final current = state;
    final res = await getAllUsersUsecase!(get_all_users_uc.Params(event.token));
    res.fold(
      (f) {
        if (current is! ChatsLoaded) {
          emit(ChatOperationFailure(_mapFailure(f)));
        }
      },
      (usersRaw) {
        final deduped = { for (final u in usersRaw) u.id: u };
        final filtered = deduped.values.where((u) => u.id != CurrentUser.id).toList();
        if (current is ChatsLoaded) {
          emit(current.copyWith(users: filtered));
        } else {
          _pendingUsers = filtered; // apply when chats arrive
        }
      },
    );
  }

  Future<void> _onGetMessages(GetMessagesEvent event, Emitter<ChatState> emit) async {
  // Ensure socket room joined before requesting history
  try { remoteDataSource.joinChat(event.chatId); } catch (_) {}
    emit(MessagesLoading(event.chatId));
    final result = await getMessagesUsecase(get_messages_uc.Params(event.chatId));
    result.fold(
      (f) => emit(ChatOperationFailure(_mapFailure(f))),
      (messages) {
        final buffered = _earlyMessages.remove(event.chatId) ?? [];
        final merged = List<Message>.from(messages);
        for (final m in buffered) {
          if (!merged.any((e) => e.messageId == m.messageId)) {
            merged.add(m);
          }
        }
        // Reset unread in cache
        final idx = _cachedChats.indexWhere((c) => c.chatId == event.chatId);
        if (idx != -1) {
          final old = _cachedChats[idx];
          if (old.unreadCount != 0) {
            _cachedChats[idx] = old.copyWith(unreadCount: 0);
            if (state is ChatsLoaded) {
              emit(ChatsLoaded(List<Chat>.from(_cachedChats), users: (state as ChatsLoaded).users));
            }
          }
        }
  // Explicitly mark chat read (internal consistency)
  add(MarkChatReadEvent(event.chatId));
        emit(MessagesLoaded(chatId: event.chatId, messages: merged));
      },
    );
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    // Optimistic append if currently viewing this chat
    final currentState = state;
    if (currentState is MessagesLoaded && currentState.chatId == event.chatId) {
      // Build optimistic message
      final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';
      final chat = _cachedChats.firstWhere((c) => c.chatId == event.chatId, orElse: () => currentState.messages.isNotEmpty ? currentState.messages.first.chat : Chat(
        chatId: event.chatId,
        user1: currentState.messages.isNotEmpty ? currentState.messages.first.chat.user1 : Authentication(email: '', password: ''),
        user2: currentState.messages.isNotEmpty ? currentState.messages.first.chat.user2 : Authentication(email: '', password: ''),
      ));
      final optimistic = Message(
        messageId: tempId,
        sender: Authentication(id: CurrentUser.id, name: CurrentUser.name, email: CurrentUser.email ?? '', password: ''),
        chat: chat,
        content: event.content,
        type: 'text',
        createdAt: DateTime.now(),
      );
      _pendingTempMessageIds.add(tempId);
      final updated = List<Message>.from(currentState.messages)..add(optimistic);
      emit(currentState.copyWith(messages: updated));
    }

    // Update chats list optimistically
    final idx = _cachedChats.indexWhere((c) => c.chatId == event.chatId);
    if (idx != -1) {
      final old = _cachedChats[idx];
      _cachedChats[idx] = old.copyWith(
        lastMessageContent: event.content,
        lastMessageAt: DateTime.now(),
      );
      final moved = _cachedChats.removeAt(idx);
      _cachedChats.insert(0, moved);
      if (state is ChatsLoaded) {
        final chatsLoaded = state as ChatsLoaded;
        emit(ChatsLoaded(List<Chat>.from(_cachedChats), users: chatsLoaded.users));
      }
    }

    // Fire actual send
    final res = await sendMessageUsecase(send_message_uc.Params(chatId: event.chatId, content: event.content));
    res.fold(
      (f) {
        // On failure, if currently viewing the chat, remove the last optimistic temp message matching content.
        final current = state;
        if (current is MessagesLoaded && current.chatId == event.chatId) {
          final updated = List<Message>.from(current.messages);
          final idxTemp = updated.lastIndexWhere((m) => m.messageId.startsWith('temp-') && m.content == event.content);
          if (idxTemp != -1) {
            updated.removeAt(idxTemp);
            emit(current.copyWith(messages: updated));
          }
        }
        emit(ChatOperationFailure(_mapFailure(f)));
      },
      (_) {},
    );
  }

  Future<void> _onInitiateChat(InitiateChatEvent event, Emitter<ChatState> emit) async {
    emit(ChatInitiating());
    final res = await initiateChatUsecase(initiate_chat_uc.Params(event.userId));
    res.fold(
      (f) => emit(ChatOperationFailure(_mapFailure(f))),
      (chat) {
        emit(ChatInitiated(chat));
        add(RefreshChatsEvent());
      },
    );
  }

  Future<void> _onDeleteChat(DeleteChatEvent event, Emitter<ChatState> emit) async {
    emit(ChatDeleting(event.chatId));
    final res = await deleteChatUsecase(delete_chat_uc.Params(event.chatId));
    res.fold(
      (f) => emit(ChatOperationFailure(_mapFailure(f))),
      (_) {
        emit(ChatDeleted(event.chatId));
        // Trigger implicit list refresh
        add(RefreshChatsEvent());
      },
    );
  }

  void _onMessageReceived(_MessageReceivedEvent event, Emitter<ChatState> emit) {
    final current = state;
    final chatId = event.message.chat.chatId;
    if (current is MessagesLoaded && current.chatId == chatId) {
      final updated = List<Message>.from(current.messages);
      // Remove any optimistic duplicate (match by content & sender id & temp id prefix)
      final duplicateIndex = updated.indexWhere((m) => m.messageId.startsWith('temp-') && m.content == event.message.content && m.sender.id == event.message.sender.id);
      if (duplicateIndex != -1) {
        _pendingTempMessageIds.remove(updated[duplicateIndex].messageId);
        updated.removeAt(duplicateIndex);
      }
      updated.add(event.message);
      emit(current.copyWith(messages: updated));
    } else {
      _earlyMessages.putIfAbsent(chatId, () => []).add(event.message);
      final buf = _earlyMessages[chatId]!;
      if (buf.length > _maxBufferedPerChat) {
        _earlyMessages[chatId] = buf.sublist(buf.length - _maxBufferedPerChat);
      }
    }
    // Update cached chats list
    final idx = _cachedChats.indexWhere((c) => c.chatId == chatId);
    if (idx != -1) {
      final old = _cachedChats[idx];
      _cachedChats[idx] = old.copyWith(
        lastMessageContent: event.message.content,
        lastMessageAt: event.message.createdAt ?? DateTime.now(),
        unreadCount: (current is MessagesLoaded && current.chatId == chatId) ? 0 : old.unreadCount + 1,
      );
      // Move updated chat to top for recency
      final moved = _cachedChats.removeAt(idx);
      _cachedChats.insert(0, moved);
    } else {
      final base = event.message.chat;
      _cachedChats.insert(0, base.copyWith(
        lastMessageContent: event.message.content,
        lastMessageAt: event.message.createdAt ?? DateTime.now(),
        unreadCount: 1,
      ));
    }
    if (state is ChatsLoaded) {
      emit(ChatsLoaded(List<Chat>.from(_cachedChats), users: (state as ChatsLoaded).users));
    }
  }

  void _onMarkChatRead(MarkChatReadEvent event, Emitter<ChatState> emit) {
    final idx = _cachedChats.indexWhere((c) => c.chatId == event.chatId);
    if (idx != -1 && _cachedChats[idx].unreadCount != 0) {
      _cachedChats[idx] = _cachedChats[idx].copyWith(unreadCount: 0);
      if (state is ChatsLoaded) {
        emit(ChatsLoaded(List<Chat>.from(_cachedChats), users: (state as ChatsLoaded).users));
      }
    }
  }

  String _mapFailure(Failure failure) {
    if (failure.runtimeType.toString().contains('Socket')) {
      return 'Network connection problem';
    }
    return 'Unexpected error';
  }

  @override
  Future<void> close() {
    _messageSub?.cancel();
    return super.close();
  }

  Future<void> _onShutdown(ShutdownChatEvent event, Emitter<ChatState> emit) async {
    try { _messageSub?.cancel(); } catch (_) {}
  try { remoteDataSource.disposeSocket(); } catch (_) {}
    _socketInitialized = false;
  _cachedChats = [];
  _earlyMessages.clear();
    emit(ChatInitial());
  }
}
