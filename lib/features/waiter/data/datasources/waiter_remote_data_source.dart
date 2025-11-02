import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/waiter/data/models/waiter_session_model.dart';

abstract class WaiterRemoteDataSource {
  Future<List<WaiterSessionModel>> getWaitingSessions({
    required String restaurantId,
  });

  Future<List<WaiterSessionModel>> getWaiterActiveSessions({
    required String waiterId,
  });

  Future<WaiterSessionModel> joinSession({
    required String tableId,
    required String waiterId,
    required String waiterName,
  });

  Future<void> endSession({required String sessionId});

  // Real-time streams
  Stream<List<WaiterSessionModel>> watchWaitingSessions({
    required String restaurantId,
  });

  Stream<List<WaiterSessionModel>> watchWaiterActiveSessions({
    required String waiterId,
  });
}

class WaiterRemoteDataSourceImpl implements WaiterRemoteDataSource {
  final FirebaseFirestore firestore;

  WaiterRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<WaiterSessionModel>> getWaitingSessions({
    required String restaurantId,
  }) async {
    try {
      final querySnapshot =
          await firestore
              .collection('sessions')
              .where('restaurantId', isEqualTo: restaurantId)
              .where('status', isEqualTo: 'waitingForWaiter')
              .orderBy('startTime', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => WaiterSessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get waiting sessions: $e');
    }
  }

  @override
  Future<List<WaiterSessionModel>> getWaiterActiveSessions({
    required String waiterId,
  }) async {
    try {
      final querySnapshot =
          await firestore
              .collection('sessions')
              .where('waiterId', isEqualTo: waiterId)
              .where('status', isEqualTo: 'active')
              .orderBy('startTime', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => WaiterSessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get active sessions: $e');
    }
  }

  @override
  Future<WaiterSessionModel> joinSession({
    required String tableId,
    required String waiterId,
    required String waiterName,
  }) async {
    try {
      // 1. Find the session by tableId with status waitingForWaiter
      final querySnapshot =
          await firestore
              .collection('sessions')
              .where('tableId', isEqualTo: tableId)
              .where('status', isEqualTo: 'waitingForWaiter')
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        throw ServerFailure('No waiting session found for this table');
      }

      final sessionDoc = querySnapshot.docs.first;

      // 2. Update the session with waiter info
      await sessionDoc.reference.update({
        'waiterId': waiterId,
        'waiterName': waiterName,
        'status': 'active',
      });

      // 3. Get the updated session
      final updatedDoc = await sessionDoc.reference.get();

      return WaiterSessionModel.fromFirestore(updatedDoc);
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Failed to join session: $e');
    }
  }

  @override
  Future<void> endSession({required String sessionId}) async {
    try {
      await firestore.collection('sessions').doc(sessionId).update({
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to end session: $e');
    }
  }

  // Real-time stream for waiting sessions
  @override
  Stream<List<WaiterSessionModel>> watchWaitingSessions({
    required String restaurantId,
  }) {
    try {
      return firestore
          .collection('sessions')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('status', isEqualTo: 'waitingForWaiter')
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => WaiterSessionModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerFailure('Failed to watch waiting sessions: $e');
    }
  }

  // Real-time stream for waiter's active sessions
  @override
  Stream<List<WaiterSessionModel>> watchWaiterActiveSessions({
    required String waiterId,
  }) {
    try {
      return firestore
          .collection('sessions')
          .where('waiterId', isEqualTo: waiterId)
          .where('status', isEqualTo: 'active')
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => WaiterSessionModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerFailure('Failed to watch active sessions: $e');
    }
  }
}
