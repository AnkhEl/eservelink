import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/home/domain/repositories/review_repository.dart';

class GetAverageRatingUseCase
    implements UseCase<double, GetAverageRatingParams> {
  final ReviewRepository repository;

  GetAverageRatingUseCase({required this.repository});

  @override
  Future<Either<Failure, double>> call(GetAverageRatingParams params) async {
    return await repository.getAverageRating(params.restaurantId);
  }
}

class GetAverageRatingParams extends Equatable {
  final String restaurantId;

  const GetAverageRatingParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}
