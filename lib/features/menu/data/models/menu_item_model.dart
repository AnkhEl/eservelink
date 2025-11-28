import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    super.imageUrl,
    super.isAvailable,
    super.dietaryInfo,
    super.preparationTime,
    required super.createdAt,
  });

  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItemModel(
      id: doc.id,
      restaurantId: data['restaurantId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      category: data['category'] as String,
      imageUrl: data['imageUrl'] as String?,
      isAvailable: data['isAvailable'] as bool? ?? true,
      dietaryInfo:
          (data['dietaryInfo'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      preparationTime: data['preparationTime'] as int? ?? 15,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'dietaryInfo': dietaryInfo,
      'preparationTime': preparationTime,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      restaurantId: restaurantId,
      name: name,
      description: description,
      price: price,
      category: category,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      dietaryInfo: dietaryInfo,
      preparationTime: preparationTime,
      createdAt: createdAt,
    );
  }

  factory MenuItemModel.fromEntity(MenuItemEntity entity) {
    return MenuItemModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      category: entity.category,
      imageUrl: entity.imageUrl,
      isAvailable: entity.isAvailable,
      dietaryInfo: entity.dietaryInfo,
      preparationTime: entity.preparationTime,
      createdAt: entity.createdAt,
    );
  }

  MenuItemModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    List<String>? dietaryInfo,
    int? preparationTime,
    DateTime? createdAt,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      preparationTime: preparationTime ?? this.preparationTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
