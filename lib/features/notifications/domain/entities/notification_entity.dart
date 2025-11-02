import 'package:equatable/equatable.dart';

enum NotificationType {
  ping,
  pingAcknowledged,
  message,
  order,
  payment,
  sessionEnded,
  general,
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime timestamp;
  final String? actionUrl;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.timestamp,
    this.actionUrl,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    body,
    data,
    isRead,
    timestamp,
    actionUrl,
  ];
}
