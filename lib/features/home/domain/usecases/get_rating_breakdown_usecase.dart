import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/home/domain/repositories/review_repository.dart';

class GetRatingBreakdownUseCase
    implements UseCase<Map<int, int>, GetRatingBreakdownParams> {
  final ReviewRepository repository;

  GetRatingBreakdownUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<int, int>>> call(
    GetRatingBreakdownParams params,
  ) async {
    return await repository.getRatingBreakdown(params.restaurantId);
  }
}

class GetRatingBreakdownParams extends Equatable {
  final String restaurantId;

  const GetRatingBreakdownParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}
