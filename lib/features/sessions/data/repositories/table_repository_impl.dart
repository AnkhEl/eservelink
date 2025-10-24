import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/sessions/data/datasources/table_remote_data_source.dart';
import 'package:eservelink/features/sessions/data/models/table_model.dart';
import 'package:eservelink/features/sessions/domain/entities/table_entity.dart';
import 'package:eservelink/features/sessions/domain/repositories/table_repository.dart';

class TableRepositoryImpl implements TableRepository {
  final TableRemoteDataSource remoteDataSource;

  TableRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TableEntity>> getTableById(String tableId) async {
    try {
      final table = await remoteDataSource.getTableById(tableId);
      return Right(table);
    } catch (e) {
      return Left(TableNotFoundFailure());
    }
  }

  @override
  Future<Either<Failure, List<TableEntity>>> getRestaurantTables(
    String restaurantId,
  ) async {
    try {
      final tables = await remoteDataSource.getRestaurantTables(restaurantId);
      return Right(tables);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTableStatus(
    String tableId,
    TableStatus status,
  ) async {
    try {
      await remoteDataSource.updateTableStatus(tableId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createTable(TableEntity table) async {
    try {
      final tableModel = TableModel.fromEntity(table);
      await remoteDataSource.createTable(tableModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTable(String tableId) async {
    try {
      await remoteDataSource.deleteTable(tableId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
