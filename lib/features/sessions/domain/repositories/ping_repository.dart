import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/sessions/domain/entities/ping_entity.dart';

abstract class PingRepository {
  /// Send a ping to waiter
  Future<Either<Failure, void>> sendPing({
    required String sessionId,
    required String customerId,
    required String customerName,
    required String tableNumber,
    String? message,
  });

  /// Get pending pings for a waiter
  Future<Either<Failure, List<PingEntity>>> getWaiterPendingPings(
    String waiterId,
  );

  /// Acknowledge a ping
  Future<Either<Failure, void>> acknowledgePing(String pingId);

  /// Stream pings for a waiter (real-time)
  Stream<Either<Failure, List<PingEntity>>> streamWaiterPings(String waiterId);
}
