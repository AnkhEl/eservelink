import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/orders/domain/entities/cart_item_entity.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';

abstract class OrderRepository {
  /// Submit order to kitchen
  Future<Either<Failure, OrderSubmissionEntity>> submitOrder({
    required String sessionId,
    required String customerId,
    required String customerName,
    required String waiterId,
    required String waiterName,
    required String restaurantId,
    required List<CartItemEntity> cartItems,
    String? notes,
  });

  /// Get all order submissions for a session
  Future<Either<Failure, List<OrderSubmissionEntity>>>
  getSessionOrderSubmissions({required String sessionId});

  /// Get pending order submissions for a waiter
  Future<Either<Failure, List<OrderSubmissionEntity>>> getWaiterPendingOrders({
    required String waiterId,
  });

  /// Stream order submissions for a session (real-time)
  Stream<Either<Failure, List<OrderSubmissionEntity>>>
  streamSessionOrderSubmissions({required String sessionId});

  /// Stream pending orders for a waiter (real-time)
  Stream<Either<Failure, List<OrderSubmissionEntity>>>
  streamWaiterPendingOrders({required String waiterId});

  /// Update order submission status
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderSubmissionId,
    required OrderSubmissionStatus status,
  });

  /// Confirm order (waiter action)
  Future<Either<Failure, void>> confirmOrder({
    required String orderSubmissionId,
  });

  /// Mark order as preparing
  Future<Either<Failure, void>> markOrderPreparing({
    required String orderSubmissionId,
  });

  /// Mark order as served
  Future<Either<Failure, void>> markOrderServed({
    required String orderSubmissionId,
  });

  /// Cancel order
  Future<Either<Failure, void>> cancelOrder({
    required String orderSubmissionId,
    required String reason,
  });
}
