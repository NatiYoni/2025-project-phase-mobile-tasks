import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entity/chat.dart';
import '../../domain/entity/message.dart';
import '../../domain/repository/chat_repository.dart';
import '../datasource/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final NetworkInfo networkInfo;
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.networkInfo,
    required this.remoteDataSource,
  });

  Future<Either<Failure, T>> _getResponse<T>(
    Future<T> Function() remoteCall,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteCall();
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      } on SocketException {
        return Left(SocketFailure());
      }
    } else {
      return Left(SocketFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(String chatId) {
    return _getResponse(() => remoteDataSource.deleteChat(chatId));
  }

  @override
  Future<Either<Failure, Chat>> getChatById(String chatId) {
    return _getResponse(() => remoteDataSource.getChatById(chatId));
  }
  

  @override
  Future<Either<Failure, List<Chat>>> getChats() {
    return _getResponse(() => remoteDataSource.getChats());
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String chatId) {
    return _getResponse(() => remoteDataSource.getMessages(chatId));
  }

  @override
  Stream<Either<Failure, Message>> getMessagesStream() async* {
    try {
      // Listen to the stream from the data source and yield each message.
      await for (final messageModel in remoteDataSource.getMessagesStream()) {
        yield Right(messageModel);
      }
    } on SocketException {
      yield Left(SocketFailure());
    } catch (e) {
      // Catches any other error from the stream.
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Chat>> initiateChat(String userId) {
     return _getResponse(() => remoteDataSource.initiateChat(userId));
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String chatId,
    required String content,
  }) {
    // For live socket ops, attempt without networkInfo gate; remote method now awaits ack.
    return Future(() async {
      try {
        await remoteDataSource.sendMessage(chatId: chatId, content: content);
        return const Right<Failure, void>(null);
      } on SocketException {
        return Left<Failure, void>(SocketFailure());
      } catch (_) {
        return Left<Failure, void>(ServerFailure());
      }
    });
  }
}
