import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class MarkOrderPreparingUseCase
    implements UseCase<void, MarkOrderPreparingParams> {
  final OrderRepository repository;

  MarkOrderPreparingUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkOrderPreparingParams params) {
    return repository.markOrderPreparing(
      orderSubmissionId: params.orderSubmissionId,
    );
  }
}

class MarkOrderPreparingParams extends Equatable {
  final String orderSubmissionId;

  const MarkOrderPreparingParams({required this.orderSubmissionId});

  @override
  List<Object> get props => [orderSubmissionId];
}
