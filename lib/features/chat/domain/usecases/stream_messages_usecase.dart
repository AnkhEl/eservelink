import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/chat/domain/entities/message_entity.dart';
import 'package:eservelink/features/chat/domain/repositories/chat_repository.dart';

class StreamMessagesUseCase {
  final ChatRepository repository;

  StreamMessagesUseCase(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(String sessionId) {
    return repository.streamMessages(sessionId: sessionId);
  }
}
