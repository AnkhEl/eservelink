import 'dart:async';
import 'package:eservelink/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:eservelink/features/orders/domain/usecases/confirm_order_usecase.dart';
import 'package:eservelink/features/orders/domain/usecases/mark_order_preparing_usecase.dart';
import 'package:eservelink/features/orders/domain/usecases/mark_order_served_usecase.dart';
import 'package:eservelink/features/orders/domain/usecases/stream_session_order_submissions_usecase.dart';
import 'package:eservelink/features/orders/domain/usecases/stream_waiter_pending_orders_usecase.dart';
import 'package:eservelink/features/orders/domain/usecases/submit_order_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/orders/presentation/bloc/order/order_event.dart';
import 'package:eservelink/features/orders/presentation/bloc/order/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final SubmitOrderUseCase submitOrder;
  final StreamSessionOrderSubmissionsUseCase streamSessionOrders;
  final StreamWaiterPendingOrdersUseCase streamWaiterOrders;
  final ConfirmOrderUseCase confirmOrder;
  final MarkOrderPreparingUseCase markOrderPreparing;
  final MarkOrderServedUseCase markOrderServed;
  final CancelOrderUseCase cancelOrder;

  StreamSubscription? _ordersSubscription;

  OrderBloc({
    required this.submitOrder,
    required this.streamSessionOrders,
    required this.streamWaiterOrders,
    required this.confirmOrder,
    required this.markOrderPreparing,
    required this.markOrderServed,
    required this.cancelOrder,
  }) : super(const OrderInitial()) {
    on<SubmitOrderEvent>(_onSubmitOrder);
    on<StartWatchingSessionOrdersEvent>(_onStartWatchingSessionOrders);
    on<StartWatchingWaiterOrdersEvent>(_onStartWatchingWaiterOrders);
    on<StopWatchingOrdersEvent>(_onStopWatchingOrders);
    on<OrdersUpdatedEvent>(_onOrdersUpdated);
    on<ConfirmOrderEvent>(_onConfirmOrder);
    on<MarkOrderPreparingEvent>(_onMarkOrderPreparing);
    on<MarkOrderServedEvent>(_onMarkOrderServed);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onSubmitOrder(
    SubmitOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('📦 Submitting order...');
    emit(const OrderLoading());

    final result = await submitOrder(
      SubmitOrderParams(
        sessionId: event.sessionId,
        customerId: event.customerId,
        customerName: event.customerName,
        waiterId: event.waiterId,
        waiterName: event.waiterName,
        restaurantId: event.restaurantId,
        cartItems: event.cartItems,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) {
        print('❌ Failed to submit order: ${failure.message}');
        emit(OrderError(failure.message));
      },
      (order) {
        print('✅ Order submitted successfully: ${order.id}');
        emit(OrderSubmitted(order));
      },
    );
  }

  Future<void> _onStartWatchingSessionOrders(
    StartWatchingSessionOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('👀 Starting to watch session orders: ${event.sessionId}');

    await _ordersSubscription?.cancel();

    _ordersSubscription = streamSessionOrders(
      StreamSessionOrderSubmissionsParams(sessionId: event.sessionId),
    ).listen(
      (result) {
        result.fold(
          (failure) {
            print('❌ Stream error: ${failure.message}');
            add(const OrdersUpdatedEvent([]));
          },
          (orders) {
            print('✅ Orders updated: ${orders.length}');
            add(OrdersUpdatedEvent(orders));
          },
        );
      },
      onError: (error) {
        print('❌ Stream error: $error');
        add(const OrdersUpdatedEvent([]));
      },
    );
  }

  Future<void> _onStartWatchingWaiterOrders(
    StartWatchingWaiterOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('👀 Starting to watch waiter orders: ${event.waiterId}');

    await _ordersSubscription?.cancel();

    _ordersSubscription = streamWaiterOrders(
      StreamWaiterPendingOrdersParams(waiterId: event.waiterId),
    ).listen(
      (result) {
        result.fold(
          (failure) {
            print('❌ Stream error: ${failure.message}');
            add(const OrdersUpdatedEvent([]));
          },
          (orders) {
            print('✅ Waiter orders updated: ${orders.length}');
            add(OrdersUpdatedEvent(orders));
          },
        );
      },
      onError: (error) {
        print('❌ Stream error: $error');
        add(const OrdersUpdatedEvent([]));
      },
    );
  }

  FutureOr<void> _onStopWatchingOrders(
    StopWatchingOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('⏹️ Stopping order watchers...');
    await _ordersSubscription?.cancel();
    _ordersSubscription = null;
  }

  FutureOr<void> _onOrdersUpdated(
    OrdersUpdatedEvent event,
    Emitter<OrderState> emit,
  ) {
    emit(OrdersLoaded(event.orders.cast()));
  }

  Future<void> _onConfirmOrder(
    ConfirmOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('✅ Confirming order: ${event.orderSubmissionId}');

    final result = await confirmOrder(
      ConfirmOrderParams(orderSubmissionId: event.orderSubmissionId),
    );

    result.fold(
      (failure) {
        print('❌ Failed to confirm order: ${failure.message}');
        emit(OrderError(failure.message));
      },
      (_) {
        print('✅ Order confirmed');
        emit(const OrderStatusUpdated('Order confirmed'));
      },
    );
  }

  Future<void> _onMarkOrderPreparing(
    MarkOrderPreparingEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('🍳 Marking order as preparing: ${event.orderSubmissionId}');

    final result = await markOrderPreparing(
      MarkOrderPreparingParams(orderSubmissionId: event.orderSubmissionId),
    );

    result.fold(
      (failure) {
        print('❌ Failed to mark order as preparing: ${failure.message}');
        emit(OrderError(failure.message));
      },
      (_) {
        print('✅ Order marked as preparing');
        emit(const OrderStatusUpdated('Order is being prepared'));
      },
    );
  }

  Future<void> _onMarkOrderServed(
    MarkOrderServedEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('🍽️ Marking order as served: ${event.orderSubmissionId}');

    final result = await markOrderServed(
      MarkOrderServedParams(orderSubmissionId: event.orderSubmissionId),
    );

    result.fold(
      (failure) {
        print('❌ Failed to mark order as served: ${failure.message}');
        emit(OrderError(failure.message));
      },
      (_) {
        print('✅ Order marked as served');
        emit(const OrderStatusUpdated('Order served'));
      },
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('❌ Cancelling order: ${event.orderSubmissionId}');

    final result = await cancelOrder(
      CancelOrderParams(
        orderSubmissionId: event.orderSubmissionId,
        reason: event.reason,
      ),
    );

    result.fold(
      (failure) {
        print('❌ Failed to cancel order: ${failure.message}');
        emit(OrderError(failure.message));
      },
      (_) {
        print('✅ Order cancelled');
        emit(const OrderStatusUpdated('Order cancelled'));
      },
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
