import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/notifications/domain/repositories/notification_repository.dart';

class MarkAllReadUseCase {
  final NotificationRepository repository;

  MarkAllReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId) {
    return repository.markAllAsRead(userId: userId);
  }
}
