import 'package:equatable/equatable.dart';
import 'package:eservelink/features/home/domain/entities/restaurant_entity.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object> get props => [];
}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantNearbyLoaded extends RestaurantState {
  final List<RestaurantEntity> restaurants;
  final double userLatitude;
  final double userLongitude;

  const RestaurantNearbyLoaded({
    required this.restaurants,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  List<Object> get props => [restaurants, userLatitude, userLongitude];
}

class RestaurantDetailLoaded extends RestaurantState {
  final RestaurantEntity restaurant;

  const RestaurantDetailLoaded({required this.restaurant});

  @override
  List<Object> get props => [restaurant];
}

class RestaurantError extends RestaurantState {
  final String message;

  const RestaurantError({required this.message});

  @override
  List<Object> get props => [message];
}
