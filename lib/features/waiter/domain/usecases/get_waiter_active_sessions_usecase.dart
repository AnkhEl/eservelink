import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';
import 'package:eservelink/features/waiter/domain/repositories/waiter_repository.dart';

class GetWaiterActiveSessionsUseCase {
  final WaiterRepository repository;

  GetWaiterActiveSessionsUseCase(this.repository);

  Future<Either<Failure, List<WaiterSessionEntity>>> call(
      GetWaiterActiveSessionsParams params,
      ) async {
    return await repository.getWaiterActiveSessions(
      waiterId: params.waiterId,
    );
  }
}

class GetWaiterActiveSessionsParams {
  final String waiterId;

  GetWaiterActiveSessionsParams({required this.waiterId});
}