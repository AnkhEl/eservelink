import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Create a new notification
  Future<Either<Failure, NotificationEntity>> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    String? actionUrl,
  });

  /// Stream notifications for a user (real-time)
  Stream<Either<Failure, List<NotificationEntity>>> streamNotifications({
    required String userId,
  });

  /// Stream unread notifications only
  Stream<Either<Failure, List<NotificationEntity>>> streamUnreadNotifications({
    required String userId,
  });

  /// Mark notification as read
  Future<Either<Failure, void>> markAsRead({required String notificationId});

  /// Mark all notifications as read for a user
  Future<Either<Failure, void>> markAllAsRead({required String userId});

  /// Get unread count
  Future<Either<Failure, int>> getUnreadCount({required String userId});

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification({
    required String notificationId,
  });

  /// Delete all notifications for a user
  Future<Either<Failure, void>> deleteAllNotifications({
    required String userId,
  });
}
