import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/home/domain/entities/restaurant_entity.dart';
import 'package:eservelink/features/home/domain/repositories/restaurant_repository.dart';

class GetNearbyRestaurantsUseCase
    implements UseCase<List<RestaurantEntity>, GetNearbyRestaurantsParams> {
  final RestaurantRepository repository;

  GetNearbyRestaurantsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<RestaurantEntity>>> call(
    GetNearbyRestaurantsParams params,
  ) async {
    return await repository.getNearbyRestaurants(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusInKm: params.radiusInKm,
    );
  }
}

class GetNearbyRestaurantsParams extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const GetNearbyRestaurantsParams({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
  });

  @override
  List<Object> get props => [latitude, longitude, radiusInKm];
}
