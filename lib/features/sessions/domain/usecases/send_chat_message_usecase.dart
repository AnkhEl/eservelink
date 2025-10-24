import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/sessions/domain/entities/chat_message_entity.dart';
import 'package:eservelink/features/sessions/domain/repositories/chat_repository.dart';

class SendChatMessageUseCase implements UseCase<void, SendChatMessageParams> {
  final ChatRepository repository;

  SendChatMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendChatMessageParams params) async {
    // Validate message
    if (params.message.trim().isEmpty) {
      return const Left(SessionFailure('Message cannot be empty'));
    }

    return await repository.sendMessage(
      sessionId: params.sessionId,
      senderId: params.senderId,
      senderName: params.senderName,
      senderType: params.senderType,
      message: params.message.trim(),
    );
  }
}

class SendChatMessageParams extends Equatable {
  final String sessionId;
  final String senderId;
  final String senderName;
  final MessageType senderType;
  final String message;

  const SendChatMessageParams({
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
  });

  @override
  List<Object> get props => [
    sessionId,
    senderId,
    senderName,
    senderType,
    message,
  ];
}
