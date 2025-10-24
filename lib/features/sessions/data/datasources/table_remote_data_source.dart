import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/sessions/data/models/table_model.dart';
import 'package:eservelink/features/sessions/domain/entities/table_entity.dart';

abstract class TableRemoteDataSource {
  Future<TableModel> getTableById(String tableId);
  Future<List<TableModel>> getRestaurantTables(String restaurantId);
  Future<void> updateTableStatus(String tableId, TableStatus status);
  Future<void> createTable(TableModel table);
  Future<void> deleteTable(String tableId);
}

class TableRemoteDataSourceImpl implements TableRemoteDataSource {
  final FirebaseFirestore firestore;

  TableRemoteDataSourceImpl({required this.firestore});

  @override
  Future<TableModel> getTableById(String tableId) async {
    try {
      final doc = await firestore.collection('tables').doc(tableId).get();

      if (!doc.exists) {
        throw Exception('Table not found');
      }

      return TableModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get table: $e');
    }
  }

  @override
  Future<List<TableModel>> getRestaurantTables(String restaurantId) async {
    try {
      final querySnapshot =
          await firestore
              .collection('tables')
              .where('restaurantId', isEqualTo: restaurantId)
              .orderBy('tableNumber')
              .get();

      return querySnapshot.docs
          .map((doc) => TableModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get restaurant tables: $e');
    }
  }

  @override
  Future<void> updateTableStatus(String tableId, TableStatus status) async {
    try {
      await firestore.collection('tables').doc(tableId).update({
        'status': _statusToString(status),
      });
    } catch (e) {
      throw Exception('Failed to update table status: $e');
    }
  }

  @override
  Future<void> createTable(TableModel table) async {
    try {
      await firestore
          .collection('tables')
          .doc(table.id)
          .set(table.toFirestore());
    } catch (e) {
      throw Exception('Failed to create table: $e');
    }
  }

  @override
  Future<void> deleteTable(String tableId) async {
    try {
      await firestore.collection('tables').doc(tableId).delete();
    } catch (e) {
      throw Exception('Failed to delete table: $e');
    }
  }

  String _statusToString(TableStatus status) {
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
