import 'package:equatable/equatable.dart';

class PingEntity extends Equatable {
  final String id;
  final String sessionId;
  final String customerId;
  final String customerName;
  final String tableNumber;
  final DateTime timestamp;
  final bool isAcknowledged;
  final String? message;

  const PingEntity({
    required this.id,
    required this.sessionId,
    required this.customerId,
    required this.customerName,
    required this.tableNumber,
    required this.timestamp,
    required this.isAcknowledged,
    this.message,
  });

  @override
  List<Object?> get props => [
    id,
    sessionId,
    customerId,
    customerName,
    tableNumber,
    timestamp,
    isAcknowledged,
    message,
  ];
}
