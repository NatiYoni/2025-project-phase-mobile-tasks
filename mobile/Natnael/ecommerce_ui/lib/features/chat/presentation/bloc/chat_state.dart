part of 'chat_bloc.dart';

@immutable
abstract class ChatState extends Equatable {
	const ChatState();

	@override
	List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

// Socket
class SocketInitializing extends ChatState {}
class SocketReady extends ChatState {}
class SocketError extends ChatState {
	final String message;
	const SocketError(this.message);
	@override
	List<Object?> get props => [message];
}

// Chats list
class ChatsLoading extends ChatState {}
class ChatsLoaded extends ChatState {
	final List<Chat> chats;
	final List<Authentication> users;
	const ChatsLoaded(this.chats, {this.users = const []});
	@override
	List<Object?> get props => [chats, users];

	ChatsLoaded copyWith({List<Chat>? chats, List<Authentication>? users}) =>
			ChatsLoaded(chats ?? this.chats, users: users ?? this.users);
}

// Single chat messages
class MessagesLoading extends ChatState {
	final String chatId;
	const MessagesLoading(this.chatId);
	@override
	List<Object?> get props => [chatId];
}
class MessagesLoaded extends ChatState {
	final String chatId;
	final List<Message> messages;
	const MessagesLoaded({required this.chatId, required this.messages});
	@override
	List<Object?> get props => [chatId, messages];

	MessagesLoaded copyWith({List<Message>? messages}) => MessagesLoaded(
				chatId: chatId,
				messages: messages ?? this.messages,
			);
}

// Chat creation / deletion
class ChatInitiating extends ChatState {}
class ChatInitiated extends ChatState {
	final Chat chat;
	const ChatInitiated(this.chat);
	@override
	List<Object?> get props => [chat];
}
class ChatDeleting extends ChatState {
	final String chatId;
	const ChatDeleting(this.chatId);
	@override
	List<Object?> get props => [chatId];
}
class ChatDeleted extends ChatState {
	final String chatId;
	const ChatDeleted(this.chatId);
	@override
	List<Object?> get props => [chatId];
}

// Sending
class MessageSending extends ChatState {}

// Generic failure
class ChatOperationFailure extends ChatState {
	final String message;
	const ChatOperationFailure(this.message);
	@override
	List<Object?> get props => [message];
}

