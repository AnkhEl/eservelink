import 'dart:math' as math;
import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/home/domain/entities/restaurant_entity.dart';
import 'package:eservelink/features/home/domain/repositories/restaurant_repository.dart';
import 'package:eservelink/features/home/data/datasources/restaurant_remote_data_source.dart';
import 'package:eservelink/features/home/data/models/restaurant_model.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RestaurantEntity>>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      final restaurants = await remoteDataSource.getNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
      );

      // Sort restaurants by distance from user location
      restaurants.sort((a, b) {
        final distA = _calculateDistance(
          latitude,
          longitude,
          a.geolocation.latitude,
          a.geolocation.longitude,
        );
        final distB = _calculateDistance(
          latitude,
          longitude,
          b.geolocation.latitude,
          b.geolocation.longitude,
        );
        return distA.compareTo(distB);
      });

      return Right(restaurants);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RestaurantEntity>> getRestaurantById({
    required String restaurantId,
  }) async {
    try {
      final restaurant = await remoteDataSource.getRestaurantById(
        restaurantId: restaurantId,
      );
      return Right(restaurant);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addRestaurant({
    required RestaurantEntity restaurant,
    required String restaurantAdminId,
  }) async {
    try {
      final restaurantModel = RestaurantModel.fromEntity(restaurant);
      await remoteDataSource.addRestaurant(
        restaurant: restaurantModel,
        restaurantAdminId: restaurantAdminId,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // Radius of the earth in km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);

    final double a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
