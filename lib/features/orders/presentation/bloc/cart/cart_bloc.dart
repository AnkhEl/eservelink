import 'dart:async';
import 'package:eservelink/features/orders/presentation/bloc/cart/cart_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/orders/data/models/cart_item_model.dart';
import 'package:eservelink/features/orders/domain/entities/cart_item_entity.dart';
import 'package:eservelink/features/orders/presentation/bloc/cart/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  // In-memory cart storage (can be replaced with persistent storage later)
  List<CartItemModel> _cartItems = [];

  CartBloc() : super(const CartInitial()) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<IncrementCartItemEvent>(_onIncrementCartItem);
    on<DecrementCartItemEvent>(_onDecrementCartItem);
    on<UpdateCartItemInstructionsEvent>(_onUpdateCartItemInstructions);
    on<ClearCartEvent>(_onClearCart);
    on<LoadCartEvent>(_onLoadCart);
  }

  FutureOr<void> _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) {
    print('🛒 Adding to cart: ${event.menuItem.name}');

    // Check if item already exists in cart
    final existingIndex = _cartItems.indexWhere(
      (item) => item.menuItem.id == event.menuItem.id,
    );

    if (existingIndex >= 0) {
      // Item exists, increment quantity
      _cartItems[existingIndex] = _cartItems[existingIndex].increment();
      print(
        '✅ Incremented existing item to quantity: ${_cartItems[existingIndex].quantity}',
      );
    } else {
      // Add new item
      _cartItems.add(
        CartItemModel(
          menuItem: event.menuItem,
          quantity: 1,
          specialInstructions: event.specialInstructions,
        ),
      );
      print('✅ Added new item to cart');
    }

    _emitCartLoaded(emit);
  }

  FutureOr<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) {
    print('🗑️ Removing from cart: ${event.menuItemId}');

    _cartItems.removeWhere((item) => item.menuItem.id == event.menuItemId);

    if (_cartItems.isEmpty) {
      emit(const CartEmpty());
    } else {
      _emitCartLoaded(emit);
    }
  }

  FutureOr<void> _onIncrementCartItem(
    IncrementCartItemEvent event,
    Emitter<CartState> emit,
  ) {
    print('➕ Incrementing cart item: ${event.menuItemId}');

    final index = _cartItems.indexWhere(
      (item) => item.menuItem.id == event.menuItemId,
    );

    if (index >= 0) {
      _cartItems[index] = _cartItems[index].increment();
      _emitCartLoaded(emit);
    }
  }

  FutureOr<void> _onDecrementCartItem(
    DecrementCartItemEvent event,
    Emitter<CartState> emit,
  ) {
    print('➖ Decrementing cart item: ${event.menuItemId}');

    final index = _cartItems.indexWhere(
      (item) => item.menuItem.id == event.menuItemId,
    );

    if (index >= 0) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index] = _cartItems[index].decrement();
        _emitCartLoaded(emit);
      } else {
        // Remove item if quantity would be 0
        add(RemoveFromCartEvent(event.menuItemId));
      }
    }
  }

  FutureOr<void> _onUpdateCartItemInstructions(
    UpdateCartItemInstructionsEvent event,
    Emitter<CartState> emit,
  ) {
    print('📝 Updating instructions for: ${event.menuItemId}');

    final index = _cartItems.indexWhere(
      (item) => item.menuItem.id == event.menuItemId,
    );

    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(
        specialInstructions: event.specialInstructions,
      );
      _emitCartLoaded(emit);
    }
  }

  FutureOr<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    print('🧹 Clearing cart');
    _cartItems.clear();
    emit(const CartEmpty());
  }

  FutureOr<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) {
    if (_cartItems.isEmpty) {
      emit(const CartEmpty());
    } else {
      _emitCartLoaded(emit);
    }
  }

  void _emitCartLoaded(Emitter<CartState> emit) {
    // Calculate totals using model's business logic
    final subtotal = _cartItems.fold<double>(
      0,
      (sum, item) => sum + item.calculateTotal(),
    );
    final tax = subtotal * 0.15; // 15% tax
    final total = subtotal + tax;
    final itemCount = _cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    emit(
      CartLoaded(
        items: _cartItems.map((model) => model.toEntity()).toList(),
        subtotal: subtotal,
        tax: tax,
        total: total,
        itemCount: itemCount,
      ),
    );
  }

  /// Helper to get current cart items as entities
  List<CartItemEntity> getCartItems() {
    return _cartItems.map((model) => model.toEntity()).toList();
  }
}
