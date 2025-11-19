// lib/features/sessions/data/datasources/ping_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/services/notification_service.dart';
import 'package:eservelink/features/sessions/data/models/ping_model.dart';

abstract class PingRemoteDataSource {
  Future<void> sendPing({
    required String sessionId,
    required String customerId,
    required String customerName,
    required String tableNumber,
    String? message,
  });

  Future<List<PingModel>> getWaiterPendingPings(String waiterId);

  Future<void> acknowledgePing({
    required String pingId,
    required String sessionId,
  });

  Stream<List<PingModel>> streamWaiterPings(String waiterId);
}

class PingRemoteDataSourceImpl implements PingRemoteDataSource {
  final FirebaseFirestore firestore;
  final NotificationService notificationService;

  PingRemoteDataSourceImpl({
    required this.firestore,
    required this.notificationService,
  });

  @override
  Future<void> sendPing({
    required String sessionId,
    required String customerId,
    required String customerName,
    required String tableNumber,
    String? message,
  }) async {
    try {
      print('🔔 Sending ping for session: $sessionId');

      // Get session to find waiter
      final sessionDoc =
          await firestore.collection('sessions').doc(sessionId).get();

      if (!sessionDoc.exists) {
        throw ServerFailure('Session not found');
      }

      final sessionData = sessionDoc.data()!;
      final waiterId = sessionData['waiterId'] as String?;

      if (waiterId == null) {
        throw ServerFailure('No waiter assigned to this session');
      }

      // Use batch write to update both collections atomically
      final batch = firestore.batch();

      // 1. Create ping document
      final pingRef = firestore.collection('pings').doc();
      batch.set(pingRef, {
        'sessionId': sessionId,
        'customerId': customerId,
        'customerName': customerName,
        'tableNumber': tableNumber,
        'message': message,
        'waiterId': waiterId,
        'isAcknowledged': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Update session document with hasPing flag
      final sessionRef = firestore.collection('sessions').doc(sessionId);
      batch.update(sessionRef, {
        'hasPing': true,
        'lastPingTime': FieldValue.serverTimestamp(),
      });

      // Commit both operations
      await batch.commit();

      print('✅ Ping sent and session updated');

      // 3. Send notification to waiter
      await notificationService.sendPingNotification(
        waiterId: waiterId,
        customerId: customerId,
        customerName: customerName,
        tableNumber: tableNumber,
        sessionId: sessionId,
        pingId: pingRef.id,
      );

      print('✅ Notification sent to waiter');
    } catch (e) {
      print('❌ Failed to send ping: $e');
      throw ServerFailure('Failed to send ping: $e');
    }
  }

  @override
  Future<List<PingModel>> getWaiterPendingPings(String waiterId) async {
    try {
      final querySnapshot =
          await firestore
              .collection('pings')
              .where('waiterId', isEqualTo: waiterId)
              .where('isAcknowledged', isEqualTo: false)
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => PingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending pings: $e');
    }
  }

  @override
  Future<void> acknowledgePing({
    required String sessionId,
    required String pingId,
  }) async {
    try {
      print('✅ Acknowledging ping: $pingId');

      // Get ping data to send notification
      final pingDoc = await firestore.collection('pings').doc(pingId).get();
      if (!pingDoc.exists) {
        throw ServerFailure('Ping not found');
      }

      final pingData = pingDoc.data()!;
      final customerId = pingData['customerId'] as String;
      final tableNumber = pingData['tableNumber'] as String;

      // Get session to find waiter info
      final sessionDoc =
          await firestore.collection('sessions').doc(sessionId).get();
      if (!sessionDoc.exists) {
        throw ServerFailure('Session not found');
      }

      final sessionData = sessionDoc.data()!;
      final waiterId = sessionData['waiterId'] as String;
      final waiterName = sessionData['waiterName'] as String;

      final batch = firestore.batch();

      // 1. Mark ping as acknowledged
      final pingRef = firestore.collection('pings').doc(pingId);
      batch.update(pingRef, {'isAcknowledged': true});

      // 2. Check if there are other unacknowledged pings for this session
      final unacknowledgedPings =
          await firestore
              .collection('pings')
              .where('sessionId', isEqualTo: sessionId)
              .where('isAcknowledged', isEqualTo: false)
              .get();

      // If this was the last unacknowledged ping, clear the hasPing flag
      if (unacknowledgedPings.docs.length <= 1) {
        final sessionRef = firestore.collection('sessions').doc(sessionId);
        batch.update(sessionRef, {'hasPing': false});
      }

      await batch.commit();

      print('✅ Ping acknowledged');

      // 3. Send notification to customer
      await notificationService.sendPingAcknowledgedNotification(
        customerId: customerId,
        waiterId: waiterId,
        waiterName: waiterName,
        tableNumber: tableNumber,
        sessionId: sessionId,
      );

      print('✅ Notification sent to customer');
    } catch (e) {
      print('❌ Failed to acknowledge ping: $e');
      throw ServerFailure('Failed to acknowledge ping: $e');
    }
  }

  @override
  Stream<List<PingModel>> streamWaiterPings(String waiterId) {
    return firestore
        .collection('pings')
        .where('waiterId', isEqualTo: waiterId)
        .where('isAcknowledged', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PingModel.fromFirestore(doc)).toList(),
        );
  }
}
