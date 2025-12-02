import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class GetSessionOrderSubmissionsUseCase
    implements
        UseCase<List<OrderSubmissionEntity>, GetSessionOrderSubmissionsParams> {
  final OrderRepository repository;

  GetSessionOrderSubmissionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderSubmissionEntity>>> call(
    GetSessionOrderSubmissionsParams params,
  ) {
    return repository.getSessionOrderSubmissions(sessionId: params.sessionId);
  }
}

class GetSessionOrderSubmissionsParams extends Equatable {
  final String sessionId;

  const GetSessionOrderSubmissionsParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
