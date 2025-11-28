import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final List<String> dietaryInfo; // e.g., ["Vegetarian", "Gluten-Free"]
  final int preparationTime; // in minutes
  final DateTime createdAt;

  const MenuItemEntity({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.dietaryInfo = const [],
    this.preparationTime = 15,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    name,
    description,
    price,
    category,
    imageUrl,
    isAvailable,
    dietaryInfo,
    preparationTime,
    createdAt,
  ];
}
