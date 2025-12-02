import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class GetWaiterPendingOrdersUseCase
    implements
        UseCase<List<OrderSubmissionEntity>, GetWaiterPendingOrdersParams> {
  final OrderRepository repository;

  GetWaiterPendingOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderSubmissionEntity>>> call(
    GetWaiterPendingOrdersParams params,
  ) {
    return repository.getWaiterPendingOrders(waiterId: params.waiterId);
  }
}

class GetWaiterPendingOrdersParams extends Equatable {
  final String waiterId;

  const GetWaiterPendingOrdersParams({required this.waiterId});

  @override
  List<Object> get props => [waiterId];
}
