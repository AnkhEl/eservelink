import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';
import 'package:eservelink/features/orders/domain/entities/cart_item_entity.dart';
import 'package:eservelink/features/sessions/domain/entities/order_item.dart';
import 'package:eservelink/features/sessions/data/models/order_item_model.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.menuItem,
    required super.quantity,
    super.specialInstructions,
  });

  /// Calculate total for this cart item
  double calculateTotal() {
    return menuItem.price * quantity;
  }

  /// Increment quantity
  CartItemModel increment() {
    return CartItemModel(
      menuItem: menuItem,
      quantity: quantity + 1,
      specialInstructions: specialInstructions,
    );
  }

  /// Decrement quantity (minimum 1)
  CartItemModel decrement() {
    if (quantity <= 1) return this;
    return CartItemModel(
      menuItem: menuItem,
      quantity: quantity - 1,
      specialInstructions: specialInstructions,
    );
  }

  /// Convert to OrderItem (for session submission)
  OrderItem toOrderItem() {
    return OrderItemModel.create(
      id: menuItem.id,
      name: menuItem.name,
      quantity: quantity,
      price: menuItem.price,
      notes: specialInstructions,
    );
  }

  /// Convert to entity
  CartItemEntity toEntity() {
    return CartItemEntity(
      menuItem: menuItem,
      quantity: quantity,
      specialInstructions: specialInstructions,
    );
  }

  /// Create from entity
  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      menuItem: entity.menuItem,
      quantity: entity.quantity,
      specialInstructions: entity.specialInstructions,
    );
  }

  /// CopyWith
  CartItemModel copyWith({
    MenuItemEntity? menuItem,
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItemModel(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}
