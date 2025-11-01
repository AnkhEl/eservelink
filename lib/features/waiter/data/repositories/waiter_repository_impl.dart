import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/waiter/data/datasources/waiter_remote_data_source.dart';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';
import 'package:eservelink/features/waiter/domain/repositories/waiter_repository.dart';

class WaiterRepositoryImpl implements WaiterRepository {
  final WaiterRemoteDataSource remoteDataSource;

  WaiterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<WaiterSessionEntity>>> getWaitingSessions({
    required String restaurantId,
  }) async {
    try {
      final sessions = await remoteDataSource.getWaitingSessions(
        restaurantId: restaurantId,
      );
      final entities = sessions.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WaiterSessionEntity>>> getWaiterActiveSessions({
    required String waiterId,
  }) async {
    try {
      final sessions = await remoteDataSource.getWaiterActiveSessions(
        waiterId: waiterId,
      );
      final entities = sessions.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, WaiterSessionEntity>> joinSession({
    required String tableId,
    required String waiterId,
    required String waiterName,
  }) async {
    try {
      final session = await remoteDataSource.joinSession(
        tableId: tableId,
        waiterId: waiterId,
        waiterName: waiterName,
      );
      return Right(session.toEntity());
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endSession({required String sessionId}) async {
    try {
      await remoteDataSource.endSession(sessionId: sessionId);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}