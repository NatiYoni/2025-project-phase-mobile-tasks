part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent extends Equatable{
  const ChatEvent();

  @override
  List<Object?> get props => [];
}


/// Initialize the WebSocket connection (supply bearer token).
class InitializeSocketEvent extends ChatEvent {
  final String token;
  const InitializeSocketEvent(this.token);
  @override
  List<Object?> get props => [token];
}

/// Fetch the list of all chats.
class GetChatsEvent extends ChatEvent {}

/// Force a refresh (pull-to-refresh) of the chats list.
class RefreshChatsEvent extends ChatEvent {}

/// Fetch a single chat by id (metadata) if needed.
class GetChatByIdEvent extends ChatEvent {
  final String chatId;
  const GetChatByIdEvent(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

/// Fetch historical messages for a specific chat (initial load).
class GetMessagesEvent extends ChatEvent {
  final String chatId;
  const GetMessagesEvent(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

/// Send a new text message to a chat.
class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String content;
  const SendMessageEvent({required this.chatId, required this.content});
  @override
  List<Object?> get props => [chatId, content];
}

/// Create (initiate) a new chat with another user by userId.
class InitiateChatEvent extends ChatEvent {
  final String userId;
  const InitiateChatEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

/// Delete a chat by id.
class DeleteChatEvent extends ChatEvent {
  final String chatId;
  const DeleteChatEvent(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

/// Internal event that the BLoC will add to itself when a new message
/// is received from the WebSocket stream.
class _MessageReceivedEvent extends ChatEvent {
  final Message message;

  const _MessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}