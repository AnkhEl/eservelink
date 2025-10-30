import 'package:equatable/equatable.dart';
import 'package:eservelink/features/sessions/domain/entities/order_item.dart';

class SessionEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String? restaurantName;
  final String tableId;
  final String customerId;
  final String customerName;
  final String? waiterId;
  final String? waiterName;
  final SessionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalAmount;
  final List<OrderItem> items;
  final bool isPaid;
  final bool canReview;
  final DateTime? lastPingTime;

  const SessionEntity({
    required this.id,
    required this.restaurantId,
    this.restaurantName,
    required this.tableId,
    required this.customerId,
    required this.customerName,
    this.waiterId,
    this.waiterName,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.totalAmount,
    required this.items,
    required this.isPaid,
    required this.canReview,
    this.lastPingTime,
  });

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    restaurantName,
    tableId,
    customerId,
    customerName,
    waiterId,
    waiterName,
    status,
    startTime,
    endTime,
    totalAmount,
    items,
    isPaid,
    canReview,
    lastPingTime,
  ];
}

enum SessionStatus {
  waitingForWaiter,
  active,
  paymentRequested,
  completed,
  cancelled,
}
