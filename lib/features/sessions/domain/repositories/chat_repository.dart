import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/sessions/domain/entities/chat_message_entity.dart';

abstract class ChatRepository {
  /// Send a message
  Future<Either<Failure, void>> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required MessageType senderType,
    required String message,
  });

  /// Get chat messages for a session
  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessages(
    String sessionId,
  );

  /// Stream chat messages (real-time)
  Stream<Either<Failure, List<ChatMessageEntity>>> streamChatMessages(
    String sessionId,
  );

  /// Mark message as read
  Future<Either<Failure, void>> markMessageAsRead(String messageId);

  /// Get unread message count
  Future<Either<Failure, int>> getUnreadCount(String sessionId, String userId);
}
