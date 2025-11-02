import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.body,
    required super.data,
    required super.isRead,
    required super.timestamp,
    super.actionUrl,
  });

  /// Create from Firestore DocumentSnapshot
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String,
      type: _notificationTypeFromString(data['type'] as String),
      title: data['title'] as String,
      body: data['body'] as String,
      data: Map<String, dynamic>.from(data['data'] as Map),
      isRead: data['isRead'] as bool? ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      actionUrl: data['actionUrl'] as String?,
    );
  }

  /// Create from Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: _notificationTypeFromString(map['type'] as String),
      title: map['title'] as String,
      body: map['body'] as String,
      data: Map<String, dynamic>.from(map['data'] as Map),
      isRead: map['isRead'] as bool? ?? false,
      timestamp:
          map['timestamp'] is Timestamp
              ? (map['timestamp'] as Timestamp).toDate()
              : DateTime.parse(map['timestamp'] as String),
      actionUrl: map['actionUrl'] as String?,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': _notificationTypeToString(type),
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'timestamp': FieldValue.serverTimestamp(),
      'actionUrl': actionUrl,
    };
  }

  /// Convert from Entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      data: entity.data,
      isRead: entity.isRead,
      timestamp: entity.timestamp,
      actionUrl: entity.actionUrl,
    );
  }

  /// Convert to Entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead,
      timestamp: timestamp,
      actionUrl: actionUrl,
    );
  }

  /// Helper: Convert string to NotificationType
  static NotificationType _notificationTypeFromString(String type) {
    switch (type) {
      case 'ping':
        return NotificationType.ping;
      case 'ping_acknowledged':
        return NotificationType.pingAcknowledged;
      case 'message':
        return NotificationType.message;
      case 'order':
        return NotificationType.order;
      case 'payment':
        return NotificationType.payment;
      case 'session_ended':
        return NotificationType.sessionEnded;
      case 'general':
      default:
        return NotificationType.general;
    }
  }

  /// Helper: Convert NotificationType to string
  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.ping:
        return 'ping';
      case NotificationType.pingAcknowledged:
        return 'ping_acknowledged';
      case NotificationType.message:
        return 'message';
      case NotificationType.order:
        return 'order';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.sessionEnded:
        return 'session_ended';
      case NotificationType.general:
        return 'general';
    }
  }
}
