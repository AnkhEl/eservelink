import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class StreamSessionOrderSubmissionsUseCase {
  final OrderRepository repository;

  StreamSessionOrderSubmissionsUseCase(this.repository);

  Stream<Either<Failure, List<OrderSubmissionEntity>>> call(
    StreamSessionOrderSubmissionsParams params,
  ) {
    return repository.streamSessionOrderSubmissions(
      sessionId: params.sessionId,
    );
  }
}

class StreamSessionOrderSubmissionsParams extends Equatable {
  final String sessionId;

  const StreamSessionOrderSubmissionsParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
