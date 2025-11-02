import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';

abstract class WaiterRepository {
  /// Get all sessions waiting for a waiter in a restaurant
  Future<Either<Failure, List<WaiterSessionEntity>>> getWaitingSessions({
    required String restaurantId,
  });

  /// Get all active sessions for a specific waiter
  Future<Either<Failure, List<WaiterSessionEntity>>> getWaiterActiveSessions({
    required String waiterId,
  });

  /// Join a session by scanning table QR
  Future<Either<Failure, WaiterSessionEntity>> joinSession({
    required String tableId,
    required String waiterId,
    required String waiterName,
  });

  /// End/complete a session
  Future<Either<Failure, void>> endSession({required String sessionId});

  // Real-time streams
  Stream<Either<Failure, List<WaiterSessionEntity>>> watchWaitingSessions({
    required String restaurantId,
  });

  Stream<Either<Failure, List<WaiterSessionEntity>>> watchWaiterActiveSessions({
    required String waiterId,
  });
}
