import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class CancelOrderUseCase implements UseCase<void, CancelOrderParams> {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelOrderParams params) {
    return repository.cancelOrder(
      orderSubmissionId: params.orderSubmissionId,
      reason: params.reason,
    );
  }
}

class CancelOrderParams extends Equatable {
  final String orderSubmissionId;
  final String reason;

  const CancelOrderParams({
    required this.orderSubmissionId,
    required this.reason,
  });

  @override
  List<Object> get props => [orderSubmissionId, reason];
}
