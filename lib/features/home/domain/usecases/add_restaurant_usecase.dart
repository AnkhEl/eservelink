import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/home/domain/entities/restaurant_entity.dart';
import 'package:eservelink/features/home/domain/repositories/restaurant_repository.dart';

class AddRestaurantUseCase implements UseCase<void, AddRestaurantParams> {
  final RestaurantRepository repository;

  AddRestaurantUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(AddRestaurantParams params) async {
    return await repository.addRestaurant(restaurant: params.restaurant);
  }
}

class AddRestaurantParams extends Equatable {
  final RestaurantEntity restaurant;

  const AddRestaurantParams({required this.restaurant});

  @override
  List<Object> get props => [restaurant];
}
