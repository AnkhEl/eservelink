// lib/features/sessions/data/datasources/ping_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<void> acknowledgePing(String pingId);
  Stream<List<PingModel>> streamWaiterPings(String waiterId);
}

class PingRemoteDataSourceImpl implements PingRemoteDataSource {
  final FirebaseFirestore firestore;

  PingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> sendPing({
    required String sessionId,
    required String customerId,
    required String customerName,
    required String tableNumber,
    String? message,
  }) async {
    try {
      // Get session to get waiter ID
      final sessionDoc =
          await firestore.collection('sessions').doc(sessionId).get();

      if (!sessionDoc.exists) {
        throw Exception('Session not found');
      }

      final waiterId = sessionDoc.data()?['waiterId'];

      if (waiterId == null) {
        throw Exception('No waiter assigned to this session');
      }

      // Create ping
      await firestore.collection('pings').add({
        'sessionId': sessionId,
        'customerId': customerId,
        'customerName': customerName,
        'tableNumber': tableNumber,
        'waiterId': waiterId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isAcknowledged': false,
      });

      // Update session last ping time
      await firestore.collection('sessions').doc(sessionId).update({
        'lastPingTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send ping: $e');
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
  Future<void> acknowledgePing(String pingId) async {
    try {
      await firestore.collection('pings').doc(pingId).update({
        'isAcknowledged': true,
      });
    } catch (e) {
      throw Exception('Failed to acknowledge ping: $e');
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
