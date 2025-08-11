import 'package:equatable/equatable.dart';

import '../../../authentication/domain/entity/authentication.dart';
import 'chat.dart';

class Message extends Equatable {
  final String messageId;
  final Authentication sender;
  final Chat chat;
  final String content;
  final String type;
  final DateTime? createdAt;

  const Message({
    required this.messageId,
    required this.sender,
    required this.chat,
    required this.content,
    required this.type,
    this.createdAt,
  });

  Message copyWith({
    Authentication? sender,
    Chat? chat,
    String? content,
    String? type,
    DateTime? createdAt,
  }) => Message(
        messageId: messageId,
        sender: sender ?? this.sender,
        chat: chat ?? this.chat,
        content: content ?? this.content,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [messageId, sender, chat, content, type, createdAt];
}
