import 'package:equatable/equatable.dart';

import '../../../authentication/domain/entity/authentication.dart';

class Chat extends Equatable {
  final String chatId;
  final Authentication user1;
  final Authentication user2;
  final String? lastMessageContent;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const Chat({
    required this.chatId,
    required this.user1,
    required this.user2,
    this.lastMessageContent,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  Chat copyWith({
    Authentication? user1,
    Authentication? user2,
    String? lastMessageContent,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) => Chat(
        chatId: chatId,
        user1: user1 ?? this.user1,
        user2: user2 ?? this.user2,
        lastMessageContent: lastMessageContent ?? this.lastMessageContent,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
      );

  @override
  List<Object?> get props => [chatId, user1, user2, lastMessageContent, lastMessageAt, unreadCount];
}
