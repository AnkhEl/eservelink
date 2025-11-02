import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/notifications/data/models/notification_model.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationModel> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    String? actionUrl,
  });

  Stream<List<NotificationModel>> streamNotifications({required String userId});

  Stream<List<NotificationModel>> streamUnreadNotifications({
    required String userId,
  });

  Future<void> markAsRead({required String notificationId});

  Future<void> markAllAsRead({required String userId});

  Future<int> getUnreadCount({required String userId});

  Future<void> deleteNotification({required String notificationId});

  Future<void> deleteAllNotifications({required String userId});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl({required this.firestore});

  @override
  Future<NotificationModel> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    String? actionUrl,
  }) async {
    try {
      print('🔔 Creating notification for user: $userId');

      final notificationRef = firestore.collection('notifications').doc();

      final notificationData = {
        'userId': userId,
        'type': _notificationTypeToString(type),
        'title': title,
        'body': body,
        'data': data,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'actionUrl': actionUrl,
      };

      await notificationRef.set(notificationData);

      // Get the created notification with server timestamp
      final doc = await notificationRef.get();
      final notification = NotificationModel.fromFirestore(doc);

      print('✅ Notification created: $title');
      return notification;
    } catch (e) {
      print('❌ Failed to create notification: $e');
      throw ServerFailure('Failed to create notification: $e');
    }
  }

  @override
  Stream<List<NotificationModel>> streamNotifications({
    required String userId,
  }) {
    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit to last 50 notifications
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<NotificationModel>> streamUnreadNotifications({
    required String userId,
  }) {
    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> markAsRead({required String notificationId}) async {
    try {
      await firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });

      print('✅ Notification marked as read: $notificationId');
    } catch (e) {
      print('❌ Failed to mark notification as read: $e');
      throw ServerFailure('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead({required String userId}) async {
    try {
      final unreadNotifications =
          await firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      print('✅ All notifications marked as read for user: $userId');
    } catch (e) {
      print('❌ Failed to mark all notifications as read: $e');
      throw ServerFailure('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    try {
      final unreadNotifications =
          await firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      return unreadNotifications.docs.length;
    } catch (e) {
      print('❌ Failed to get unread count: $e');
      return 0;
    }
  }

  @override
  Future<void> deleteNotification({required String notificationId}) async {
    try {
      await firestore.collection('notifications').doc(notificationId).delete();
      print('✅ Notification deleted: $notificationId');
    } catch (e) {
      print('❌ Failed to delete notification: $e');
      throw ServerFailure('Failed to delete notification: $e');
    }
  }

  @override
  Future<void> deleteAllNotifications({required String userId}) async {
    try {
      final notifications =
          await firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .get();

      final batch = firestore.batch();
      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All notifications deleted for user: $userId');
    } catch (e) {
      print('❌ Failed to delete all notifications: $e');
      throw ServerFailure('Failed to delete all notifications: $e');
    }
  }

  String _notificationTypeToString(NotificationType type) {
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
