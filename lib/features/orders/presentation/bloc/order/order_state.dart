import 'package:equatable/equatable.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OrderInitial extends OrderState {
  const OrderInitial();
}

/// Loading
class OrderLoading extends OrderState {
  const OrderLoading();
}

/// Order submitted successfully
class OrderSubmitted extends OrderState {
  final OrderSubmissionEntity order;

  const OrderSubmitted(this.order);

  @override
  List<Object> get props => [order];
}

/// Orders loaded (list of orders)
class OrdersLoaded extends OrderState {
  final List<OrderSubmissionEntity> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

/// Order status updated
class OrderStatusUpdated extends OrderState {
  final String message;

  const OrderStatusUpdated(this.message);

  @override
  List<Object> get props => [message];
}

/// Error
class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}
