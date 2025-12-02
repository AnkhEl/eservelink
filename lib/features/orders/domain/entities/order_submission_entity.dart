import 'package:equatable/equatable.dart';
import 'package:eservelink/features/sessions/domain/entities/order_item.dart';

/// Represents a group of items submitted to the kitchen
class OrderSubmissionEntity extends Equatable {
  final String id;
  final String sessionId;
  final String customerId;
  final String customerName;
  final String waiterId;
  final String waiterName;
  final String restaurantId;
  final List<OrderItem> items; // References existing OrderItem from sessions
  final double subtotal;
  final double tax;
  final double total;
  final OrderSubmissionStatus status;
  final DateTime submittedAt;
  final DateTime? confirmedAt;
  final DateTime? preparingAt;
  final DateTime? servedAt;
  final String? notes;

  const OrderSubmissionEntity({
    required this.id,
    required this.sessionId,
    required this.customerId,
    required this.customerName,
    required this.waiterId,
    required this.waiterName,
    required this.restaurantId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.submittedAt,
    this.confirmedAt,
    this.preparingAt,
    this.servedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    sessionId,
    customerId,
    customerName,
    waiterId,
    waiterName,
    restaurantId,
    items,
    subtotal,
    tax,
    total,
    status,
    submittedAt,
    confirmedAt,
    preparingAt,
    servedAt,
    notes,
  ];
}

enum OrderSubmissionStatus { pending, confirmed, preparing, served, cancelled }
