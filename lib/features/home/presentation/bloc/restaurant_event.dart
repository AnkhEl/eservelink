import 'package:equatable/equatable.dart';

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
