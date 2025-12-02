import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class ConfirmOrderUseCase implements UseCase<void, ConfirmOrderParams> {
  final OrderRepository repository;

  ConfirmOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ConfirmOrderParams params) {
    return repository.confirmOrder(orderSubmissionId: params.orderSubmissionId);
  }
}

class ConfirmOrderParams extends Equatable {
  final String orderSubmissionId;

  const ConfirmOrderParams({required this.orderSubmissionId});

  @override
  List<Object> get props => [orderSubmissionId];
}
