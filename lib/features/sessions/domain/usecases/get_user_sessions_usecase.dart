import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';

class GetUserSessionsUseCase
    implements UseCase<List<SessionEntity>, GetUserSessionsParams> {
  final SessionRepository repository;

  GetUserSessionsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<SessionEntity>>> call(
    GetUserSessionsParams params,
  ) async {
    return await repository.getUserSessions(
      customerId: params.customerId,
      limit: params.limit,
    );
  }
}

class GetUserSessionsParams extends Equatable {
  final String customerId;
  final int limit;

  const GetUserSessionsParams({required this.customerId, this.limit = 50});

  @override
  List<Object> get props => [customerId, limit];
}
