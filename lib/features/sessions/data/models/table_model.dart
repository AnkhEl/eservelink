import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/sessions/domain/entities/table_entity.dart';

class TableModel extends TableEntity {
  const TableModel({
    required super.id,
    required super.restaurantId,
    required super.tableNumber,
    required super.capacity,
    required super.status,
    required super.createdAt,
  });

  // Convert from Firestore
  factory TableModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TableModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      tableNumber: data['tableNumber'] ?? '',
      capacity: data['capacity'] ?? 0,
      status: _statusFromString(data['status'] ?? 'available'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert from entity
  factory TableModel.fromEntity(TableEntity entity) {
    return TableModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      tableNumber: entity.tableNumber,
      capacity: entity.capacity,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }

  static TableStatus _statusFromString(String status) {
    switch (status) {
      case 'available':
        return TableStatus.available;
      case 'occupied':
        return TableStatus.occupied;
      case 'reserved':
        return TableStatus.reserved;
      case 'maintenance':
        return TableStatus.maintenance;
      default:
        return TableStatus.available;
    }
  }

  static String _statusToString(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'available';
      case TableStatus.occupied:
        return 'occupied';
      case TableStatus.reserved:
        return 'reserved';
      case TableStatus.maintenance:
        return 'maintenance';
    }
  }
}
