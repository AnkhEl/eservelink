import 'package:equatable/equatable.dart';
import 'package:eservelink/features/orders/domain/entities/cart_item_entity.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

/// Submit order
class SubmitOrderEvent extends OrderEvent {
  final String sessionId;
  final String customerId;
  final String customerName;
  final String waiterId;
  final String waiterName;
  final String restaurantId;
  final List<CartItemEntity> cartItems;
  final String? notes;

  const SubmitOrderEvent({
    required this.sessionId,
    required this.customerId,
    required this.customerName,
    required this.waiterId,
    required this.waiterName,
    required this.restaurantId,
    required this.cartItems,
    this.notes,
  });

  @override
  List<Object?> get props => [
    sessionId,
    customerId,
    customerName,
    waiterId,
    waiterName,
    restaurantId,
    cartItems,
    notes,
  ];
}

/// Start watching session orders (customer view)
class StartWatchingSessionOrdersEvent extends OrderEvent {
  final String sessionId;

  const StartWatchingSessionOrdersEvent(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

/// Start watching waiter pending orders
class StartWatchingWaiterOrdersEvent extends OrderEvent {
  final String waiterId;

  const StartWatchingWaiterOrdersEvent(this.waiterId);

  @override
  List<Object> get props => [waiterId];
}

/// Stop watching orders
class StopWatchingOrdersEvent extends OrderEvent {
  const StopWatchingOrdersEvent();
}

/// Orders updated (from stream)
class OrdersUpdatedEvent extends OrderEvent {
  final List<dynamic> orders;

  const OrdersUpdatedEvent(this.orders);

  @override
  List<Object> get props => [orders];
}

/// Confirm order (waiter action)
class ConfirmOrderEvent extends OrderEvent {
  final String orderSubmissionId;

  const ConfirmOrderEvent(this.orderSubmissionId);

  @override
  List<Object> get props => [orderSubmissionId];
}

/// Mark order as preparing
class MarkOrderPreparingEvent extends OrderEvent {
  final String orderSubmissionId;

  const MarkOrderPreparingEvent(this.orderSubmissionId);

  @override
  List<Object> get props => [orderSubmissionId];
}

/// Mark order as served
class MarkOrderServedEvent extends OrderEvent {
  final String orderSubmissionId;

  const MarkOrderServedEvent(this.orderSubmissionId);

  @override
  List<Object> get props => [orderSubmissionId];
}

/// Cancel order
class CancelOrderEvent extends OrderEvent {
  final String orderSubmissionId;
  final String reason;

  const CancelOrderEvent({
    required this.orderSubmissionId,
    required this.reason,
  });

  @override
  List<Object> get props => [orderSubmissionId, reason];
}
