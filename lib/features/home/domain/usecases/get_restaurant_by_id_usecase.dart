import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/home/domain/entities/restaurant_entity.dart';
import 'package:eservelink/features/home/domain/repositories/restaurant_repository.dart';

class GetRestaurantByIdUseCase
    implements UseCase<RestaurantEntity, GetRestaurantByIdParams> {
  final RestaurantRepository repository;

  GetRestaurantByIdUseCase({required this.repository});

  @override
  Future<Either<Failure, RestaurantEntity>> call(
    GetRestaurantByIdParams params,
  ) async {
    return await repository.getRestaurantById(
      restaurantId: params.restaurantId,
    );
  }
}

class GetRestaurantByIdParams extends Equatable {
  final String restaurantId;

  const GetRestaurantByIdParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}
