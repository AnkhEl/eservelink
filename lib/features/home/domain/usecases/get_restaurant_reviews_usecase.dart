import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/home/domain/entities/review_entity.dart';
import 'package:eservelink/features/home/domain/repositories/review_repository.dart';

class GetRestaurantReviewsUseCase
    implements UseCase<List<ReviewEntity>, GetRestaurantReviewsParams> {
  final ReviewRepository repository;

  GetRestaurantReviewsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ReviewEntity>>> call(
    GetRestaurantReviewsParams params,
  ) async {
    return await repository.getRestaurantReviews(params.restaurantId);
  }
}

class GetRestaurantReviewsParams extends Equatable {
  final String restaurantId;

  const GetRestaurantReviewsParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}
