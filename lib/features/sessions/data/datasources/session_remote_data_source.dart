import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/sessions/data/models/session_model.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/sessions/domain/entities/order_item.dart';

abstract class SessionRemoteDataSource {
  Future<SessionModel> createSession({
    required String restaurantId,
    required String tableId,
    required String customerId,
    required String customerName,
  });

  Future<SessionModel> joinSessionAsWaiter({
    required String sessionId,
    required String waiterId,
    required String waiterName,
  });

  Future<SessionModel?> getActiveSessionByTable(String tableId);
  Future<SessionModel> getSessionById(String sessionId);
  Future<SessionModel?> getCustomerActiveSession(String customerId);
  Future<List<SessionModel>> getWaiterActiveSessions(String waiterId);
  Future<void> updateSessionStatus(String sessionId, SessionStatus status);
  Future<void> addItemToSession(String sessionId, OrderItem item);
  Future<void> updateSessionTotal(String sessionId, double totalAmount);
  Future<void> markSessionAsPaid(String sessionId);
  Future<void> completeSession(String sessionId);
  Future<void> cancelSession(String sessionId);
  Stream<SessionModel> streamSession(String sessionId);
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final FirebaseFirestore firestore;

  SessionRemoteDataSourceImpl({required this.firestore});

  @override
  Future<SessionModel> createSession({
    required String restaurantId,
    required String tableId,
    required String customerId,
    required String customerName,
  }) async {
    try {
      final docRef = firestore.collection('sessions').doc();

      final session = SessionModel(
        id: docRef.id,
        restaurantId: restaurantId,
        tableId: tableId,
        customerId: customerId,
        customerName: customerName,
        waiterId: null,
        waiterName: null,
        status: SessionStatus.waitingForWaiter,
        startTime: DateTime.now(),
        endTime: null,
        totalAmount: 0.0,
        items: [],
        isPaid: false,
        canReview: false,
        lastPingTime: null,
      );

      await docRef.set(SessionModel.fromEntity(session).toFirestore());

      return session;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  @override
  Future<SessionModel> joinSessionAsWaiter({
    required String sessionId,
    required String waiterId,
    required String waiterName,
  }) async {
    try {
      await firestore.collection('sessions').doc(sessionId).update({
        'waiterId': waiterId,
        'waiterName': waiterName,
        'status': 'active',
      });

      final doc = await firestore.collection('sessions').doc(sessionId).get();
      return SessionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to join session as waiter: $e');
    }
  }

  @override
  Future<SessionModel?> getActiveSessionByTable(String tableId) async {
    try {
      final querySnapshot =
          await firestore
              .collection('sessions')
              .where('tableId', isEqualTo: tableId)
              .where('status', whereIn: ['waitingForWaiter', 'active'])
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return SessionModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get active session by table: $e');
    }
  }

  @override
  Future<SessionModel> getSessionById(String sessionId) async {
    try {
      final doc = await firestore.collection('sessions').doc(sessionId).get();

      if (!doc.exists) {
        throw Exception('Session not found');
      }

      return SessionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  @override
  Future<SessionModel?> getCustomerActiveSession(String customerId) async {
    try {
      final querySnapshot =
          await firestore
              .collection('sessions')
              .where('customerId', isEqualTo: customerId)
              .where('status', whereIn: ['waitingForWaiter', 'active'])
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return SessionModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get customer active session: $e');
    }
  }

  @override
  Future<List<SessionModel>> getWaiterActiveSessions(String waiterId) async {
    try {
      final querySnapshot =
          await firestore
              .collection('sessions')
              .where('waiterId', isEqualTo: waiterId)
              .where('status', isEqualTo: 'active')
              .get();

      return querySnapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get waiter active sessions: $e');
    }
  }

  @override
  Future<void> updateSessionStatus(
    String sessionId,
    SessionStatus status,
  ) async {
    try {
      await firestore.collection('sessions').doc(sessionId).update({
        'status': _statusToString(status),
      });
    } catch (e) {
      throw Exception('Failed to update session status: $e');
    }
  }

  @override
  Future<void> addItemToSession(String sessionId, OrderItem item) async {
    try {
      final doc = await firestore.collection('sessions').doc(sessionId).get();
      final session = SessionModel.fromFirestore(doc);

      final updatedItems = [...session.items, item];
      final newTotal = updatedItems.fold(
        0.0,
        (sum, item) => sum + item.subtotal,
      );

      await firestore.collection('sessions').doc(sessionId).update({
        'items':
            updatedItems
                .map(
                  (item) => {
                    'id': item.id,
                    'name': item.name,
                    'quantity': item.quantity,
                    'price': item.price,
                    'subtotal': item.subtotal,
                    'addedAt': item.addedAt.toIso8601String(),
                    'notes': item.notes,
                  },
                )
                .toList(),
        'totalAmount': newTotal,
      });
    } catch (e) {
      throw Exception('Failed to add item to session: $e');
    }
  }

  @override
  Future<void> updateSessionTotal(String sessionId, double totalAmount) async {
    try {
      await firestore.collection('sessions').doc(sessionId).update({
        'totalAmount': totalAmount,
      });
    } catch (e) {
      throw Exception('Failed to update session total: $e');
    }
  }

  @override
  Future<void> markSessionAsPaid(String sessionId) async {
    try {
      await firestore.collection('sessions').doc(sessionId).update({
        'isPaid': true,
        'canReview': true,
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark session as paid: $e');
    }
  }

  @override
  Future<void> completeSession(String sessionId) async {
    try {
      await firestore.collection('sessions').doc(sessionId).update({
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to complete session: $e');
    }
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    try {
      await firestore.collection('sessions').doc(sessionId).update({
        'status': 'cancelled',
        'endTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel session: $e');
    }
  }

  @override
  Stream<SessionModel> streamSession(String sessionId) {
    return firestore
        .collection('sessions')
        .doc(sessionId)
        .snapshots()
        .map((doc) => SessionModel.fromFirestore(doc));
  }

  String _statusToString(SessionStatus status) {
    switch (status) {
      case SessionStatus.waitingForWaiter:
        return 'waitingForWaiter';
      case SessionStatus.active:
        return 'active';
      case SessionStatus.paymentRequested:
        return 'paymentRequested';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.cancelled:
        return 'cancelled';
    }
  }
}
