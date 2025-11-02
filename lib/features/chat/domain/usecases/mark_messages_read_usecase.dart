import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/chat/domain/repositories/chat_repository.dart';

class MarkMessagesReadUseCase {
  final ChatRepository repository;

  MarkMessagesReadUseCase(this.repository);

  Future<Either<Failure, void>> call(MarkMessagesReadParams params) {
    return repository.markMessagesAsRead(
      sessionId: params.sessionId,
      userId: params.userId,
    );
  }
}

class MarkMessagesReadParams {
  final String sessionId;
  final String userId;

  MarkMessagesReadParams({required this.sessionId, required this.userId});
}
