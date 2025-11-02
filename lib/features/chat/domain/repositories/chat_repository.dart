import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  /// Send a message in a session
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  });

  /// Stream messages for a session in real-time
  Stream<Either<Failure, List<MessageEntity>>> streamMessages({
    required String sessionId,
  });

  /// Mark messages as read
  Future<Either<Failure, void>> markMessagesAsRead({
    required String sessionId,
    required String userId,
  });

  /// Send typing indicator
  Future<Either<Failure, void>> sendTypingIndicator({
    required String sessionId,
    required String userId,
    required bool isTyping,
  });

  /// Stream typing indicator
  Stream<Either<Failure, Map<String, bool>>> streamTypingIndicators({
    required String sessionId,
  });

  /// Get unread message count for a user
  Future<Either<Failure, int>> getUnreadCount({
    required String sessionId,
    required String userId,
  });
}
