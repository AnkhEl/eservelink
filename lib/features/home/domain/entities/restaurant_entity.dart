import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phoneNumber;
  final String email;
  final String imageUrl;
  final double rating;
  final List<String> categories;
  final String priceRange;
  final Map<String, dynamic> openingHours;
  final GeoPoint geolocation;
  final String geohash;
  final bool isActive;
  final DateTime createdAt;

  const RestaurantEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.imageUrl,
    required this.rating,
    required this.categories,
    required this.priceRange,
    required this.openingHours,
    required this.geolocation,
    required this.geohash,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    address,
    phoneNumber,
    email,
    imageUrl,
    rating,
    categories,
    priceRange,
    openingHours,
    geolocation,
    geohash,
    isActive,
    createdAt,
  ];
}
