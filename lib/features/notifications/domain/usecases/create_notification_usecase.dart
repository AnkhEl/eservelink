import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:eservelink/features/notifications/domain/repositories/notification_repository.dart';

class CreateNotificationUseCase {
  final NotificationRepository repository;

  CreateNotificationUseCase(this.repository);

  Future<Either<Failure, NotificationEntity>> call(
    CreateNotificationParams params,
  ) {
    return repository.createNotification(
      userId: params.userId,
      type: params.type,
      title: params.title,
      body: params.body,
      data: params.data,
      actionUrl: params.actionUrl,
    );
  }
}

class CreateNotificationParams {
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? actionUrl;

  CreateNotificationParams({
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.actionUrl,
  });
}
