import 'package:equatable/equatable.dart';
import 'package:eservelink/features/home/domain/entities/restaurant_entity.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object> get props => [];
}

class LoadNearbyRestaurantsEvent extends RestaurantEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const LoadNearbyRestaurantsEvent({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
  });

  @override
  List<Object> get props => [latitude, longitude, radiusInKm];
}

class LoadRestaurantByIdEvent extends RestaurantEvent {
  final String restaurantId;

  const LoadRestaurantByIdEvent({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}

class RefreshRestaurantsEvent extends RestaurantEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const RefreshRestaurantsEvent({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
  });

  @override
  List<Object> get props => [latitude, longitude, radiusInKm];
}

class NavigateToRestaurantDetailEvent extends RestaurantEvent {
  final RestaurantEntity restaurant;
  final double distance;
  final double userLatitude;
  final double userLongitude;

  const NavigateToRestaurantDetailEvent({
    required this.restaurant,
    required this.distance,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  List<Object> get props => [restaurant, distance, userLatitude, userLongitude];
}

class NavigateBackToRestaurantListEvent extends RestaurantEvent {
  const NavigateBackToRestaurantListEvent();
}
