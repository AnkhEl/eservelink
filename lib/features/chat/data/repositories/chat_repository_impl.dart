import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:eservelink/features/chat/domain/entities/message_entity.dart';
import 'package:eservelink/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        sessionId: sessionId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        text: text,
      );
      return Right(message.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> streamMessages({
    required String sessionId,
  }) {
    try {
      return remoteDataSource
          .streamMessages(sessionId: sessionId)
          .map(
            (messages) =>
                Right(messages.map((model) => model.toEntity()).toList()),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String sessionId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.markMessagesAsRead(
        sessionId: sessionId,
        userId: userId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendTypingIndicator({
    required String sessionId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await remoteDataSource.sendTypingIndicator(
        sessionId: sessionId,
        userId: userId,
        isTyping: isTyping,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Map<String, bool>>> streamTypingIndicators({
    required String sessionId,
  }) {
    try {
      return remoteDataSource
          .streamTypingIndicators(sessionId: sessionId)
          .map((indicators) => Right(indicators));
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({
    required String sessionId,
    required String userId,
  }) async {
    try {
      final count = await remoteDataSource.getUnreadCount(
        sessionId: sessionId,
        userId: userId,
      );
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
