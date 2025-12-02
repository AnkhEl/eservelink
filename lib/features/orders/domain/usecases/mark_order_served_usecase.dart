import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class MarkOrderServedUseCase implements UseCase<void, MarkOrderServedParams> {
  final OrderRepository repository;

  MarkOrderServedUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkOrderServedParams params) {
    return repository.markOrderServed(
      orderSubmissionId: params.orderSubmissionId,
    );
  }
}

class MarkOrderServedParams extends Equatable {
  final String orderSubmissionId;

  const MarkOrderServedParams({required this.orderSubmissionId});

  @override
  List<Object> get props => [orderSubmissionId];
}
