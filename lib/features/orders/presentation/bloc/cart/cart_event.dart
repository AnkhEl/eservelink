import 'package:equatable/equatable.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Add item to cart
class AddToCartEvent extends CartEvent {
  final MenuItemEntity menuItem;
  final String? specialInstructions;

  const AddToCartEvent({required this.menuItem, this.specialInstructions});

  @override
  List<Object?> get props => [menuItem, specialInstructions];
}

/// Remove item from cart
class RemoveFromCartEvent extends CartEvent {
  final String menuItemId;

  const RemoveFromCartEvent(this.menuItemId);

  @override
  List<Object> get props => [menuItemId];
}

/// Increment item quantity
class IncrementCartItemEvent extends CartEvent {
  final String menuItemId;

  const IncrementCartItemEvent(this.menuItemId);

  @override
  List<Object> get props => [menuItemId];
}

/// Decrement item quantity
class DecrementCartItemEvent extends CartEvent {
  final String menuItemId;

  const DecrementCartItemEvent(this.menuItemId);

  @override
  List<Object> get props => [menuItemId];
}

/// Update special instructions
class UpdateCartItemInstructionsEvent extends CartEvent {
  final String menuItemId;
  final String? specialInstructions;

  const UpdateCartItemInstructionsEvent({
    required this.menuItemId,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [menuItemId, specialInstructions];
}

/// Clear cart
class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

/// Load cart (for persistence later)
class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}
