import 'package:equatable/equatable.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to notifications for a user
class StartListeningToNotificationsEvent extends NotificationEvent {
  final String userId;

  const StartListeningToNotificationsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Stop listening to notifications
class StopListeningToNotificationsEvent extends NotificationEvent {}

/// Internal event when notifications are updated from stream
class NotificationsUpdatedEvent extends NotificationEvent {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationsUpdatedEvent({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// Create a notification
class CreateNotificationEvent extends NotificationEvent {
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? actionUrl;

  const CreateNotificationEvent({
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.actionUrl,
  });

  @override
  List<Object?> get props => [userId, type, title, body, data, actionUrl];
}

/// Mark notification as read
class MarkNotificationReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class MarkAllNotificationsReadEvent extends NotificationEvent {
  final String userId;

  const MarkAllNotificationsReadEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Delete notification
class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}
