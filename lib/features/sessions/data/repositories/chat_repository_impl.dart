import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/sessions/data/datasources/chat_remote_data_source.dart';
import 'package:eservelink/features/sessions/domain/entities/chat_message_entity.dart';
import 'package:eservelink/features/sessions/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required MessageType senderType,
    required String message,
  }) async {
    try {
      await remoteDataSource.sendMessage(
        sessionId: sessionId,
        senderId: senderId,
        senderName: senderName,
        senderType: senderType,
        message: message,
      );
      return const Right(null);
    } catch (e) {
      return Left(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessages(
    String sessionId,
  ) async {
    try {
      final messages = await remoteDataSource.getChatMessages(sessionId);
      return Right(messages);
    } catch (e) {
      return Left(ChatFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ChatMessageEntity>>> streamChatMessages(
    String sessionId,
  ) {
    try {
      return remoteDataSource
          .streamChatMessages(sessionId)
          .map((messages) => Right<Failure, List<ChatMessageEntity>>(messages))
          .handleError(
            (error) => Left<Failure, List<ChatMessageEntity>>(
              ChatFailure(error.toString()),
            ),
          );
    } catch (e) {
      return Stream.value(Left(ChatFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(String messageId) async {
    try {
      await remoteDataSource.markMessageAsRead(messageId);
      return const Right(null);
    } catch (e) {
      return Left(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(
    String sessionId,
    String userId,
  ) async {
    try {
      final count = await remoteDataSource.getUnreadCount(sessionId, userId);
      return Right(count);
    } catch (e) {
      return Left(ChatFailure(e.toString()));
    }
  }
}
