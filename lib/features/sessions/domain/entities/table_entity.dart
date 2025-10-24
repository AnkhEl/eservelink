import 'package:equatable/equatable.dart';

class TableEntity extends Equatable {
  final String id; // This is what the QR code contains
  final String restaurantId;
  final String tableNumber; // "Table 1", "Table 2", etc.
  final int capacity;
  final TableStatus status;
  final DateTime createdAt;

  const TableEntity({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    tableNumber,
    capacity,
    status,
    createdAt,
  ];
}

enum TableStatus {
  available,
  occupied,
  reserved,
  maintenance,
}