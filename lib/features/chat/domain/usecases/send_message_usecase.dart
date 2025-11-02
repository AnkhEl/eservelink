import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/chat/domain/entities/message_entity.dart';
import 'package:eservelink/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return repository.sendMessage(
      sessionId: params.sessionId,
      senderId: params.senderId,
      senderName: params.senderName,
      senderRole: params.senderRole,
      text: params.text,
    );
  }
}

class SendMessageParams {
  final String sessionId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;

  SendMessageParams({
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
  });
}
