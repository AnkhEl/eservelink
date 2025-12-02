import 'package:equatable/equatable.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';

/// Represents an item in the shopping cart (before submission)
class CartItemEntity extends Equatable {
  final MenuItemEntity menuItem;
  final int quantity;
  final String? specialInstructions;

  const CartItemEntity({
    required this.menuItem,
    required this.quantity,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [menuItem, quantity, specialInstructions];
}
