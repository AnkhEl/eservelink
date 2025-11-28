import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/menu/domain/entities/menu_category_entity.dart';

class MenuCategoryModel extends MenuCategoryEntity {
  const MenuCategoryModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    required super.description,
    required super.order,
    super.iconName,
    required super.createdAt,
  });

  factory MenuCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuCategoryModel(
      id: doc.id,
      restaurantId: data['restaurantId'] as String,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      order: data['order'] as int,
      iconName: data['iconName'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'order': order,
      'iconName': iconName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MenuCategoryEntity toEntity() {
    return MenuCategoryEntity(
      id: id,
      restaurantId: restaurantId,
      name: name,
      description: description,
      order: order,
      iconName: iconName,
      createdAt: createdAt,
    );
  }

  factory MenuCategoryModel.fromEntity(MenuCategoryEntity entity) {
    return MenuCategoryModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      name: entity.name,
      description: entity.description,
      order: entity.order,
      iconName: entity.iconName,
      createdAt: entity.createdAt,
    );
  }

  MenuCategoryModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    int? order,
    String? iconName,
    DateTime? createdAt,
  }) {
    return MenuCategoryModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
