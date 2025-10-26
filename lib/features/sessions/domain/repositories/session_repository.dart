import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/sessions/domain/entities/order_item.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';

abstract class SessionRepository {
  /// Create a new session (customer scans QR)
  Future<Either<Failure, SessionEntity>> createSession({
    required String restaurantId,
    required String tableId,
    required String customerId,
    required String customerName,
  });

  /// Join session as waiter (waiter scans QR)
  Future<Either<Failure, SessionEntity>> joinSessionAsWaiter({
    required String sessionId,
    required String waiterId,
    required String waiterName,
  });

  /// Get active session by table ID
  Future<Either<Failure, SessionEntity?>> getActiveSessionByTable(
    String tableId,
  );

  /// Get session by ID
  Future<Either<Failure, SessionEntity>> getSessionById(String sessionId);

  /// Get customer's active session
  Future<Either<Failure, SessionEntity?>> getCustomerActiveSession(
    String customerId,
  );

  /// Get waiter's active sessions
  Future<Either<Failure, List<SessionEntity>>> getWaiterActiveSessions(
    String waiterId,
  );

  /// Update session status
  Future<Either<Failure, void>> updateSessionStatus(
    String sessionId,
    SessionStatus status,
  );

  /// Add item to session
  Future<Either<Failure, void>> addItemToSession(
    String sessionId,
    OrderItem item,
  );

  /// Update session total
  Future<Either<Failure, void>> updateSessionTotal(
    String sessionId,
    double totalAmount,
  );

  /// Mark session as paid
  Future<Either<Failure, void>> markSessionAsPaid(String sessionId);

  /// Complete session
  Future<Either<Failure, void>> completeSession(String sessionId);

  /// Cancel session
  Future<Either<Failure, void>> cancelSession(String sessionId);

  /// Stream active session (real-time updates)
  Stream<Either<Failure, SessionEntity>> streamSession(String sessionId);

  ///Get sessions by customer ID
  Future<Either<Failure, List<SessionEntity>>> getUserSessions({
    required String customerId,
    int limit = 50,
  });
}
