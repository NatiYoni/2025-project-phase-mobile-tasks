import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';



// Core
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

// Data source (for socket lifecycle)
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

  StreamSubscription? _messageSub;

  ChatBloc({
    required this.remoteDataSource,
    required this.getChatsUsecase,
    required this.getMessagesUsecase,
    required this.getMessagesStreamUsecase,
    required this.initiateChatUsecase,
    required this.deleteChatUsecase,
    required this.sendMessageUsecase,
  }) : super(ChatInitial()) {
    on<InitializeSocketEvent>(_onInitSocket);
    on<GetChatsEvent>(_onGetChats);
  on<RefreshChatsEvent>(_onRefreshChats);
    on<GetMessagesEvent>(_onGetMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<InitiateChatEvent>(_onInitiateChat);
    on<DeleteChatEvent>(_onDeleteChat);
    on<_MessageReceivedEvent>(_onMessageReceived);
  }

  Future<void> _onInitSocket(InitializeSocketEvent event, Emitter<ChatState> emit) async {
    emit(SocketInitializing());
    try {
      await remoteDataSource.initSocket(event.token);
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
    emit(ChatsLoading());
    final result = await getChatsUsecase(NoParams());
    result.fold(
      (f) => emit(ChatOperationFailure(_mapFailure(f))),
      (chats) => emit(ChatsLoaded(chats)),
    );
  }

  Future<void> _onRefreshChats(RefreshChatsEvent event, Emitter<ChatState> emit) async {
    // Keep current list (if any) while refreshing silently.
    final previous = state;
    final result = await getChatsUsecase(NoParams());
    result.fold(
      (f) => emit(ChatOperationFailure(_mapFailure(f))),
      (chats) => emit(ChatsLoaded(chats)),
    );
    // If failed and we had previous loaded state, you might re-emit it; kept simple here.
    if (state is ChatOperationFailure && previous is ChatsLoaded) {
      emit(previous); // revert to old list on failure
    }
  }

  Future<void> _onGetMessages(GetMessagesEvent event, Emitter<ChatState> emit) async {
    emit(MessagesLoading(event.chatId));
    final result = await getMessagesUsecase(get_messages_uc.Params(event.chatId));
    result.fold(
      (f) => emit(ChatOperationFailure(_mapFailure(f))),
      (messages) => emit(MessagesLoaded(chatId: event.chatId, messages: messages)),
    );
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    // Optionally show sending state
    final res = await sendMessageUsecase(send_message_uc.Params(chatId: event.chatId, content: event.content));
    res.fold(
      (f) => emit(ChatOperationFailure(_mapFailure(f))),
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
    if (current is MessagesLoaded && current.chatId == event.message.chat.chatId) {
      final updated = List<Message>.from(current.messages)..add(event.message);
      emit(current.copyWith(messages: updated));
    }
    // Only refresh chat list ordering if we're NOT currently inside a messages view.
    if (current is! MessagesLoaded && state is ChatsLoaded) {
      add(RefreshChatsEvent());
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
    try { remoteDataSource.disposeSocket(); } catch (_) {}
    return super.close();
  }
}
