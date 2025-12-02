import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class UpdateOrderStatusUseCase
    implements UseCase<void, UpdateOrderStatusParams> {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateOrderStatusParams params) {
    return repository.updateOrderStatus(
      orderSubmissionId: params.orderSubmissionId,
      status: params.status,
    );
  }
}

class UpdateOrderStatusParams extends Equatable {
  final String orderSubmissionId;
  final OrderSubmissionStatus status;

  const UpdateOrderStatusParams({
    required this.orderSubmissionId,
    required this.status,
  });

  @override
  List<Object> get props => [orderSubmissionId, status];
}
