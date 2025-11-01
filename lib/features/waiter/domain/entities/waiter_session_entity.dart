import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';

class WaiterSessionEntity extends SessionEntity {
  final bool hasPing;
  final int unreadMessages;

  const WaiterSessionEntity({
    required super.id,
    required super.restaurantId,
    super.restaurantName,
    required super.tableId,
    required super.customerId,
    required super.customerName,
    super.waiterId,
    super.waiterName,
    required super.status,
    required super.startTime,
    super.endTime,
    required super.totalAmount,
    required super.items,
    required super.isPaid,
    required super.canReview,
    super.lastPingTime,
    this.hasPing = false,
    this.unreadMessages = 0,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    hasPing,
    unreadMessages,
  ];
}
