import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/orders/domain/entities/cart_item_entity.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class SubmitOrderUseCase
    implements UseCase<OrderSubmissionEntity, SubmitOrderParams> {
  final OrderRepository repository;

  SubmitOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderSubmissionEntity>> call(
    SubmitOrderParams params,
  ) {
    return repository.submitOrder(
      sessionId: params.sessionId,
      customerId: params.customerId,
      customerName: params.customerName,
      waiterId: params.waiterId,
      waiterName: params.waiterName,
      restaurantId: params.restaurantId,
      cartItems: params.cartItems,
      notes: params.notes,
    );
  }
}

class SubmitOrderParams extends Equatable {
  final String sessionId;
  final String customerId;
  final String customerName;
  final String waiterId;
  final String waiterName;
  final String restaurantId;
  final List<CartItemEntity> cartItems;
  final String? notes;

  const SubmitOrderParams({
    required this.sessionId,
    required this.customerId,
    required this.customerName,
    required this.waiterId,
    required this.waiterName,
    required this.restaurantId,
    required this.cartItems,
    this.notes,
  });

  @override
  List<Object?> get props => [
    sessionId,
    customerId,
    customerName,
    waiterId,
    waiterName,
    restaurantId,
    cartItems,
    notes,
  ];
}
