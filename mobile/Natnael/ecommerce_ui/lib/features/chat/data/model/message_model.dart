
import '../../../authentication/data/model/authentication_model.dart';
import '../../domain/entity/message.dart';
import 'chat_model.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.messageId,
    required super.sender,
    required super.chat,
    required super.content,
    required super.type,
    super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    DateTime? ts;
    final rawTs = json['createdAt'] ?? json['timestamp'];
    if (rawTs is String) {
      try { ts = DateTime.parse(rawTs); } catch (_) {}
    }
    return MessageModel(
      messageId: json['_id'],
      sender: AuthenticationModel.fromJson(json['sender']),
      chat: ChatModel.fromJson(json['chat']),
      content: json['content'],
      type: json['type'],
      createdAt: ts,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': messageId,
      'sender': (sender as AuthenticationModel).toJson(),
      'chat': (chat as ChatModel).toJson(),
      'content': content,
      'type': type,
      'createdAt': createdAt?.toIso8601String(),
    };
    return data;
  }
}
