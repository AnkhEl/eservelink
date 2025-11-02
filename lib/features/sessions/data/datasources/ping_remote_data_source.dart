import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/core/error/failures.dart';
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
    } catch (e) {
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
    } catch (e) {
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
