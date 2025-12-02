import 'package:equatable/equatable.dart';
import 'package:eservelink/features/orders/domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CartInitial extends CartState {
  const CartInitial();
}

/// Cart loaded with items
class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final double subtotal;
  final double tax;
  final double total;
  final int itemCount;

  const CartLoaded({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.itemCount,
  });

  @override
  List<Object> get props => [items, subtotal, tax, total, itemCount];
}

/// Cart is empty
class CartEmpty extends CartState {
  const CartEmpty();
}
