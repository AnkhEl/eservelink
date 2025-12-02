import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:eservelink/features/orders/data/models/cart_item_model.dart';
import 'package:eservelink/features/orders/domain/entities/cart_item_entity.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:eservelink/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OrderSubmissionEntity>> submitOrder({
    required String sessionId,
    required String customerId,
    required String customerName,
    required String waiterId,
    required String waiterName,
    required String restaurantId,
    required List<CartItemEntity> cartItems,
    String? notes,
  }) async {
    try {
      // Convert entities to models
      final cartItemModels =
          cartItems.map((item) => CartItemModel.fromEntity(item)).toList();

      final orderSubmission = await remoteDataSource.submitOrder(
        sessionId: sessionId,
        customerId: customerId,
        customerName: customerName,
        waiterId: waiterId,
        waiterName: waiterName,
        restaurantId: restaurantId,
        cartItems: cartItemModels,
        notes: notes,
      );

      return Right(orderSubmission.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderSubmissionEntity>>>
  getSessionOrderSubmissions({required String sessionId}) async {
    try {
      final orderSubmissions = await remoteDataSource
          .getSessionOrderSubmissions(sessionId: sessionId);

      return Right(orderSubmissions.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderSubmissionEntity>>> getWaiterPendingOrders({
    required String waiterId,
  }) async {
    try {
      final orderSubmissions = await remoteDataSource.getWaiterPendingOrders(
        waiterId: waiterId,
      );

      return Right(orderSubmissions.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<OrderSubmissionEntity>>>
  streamSessionOrderSubmissions({required String sessionId}) {
    try {
      return remoteDataSource
          .streamSessionOrderSubmissions(sessionId: sessionId)
          .map(
            (models) => Right<Failure, List<OrderSubmissionEntity>>(
              models.map((model) => model.toEntity()).toList(),
            ),
          )
          .handleError(
            (error) => Left<Failure, List<OrderSubmissionEntity>>(
              ServerFailure(error.toString()),
            ),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<OrderSubmissionEntity>>>
  streamWaiterPendingOrders({required String waiterId}) {
    try {
      return remoteDataSource
          .streamWaiterPendingOrders(waiterId: waiterId)
          .map(
            (models) => Right<Failure, List<OrderSubmissionEntity>>(
              models.map((model) => model.toEntity()).toList(),
            ),
          )
          .handleError(
            (error) => Left<Failure, List<OrderSubmissionEntity>>(
              ServerFailure(error.toString()),
            ),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderSubmissionId,
    required OrderSubmissionStatus status,
  }) async {
    try {
      await remoteDataSource.updateOrderStatus(
        orderSubmissionId: orderSubmissionId,
        status: status,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmOrder({
    required String orderSubmissionId,
  }) async {
    try {
      await remoteDataSource.confirmOrder(orderSubmissionId: orderSubmissionId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markOrderPreparing({
    required String orderSubmissionId,
  }) async {
    try {
      await remoteDataSource.markOrderPreparing(
        orderSubmissionId: orderSubmissionId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markOrderServed({
    required String orderSubmissionId,
  }) async {
    try {
      await remoteDataSource.markOrderServed(
        orderSubmissionId: orderSubmissionId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder({
    required String orderSubmissionId,
    required String reason,
  }) async {
    try {
      await remoteDataSource.cancelOrder(
        orderSubmissionId: orderSubmissionId,
        reason: reason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
