import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/sessions/domain/entities/table_entity.dart';

abstract class TableRepository {
  /// Get table by QR code
  Future<Either<Failure, TableEntity>> getTableById(String tableId);

  /// Get all tables for a restaurant
  Future<Either<Failure, List<TableEntity>>> getRestaurantTables(
    String restaurantId,
  );

  /// Update table status
  Future<Either<Failure, void>> updateTableStatus(
    String tableId,
    TableStatus status,
  );

  /// Create a new table (admin only)
  Future<Either<Failure, void>> createTable(TableEntity table);

  /// Delete a table (admin only)
  Future<Either<Failure, void>> deleteTable(String tableId);
}
