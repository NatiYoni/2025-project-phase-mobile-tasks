
import '../../../authentication/data/model/authentication_model.dart';
import '../../domain/entity/chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required super.chatId,
    required super.user1,
    required super.user2,
    super.lastMessageContent,
    super.lastMessageAt,
    super.unreadCount,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // Try to parse last message fields if backend provides them.
    String? lastContent;
    DateTime? lastAt;
    int unread = 0;
    final lm = json['lastMessage'] ?? json['latestMessage'];
    if (lm is Map) {
      lastContent = lm['content'] ?? lm['text'] ?? lm['message'];
      final rawTs = lm['createdAt'] ?? lm['timestamp'];
      if (rawTs is String) {
        try { lastAt = DateTime.parse(rawTs); } catch (_) {}
      }
    } else if (lm is String) {
      lastContent = lm;
    }
    unread = (json['unreadCount'] ?? json['unread'] ?? json['unseen'] ?? 0) is int
        ? (json['unreadCount'] ?? json['unread'] ?? json['unseen'] ?? 0) as int
        : 0;
    return ChatModel(
      chatId: json['_id'],
      user1: AuthenticationModel.fromJson(json['user1']),
      user2: AuthenticationModel.fromJson(json['user2']),
      lastMessageContent: lastContent,
      lastMessageAt: lastAt,
      unreadCount: unread,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': chatId,
      'user1': (user1 as AuthenticationModel).toJson(),
      'user2': (user2 as AuthenticationModel).toJson(),
      'lastMessageContent': lastMessageContent,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
    };
    return data;
  }
}
