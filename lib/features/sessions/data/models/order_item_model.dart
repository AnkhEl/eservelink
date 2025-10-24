import 'package:eservelink/features/sessions/domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.name,
    required super.quantity,
    required super.price,
    required super.subtotal,
    required super.addedAt,
    super.notes,
  });

  // ✅ CORRECT - Factory with calculation logic in MODEL
  factory OrderItemModel.create({
    required String id,
    required String name,
    required int quantity,
    required double price,
    String? notes,
  }) {
    return OrderItemModel(
      id: id,
      name: name,
      quantity: quantity,
      price: price,
      subtotal: quantity * price, // ← Business logic in MODEL
      addedAt: DateTime.now(),
      notes: notes,
    );
  }

  // Convert from Map (Firestore)
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      addedAt: DateTime.parse(
        map['addedAt'] ?? DateTime.now().toIso8601String(),
      ),
      notes: map['notes'],
    );
  }

  // Convert to Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'addedAt': addedAt.toIso8601String(),
      'notes': notes,
    };
  }

  // Convert from entity
  factory OrderItemModel.fromEntity(OrderItem entity) {
    return OrderItemModel(
      id: entity.id,
      name: entity.name,
      quantity: entity.quantity,
      price: entity.price,
      subtotal: entity.subtotal,
      addedAt: entity.addedAt,
      notes: entity.notes,
    );
  }

  // ✅ Business logic methods in MODEL
  OrderItemModel updateQuantity(int newQuantity) {
    return OrderItemModel(
      id: id,
      name: name,
      quantity: newQuantity,
      price: price,
      subtotal: newQuantity * price, // Recalculate
      addedAt: addedAt,
      notes: notes,
    );
  }

  OrderItemModel addQuantity(int amount) {
    return updateQuantity(quantity + amount);
  }
}
