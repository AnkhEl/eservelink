import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/sessions/domain/entities/table_entity.dart';
import 'package:eservelink/features/sessions/domain/repositories/table_repository.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';

class ScanQrAndCreateSessionUseCase
    implements UseCase<SessionEntity, ScanQrAndCreateSessionParams> {
  final TableRepository tableRepository;
  final SessionRepository sessionRepository;

  ScanQrAndCreateSessionUseCase({
    required this.tableRepository,
    required this.sessionRepository,
  });

  @override
  Future<Either<Failure, SessionEntity>> call(
    ScanQrAndCreateSessionParams params,
  ) async {
    // Step 1: Get table by id
    final tableResult = await tableRepository.getTableById(
      params.scannedQrCode,
    );

    return await tableResult.fold((failure) => Left(failure), (table) async {
      // Step 2: Check if table is available
      if (table.status == TableStatus.occupied) {
        // Check if there's an active session
        final activeSessionResult = await sessionRepository
            .getActiveSessionByTable(table.id);

        return await activeSessionResult.fold((failure) => Left(failure), (
          existingSession,
        ) async {
          if (existingSession != null) {
            // Table is occupied, return existing session or error
            if (existingSession.customerId == params.customerId) {
              // Same customer, return existing session
              return Right(existingSession);
            } else {
              // Different customer, table is occupied
              return const Left(
                SessionFailure('This table is currently occupied'),
              );
            }
          }

          // No active session but marked occupied, create new session
          return _createNewSession(table, params);
        });
      }

      // Table is available, create new session
      return _createNewSession(table, params);
    });
  }

  Future<Either<Failure, SessionEntity>> _createNewSession(
    TableEntity table,
    ScanQrAndCreateSessionParams params,
  ) async {
    final sessionResult = await sessionRepository.createSession(
      restaurantId: table.restaurantId,
      tableId: table.id,
      customerId: params.customerId,
      customerName: params.customerName,
    );

    // Update table status to occupied
    await tableRepository.updateTableStatus(table.id, TableStatus.occupied);

    return sessionResult;
  }
}

class ScanQrAndCreateSessionParams extends Equatable {
  final String scannedQrCode;
  final String customerId;
  final String customerName;

  const ScanQrAndCreateSessionParams({
    required this.scannedQrCode,
    required this.customerId,
    required this.customerName,
  });

  @override
  List<Object> get props => [scannedQrCode, customerId, customerName];
}
