import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:eservelink/features/notifications/domain/usecases/create_notification_usecase.dart';

class NotificationService {
  final CreateNotificationUseCase createNotification;

  NotificationService({required this.createNotification});

  /// Send ping notification to waiter
  Future<void> sendPingNotification({
    required String waiterId,
    required String customerId,
    required String customerName,
    required String tableNumber,
    required String sessionId,
    required String pingId,
  }) async {
    await createNotification(
      CreateNotificationParams(
        userId: waiterId,
        type: NotificationType.ping,
        title: 'Customer needs attention! 🔔',
        body: '$customerName from $tableNumber is calling you',
        data: {
          'sessionId': sessionId,
          'senderId': customerId,
          'senderName': customerName,
          'tableNumber': tableNumber,
          'pingId': pingId,
        },
      ),
    );
  }

  /// Send ping acknowledged notification to customer
  Future<void> sendPingAcknowledgedNotification({
    required String customerId,
    required String waiterId,
    required String waiterName,
    required String tableNumber,
    required String sessionId,
  }) async {
    await createNotification(
      CreateNotificationParams(
        userId: customerId,
        type: NotificationType.pingAcknowledged,
        title: 'Waiter is on the way! ✅',
        body: '$waiterName has acknowledged your ping',
        data: {
          'sessionId': sessionId,
          'senderId': waiterId,
          'senderName': waiterName,
          'tableNumber': tableNumber,
        },
      ),
    );
  }

  /// Send new message notification
  Future<void> sendMessageNotification({
    required String recipientId,
    required String senderId,
    required String senderName,
    required String messageText,
    required String sessionId,
  }) async {
    await createNotification(
      CreateNotificationParams(
        userId: recipientId,
        type: NotificationType.message,
        title: 'New message from $senderName 💬',
        body:
            messageText.length > 50
                ? '${messageText.substring(0, 50)}...'
                : messageText,
        data: {
          'sessionId': sessionId,
          'senderId': senderId,
          'senderName': senderName,
          'messageText': messageText,
        },
      ),
    );
  }

  /// Send session ended notification
  Future<void> sendSessionEndedNotification({
    required String customerId,
    required String waiterName,
    required String tableNumber,
    required String sessionId,
  }) async {
    await createNotification(
      CreateNotificationParams(
        userId: customerId,
        type: NotificationType.sessionEnded,
        title: 'Session completed 🎉',
        body: 'Thank you for dining with us at $tableNumber',
        data: {
          'sessionId': sessionId,
          'tableNumber': tableNumber,
          'waiterName': waiterName,
        },
      ),
    );
  }
}
