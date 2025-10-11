import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/home/domain/entities/restaurant_entity.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, List<RestaurantEntity>>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  });

  Future<Either<Failure, RestaurantEntity>> getRestaurantById({
    required String restaurantId,
  });

  Future<Either<Failure, void>> addRestaurant({
    required RestaurantEntity restaurant,
  });
}
