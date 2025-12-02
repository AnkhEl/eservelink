import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class StreamWaiterPendingOrdersUseCase {
  final OrderRepository repository;

  StreamWaiterPendingOrdersUseCase(this.repository);

  Stream<Either<Failure, List<OrderSubmissionEntity>>> call(
    StreamWaiterPendingOrdersParams params,
  ) {
    return repository.streamWaiterPendingOrders(waiterId: params.waiterId);
  }
}

class StreamWaiterPendingOrdersParams extends Equatable {
  final String waiterId;

  const StreamWaiterPendingOrdersParams({required this.waiterId});

  @override
  List<Object> get props => [waiterId];
}
