import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';

class GetActiveSessionUseCase
    implements UseCase<SessionEntity?, GetActiveSessionParams> {
  final SessionRepository repository;

  GetActiveSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity?>> call(
    GetActiveSessionParams params,
  ) async {
    return await repository.getCustomerActiveSession(params.customerId);
  }
}

class GetActiveSessionParams extends Equatable {
  final String customerId;

  const GetActiveSessionParams({required this.customerId});

  @override
  List<Object> get props => [customerId];
}
