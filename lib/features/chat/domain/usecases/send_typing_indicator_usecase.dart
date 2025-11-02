import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/chat/domain/repositories/chat_repository.dart';

class SendTypingIndicatorUseCase {
  final ChatRepository repository;

  SendTypingIndicatorUseCase(this.repository);

  Future<Either<Failure, void>> call(TypingIndicatorParams params) {
    return repository.sendTypingIndicator(
      sessionId: params.sessionId,
      userId: params.userId,
      isTyping: params.isTyping,
    );
  }
}

class TypingIndicatorParams {
  final String sessionId;
  final String userId;
  final bool isTyping;

  TypingIndicatorParams({
    required this.sessionId,
    required this.userId,
    required this.isTyping,
  });
}
