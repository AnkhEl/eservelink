import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/waiter/domain/repositories/waiter_repository.dart';

class EndSessionUseCase {
  final WaiterRepository repository;

  EndSessionUseCase(this.repository);

  Future<Either<Failure, void>> call(EndSessionParams params) async {
    return await repository.endSession(sessionId: params.sessionId);
  }
}

class EndSessionParams {
  final String sessionId;

  EndSessionParams({required this.sessionId});
}