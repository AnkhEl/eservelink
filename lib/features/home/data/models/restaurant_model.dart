import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/home/domain/entities/restaurant_entity.dart';

class RestaurantModel extends RestaurantEntity {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.description,
    required super.address,
    required super.phoneNumber,
    required super.email,
    required super.imageUrl,
    required super.rating,
    required super.categories,
    required super.priceRange,
    required super.openingHours,
    required super.geolocation,
    required super.geohash,
    required super.isActive,
    required super.createdAt,
    required super.restaurantAdminId,
  });

  /// Convert Firestore document to RestaurantModel
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final position = data['position'] as Map<String, dynamic>?;

    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      categories: List<String>.from(data['categories'] ?? []),
      priceRange: data['priceRange'] ?? '',
      openingHours: Map<String, dynamic>.from(data['openingHours'] ?? {}),
      geolocation: position?['geopoint'] as GeoPoint, // 👈 updated
      geohash: position?['geohash'] ?? '', // 👈 updated
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      restaurantAdminId: data['restaurant_admin_id'] ?? '',
    );
  }

  /// Convert RestaurantModel to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'imageUrl': imageUrl,
      'rating': rating,
      'categories': categories,
      'priceRange': priceRange,
      'openingHours': openingHours,
      'position': {'geopoint': geolocation, 'geohash': geohash},
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'restaurant_admin_id': restaurantAdminId,
    };
  }

  /// Convert RestaurantEntity to RestaurantModel
  factory RestaurantModel.fromEntity(RestaurantEntity entity) {
    return RestaurantModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      address: entity.address,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      imageUrl: entity.imageUrl,
      rating: entity.rating,
      categories: entity.categories,
      priceRange: entity.priceRange,
      openingHours: entity.openingHours,
      geolocation: entity.geolocation,
      geohash: entity.geohash,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      restaurantAdminId: entity.restaurantAdminId,
    );
  }
}
