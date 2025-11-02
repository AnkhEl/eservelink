import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:eservelink/features/notifications/domain/repositories/notification_repository.dart';

class StreamUnreadNotificationsUseCase {
  final NotificationRepository repository;

  StreamUnreadNotificationsUseCase(this.repository);

  Stream<Either<Failure, List<NotificationEntity>>> call(String userId) {
    return repository.streamUnreadNotifications(userId: userId);
  }
}
