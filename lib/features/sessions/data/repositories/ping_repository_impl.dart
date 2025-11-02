// lib/features/sessions/data/repositories/ping_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/sessions/data/datasources/ping_remote_data_source.dart';
import 'package:eservelink/features/sessions/domain/entities/ping_entity.dart';
import 'package:eservelink/features/sessions/domain/repositories/ping_repository.dart';

class PingRepositoryImpl implements PingRepository {
  final PingRemoteDataSource remoteDataSource;

  PingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendPing({
    required String sessionId,
    required String customerId,
    required String customerName,
    required String tableNumber,
    String? message,
  }) async {
    try {
      await remoteDataSource.sendPing(
        sessionId: sessionId,
        customerId: customerId,
        customerName: customerName,
        tableNumber: tableNumber,
        message: message,
      );
      return const Right(null);
    } catch (e) {
      return Left(PingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PingEntity>>> getWaiterPendingPings(
    String waiterId,
  ) async {
    try {
      final pings = await remoteDataSource.getWaiterPendingPings(waiterId);
      return Right(pings);
    } catch (e) {
      return Left(PingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acknowledgePing({
    required String pingId,
    required String sessionId,
  }) async {
    try {
      await remoteDataSource.acknowledgePing(
        pingId: pingId,
        sessionId: sessionId,
      );
      return const Right(null);
    } catch (e) {
      return Left(PingFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<PingEntity>>> streamWaiterPings(String waiterId) {
    try {
      return remoteDataSource
          .streamWaiterPings(waiterId)
          .map((pings) => Right<Failure, List<PingEntity>>(pings))
          .handleError(
            (error) =>
                Left<Failure, List<PingEntity>>(PingFailure(error.toString())),
          );
    } catch (e) {
      return Stream.value(Left(PingFailure(e.toString())));
    }
  }
}
