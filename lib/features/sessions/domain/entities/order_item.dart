import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final double subtotal;
  final DateTime addedAt;
  final String? notes;

  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.addedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    quantity,
    price,
    subtotal,
    addedAt,
    notes,
  ];
}
