import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/orders/data/models/cart_item_model.dart';
import 'package:eservelink/features/orders/data/models/order_submission_model.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:eservelink/features/sessions/data/models/order_item_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderSubmissionModel> submitOrder({
    required String sessionId,
    required String customerId,
    required String customerName,
    required String waiterId,
    required String waiterName,
    required String restaurantId,
    required List<CartItemModel> cartItems,
    String? notes,
  });

  Future<List<OrderSubmissionModel>> getSessionOrderSubmissions({
    required String sessionId,
  });

  Future<List<OrderSubmissionModel>> getWaiterPendingOrders({
    required String waiterId,
  });

  Stream<List<OrderSubmissionModel>> streamSessionOrderSubmissions({
    required String sessionId,
  });

  Stream<List<OrderSubmissionModel>> streamWaiterPendingOrders({
    required String waiterId,
  });

  Future<void> updateOrderStatus({
    required String orderSubmissionId,
    required OrderSubmissionStatus status,
  });

  Future<void> confirmOrder({required String orderSubmissionId});

  Future<void> markOrderPreparing({required String orderSubmissionId});

  Future<void> markOrderServed({required String orderSubmissionId});

  Future<void> cancelOrder({
    required String orderSubmissionId,
    required String reason,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore firestore;

  OrderRemoteDataSourceImpl({required this.firestore});

  @override
  Future<OrderSubmissionModel> submitOrder({
    required String sessionId,
    required String customerId,
    required String customerName,
    required String waiterId,
    required String waiterName,
    required String restaurantId,
    required List<CartItemModel> cartItems,
    String? notes,
  }) async {
    try {
      print('📦 Submitting order for session: $sessionId');

      // Convert cart items to order items
      final orderItems = cartItems.map((item) => item.toOrderItem()).toList();

      // Calculate totals using model's business logic
      final totals = OrderSubmissionModel.calculateTotals(orderItems);

      // Create order submission document
      final docRef = firestore.collection('order_submissions').doc();

      final orderSubmission = OrderSubmissionModel(
        id: docRef.id,
        sessionId: sessionId,
        customerId: customerId,
        customerName: customerName,
        waiterId: waiterId,
        waiterName: waiterName,
        restaurantId: restaurantId,
        items: orderItems,
        subtotal: totals['subtotal']!,
        tax: totals['tax']!,
        total: totals['total']!,
        status: OrderSubmissionStatus.pending,
        submittedAt: DateTime.now(),
        notes: notes,
      );

      // Use batch write to update both order_submissions and session
      final batch = firestore.batch();

      // 1. Create order submission
      batch.set(docRef, orderSubmission.toFirestore());

      // 2. Add items to session's items array
      final sessionRef = firestore.collection('sessions').doc(sessionId);
      batch.update(sessionRef, {
        'items': FieldValue.arrayUnion(
          orderItems
              .map((item) => OrderItemModel.fromEntity(item).toMap())
              .toList(),
        ),
        'totalAmount': FieldValue.increment(totals['total']!),
      });

      await batch.commit();

      print('✅ Order submitted successfully: ${docRef.id}');
      return orderSubmission;
    } catch (e) {
      print('❌ Failed to submit order: $e');
      throw ServerFailure('Failed to submit order: $e');
    }
  }

  @override
  Future<List<OrderSubmissionModel>> getSessionOrderSubmissions({
    required String sessionId,
  }) async {
    try {
      final querySnapshot =
          await firestore
              .collection('order_submissions')
              .where('sessionId', isEqualTo: sessionId)
              .orderBy('submittedAt', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => OrderSubmissionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get session order submissions: $e');
    }
  }

  @override
  Future<List<OrderSubmissionModel>> getWaiterPendingOrders({
    required String waiterId,
  }) async {
    try {
      final querySnapshot =
          await firestore
              .collection('order_submissions')
              .where('waiterId', isEqualTo: waiterId)
              .where('status', isEqualTo: 'pending')
              .orderBy('submittedAt', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => OrderSubmissionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get waiter pending orders: $e');
    }
  }

  @override
  Stream<List<OrderSubmissionModel>> streamSessionOrderSubmissions({
    required String sessionId,
  }) {
    return firestore
        .collection('order_submissions')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('submittedAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderSubmissionModel.fromFirestore(doc))
                  .toList(),
        );
  }

  @override
  Stream<List<OrderSubmissionModel>> streamWaiterPendingOrders({
    required String waiterId,
  }) {
    return firestore
        .collection('order_submissions')
        .where('waiterId', isEqualTo: waiterId)
        .where('status', whereIn: ['pending', 'confirmed', 'preparing'])
        .orderBy('submittedAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderSubmissionModel.fromFirestore(doc))
                  .toList(),
        );
  }

  @override
  Future<void> updateOrderStatus({
    required String orderSubmissionId,
    required OrderSubmissionStatus status,
  }) async {
    try {
      final statusString = _statusToString(status);
      final updateData = <String, dynamic>{'status': statusString};

      // Add timestamp based on status
      switch (status) {
        case OrderSubmissionStatus.confirmed:
          updateData['confirmedAt'] = FieldValue.serverTimestamp();
          break;
        case OrderSubmissionStatus.preparing:
          updateData['preparingAt'] = FieldValue.serverTimestamp();
          break;
        case OrderSubmissionStatus.served:
          updateData['servedAt'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }

      await firestore
          .collection('order_submissions')
          .doc(orderSubmissionId)
          .update(updateData);

      print('✅ Order status updated: $orderSubmissionId → $statusString');
    } catch (e) {
      throw ServerFailure('Failed to update order status: $e');
    }
  }

  @override
  Future<void> confirmOrder({required String orderSubmissionId}) async {
    try {
      await updateOrderStatus(
        orderSubmissionId: orderSubmissionId,
        status: OrderSubmissionStatus.confirmed,
      );
    } catch (e) {
      throw ServerFailure('Failed to confirm order: $e');
    }
  }

  @override
  Future<void> markOrderPreparing({required String orderSubmissionId}) async {
    try {
      await updateOrderStatus(
        orderSubmissionId: orderSubmissionId,
        status: OrderSubmissionStatus.preparing,
      );
    } catch (e) {
      throw ServerFailure('Failed to mark order as preparing: $e');
    }
  }

  @override
  Future<void> markOrderServed({required String orderSubmissionId}) async {
    try {
      await updateOrderStatus(
        orderSubmissionId: orderSubmissionId,
        status: OrderSubmissionStatus.served,
      );
    } catch (e) {
      throw ServerFailure('Failed to mark order as served: $e');
    }
  }

  @override
  Future<void> cancelOrder({
    required String orderSubmissionId,
    required String reason,
  }) async {
    try {
      await firestore
          .collection('order_submissions')
          .doc(orderSubmissionId)
          .update({
            'status': 'cancelled',
            'cancellationReason': reason,
            'cancelledAt': FieldValue.serverTimestamp(),
          });

      print('✅ Order cancelled: $orderSubmissionId');
    } catch (e) {
      throw ServerFailure('Failed to cancel order: $e');
    }
  }

  String _statusToString(OrderSubmissionStatus status) {
    switch (status) {
      case OrderSubmissionStatus.pending:
        return 'pending';
      case OrderSubmissionStatus.confirmed:
        return 'confirmed';
      case OrderSubmissionStatus.preparing:
        return 'preparing';
      case OrderSubmissionStatus.served:
        return 'served';
      case OrderSubmissionStatus.cancelled:
        return 'cancelled';
    }
  }
}
