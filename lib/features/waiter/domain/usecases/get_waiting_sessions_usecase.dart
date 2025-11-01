import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';
import 'package:eservelink/features/waiter/domain/repositories/waiter_repository.dart';

class GetWaitingSessionsUseCase {
  final WaiterRepository repository;

  GetWaitingSessionsUseCase(this.repository);

  Future<Either<Failure, List<WaiterSessionEntity>>> call(
      GetWaitingSessionsParams params,
      ) async {
    return await repository.getWaitingSessions(
      restaurantId: params.restaurantId,
    );
  }
}

class GetWaitingSessionsParams {
  final String restaurantId;

  GetWaitingSessionsParams({required this.restaurantId});
}
