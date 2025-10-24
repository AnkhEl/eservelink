import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';
import 'package:eservelink/features/sessions/domain/repositories/table_repository.dart';

class JoinSessionAsWaiterUseCase
    implements UseCase<SessionEntity, JoinSessionAsWaiterParams> {
  final SessionRepository sessionRepository;
  final TableRepository tableRepository;

  JoinSessionAsWaiterUseCase({
    required this.sessionRepository,
    required this.tableRepository,
  });

  @override
  Future<Either<Failure, SessionEntity>> call(
    JoinSessionAsWaiterParams params,
  ) async {
    // Step 1: Get table by QR code
    final tableResult = await tableRepository.getTableById(params.tableId);

    return await tableResult.fold((failure) => Left(failure), (table) async {
      // Step 2: Get active session for this table
      final sessionResult = await sessionRepository.getActiveSessionByTable(
        table.id,
      );

      return await sessionResult.fold((failure) => Left(failure), (
        session,
      ) async {
        if (session == null) {
          return const Left(
            SessionFailure('No active session found for this table'),
          );
        }

        // Step 3: Join session as waiter
        return await sessionRepository.joinSessionAsWaiter(
          sessionId: session.id,
          waiterId: params.waiterId,
          waiterName: params.waiterName,
        );
      });
    });
  }
}

class JoinSessionAsWaiterParams extends Equatable {
  final String tableId;
  final String waiterId;
  final String waiterName;

  const JoinSessionAsWaiterParams({
    required this.tableId,
    required this.waiterId,
    required this.waiterName,
  });

  @override
  List<Object> get props => [tableId, waiterId, waiterName];
}
