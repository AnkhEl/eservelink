import 'package:equatable/equatable.dart';

class MenuCategoryEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final int order; // Display order
  final String? iconName; // e.g., "restaurant", "local_bar"
  final DateTime createdAt;

  const MenuCategoryEntity({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.order,
    this.iconName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    name,
    description,
    order,
    iconName,
    createdAt,
  ];
}
