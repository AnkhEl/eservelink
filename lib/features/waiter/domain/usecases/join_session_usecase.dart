import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';
import 'package:eservelink/features/waiter/domain/repositories/waiter_repository.dart';

class JoinSessionUseCase {
  final WaiterRepository repository;

  JoinSessionUseCase(this.repository);

  Future<Either<Failure, WaiterSessionEntity>> call(
      JoinSessionParams params,
      ) async {
    return await repository.joinSession(
      tableId: params.tableId,
      waiterId: params.waiterId,
      waiterName: params.waiterName,
    );
  }
}

class JoinSessionParams {
  final String tableId;
  final String waiterId;
  final String waiterName;

  JoinSessionParams({
    required this.tableId,
    required this.waiterId,
    required this.waiterName,
  });
}