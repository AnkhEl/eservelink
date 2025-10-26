import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/sessions/data/datasources/session_remote_data_source.dart';
import 'package:eservelink/features/sessions/domain/entities/order_item.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;

  SessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SessionEntity>> createSession({
    required String restaurantId,
    required String tableId,
    required String customerId,
    required String customerName,
  }) async {
    try {
      final session = await remoteDataSource.createSession(
        restaurantId: restaurantId,
        tableId: tableId,
        customerId: customerId,
        customerName: customerName,
      );
      return Right(session);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> joinSessionAsWaiter({
    required String sessionId,
    required String waiterId,
    required String waiterName,
  }) async {
    try {
      final session = await remoteDataSource.joinSessionAsWaiter(
        sessionId: sessionId,
        waiterId: waiterId,
        waiterName: waiterName,
      );
      return Right(session);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionEntity?>> getActiveSessionByTable(
    String tableId,
  ) async {
    try {
      final session = await remoteDataSource.getActiveSessionByTable(tableId);
      return Right(session);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> getSessionById(
    String sessionId,
  ) async {
    try {
      final session = await remoteDataSource.getSessionById(sessionId);
      return Right(session);
    } catch (e) {
      return Left(SessionNotFoundFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity?>> getCustomerActiveSession(
    String customerId,
  ) async {
    try {
      final session = await remoteDataSource.getCustomerActiveSession(
        customerId,
      );
      return Right(session);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getWaiterActiveSessions(
    String waiterId,
  ) async {
    try {
      final sessions = await remoteDataSource.getWaiterActiveSessions(waiterId);
      return Right(sessions);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSessionStatus(
    String sessionId,
    SessionStatus status,
  ) async {
    try {
      await remoteDataSource.updateSessionStatus(sessionId, status);
      return const Right(null);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addItemToSession(
    String sessionId,
    OrderItem item,
  ) async {
    try {
      await remoteDataSource.addItemToSession(sessionId, item);
      return const Right(null);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSessionTotal(
    String sessionId,
    double totalAmount,
  ) async {
    try {
      await remoteDataSource.updateSessionTotal(sessionId, totalAmount);
      return const Right(null);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markSessionAsPaid(String sessionId) async {
    try {
      await remoteDataSource.markSessionAsPaid(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeSession(String sessionId) async {
    try {
      await remoteDataSource.completeSession(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSession(String sessionId) async {
    try {
      await remoteDataSource.cancelSession(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, SessionEntity>> streamSession(String sessionId) {
    try {
      return remoteDataSource
          .streamSession(sessionId)
          .map((session) => Right<Failure, SessionEntity>(session))
          .handleError(
            (error) =>
                Left<Failure, SessionEntity>(SessionFailure(error.toString())),
          );
    } catch (e) {
      return Stream.value(Left(SessionFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getUserSessions({
    required String customerId,
    int limit = 50,
  }) async {
    try {
      final sessions = await remoteDataSource.getUserSessions(
        customerId: customerId,
        limit: limit,
      );
      return Right(sessions);
    } catch (e) {
      return Left(SessionFailure(e.toString()));
    }
  }
}
