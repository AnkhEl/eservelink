import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/home/data/datasources/review_remote_data_source.dart';
import 'package:eservelink/features/home/data/models/review_model.dart';
import 'package:eservelink/features/home/domain/entities/review_entity.dart';
import 'package:eservelink/features/home/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReviewEntity>>> getRestaurantReviews(
    String restaurantId,
  ) async {
    try {
      final reviews = await remoteDataSource.getRestaurantReviews(restaurantId);

      if (reviews.isEmpty) {
        return Left(NoReviewsFoundFailure());
      }

      return Right(reviews);
    } catch (e) {
      return Left(ReviewFetchFailure('Failed to get restaurant reviews: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<int, int>>> getRatingBreakdown(
    String restaurantId,
  ) async {
    try {
      final reviews = await remoteDataSource.getRestaurantReviews(restaurantId);

      if (reviews.isEmpty) {
        return Left(NoReviewsFoundFailure());
      }

      final breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var review in reviews) {
        final ratingKey = review.rating.round().clamp(1, 5);
        breakdown[ratingKey] = (breakdown[ratingKey] ?? 0) + 1;
      }

      return Right(breakdown);
    } catch (e) {
      return Left(ReviewFetchFailure('Failed to get rating breakdown: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageRating(String restaurantId) async {
    try {
      final reviews = await remoteDataSource.getRestaurantReviews(restaurantId);

      if (reviews.isEmpty) {
        return Left(NoReviewsFoundFailure());
      }

      final sum = reviews.fold(0.0, (sum, review) => sum + review.rating);
      final average = sum / reviews.length;

      return Right(average);
    } catch (e) {
      return Left(ReviewFetchFailure('Failed to get average rating: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createReview(ReviewEntity review) async {
    try {
      final reviewModel = ReviewModel.fromEntity(review);
      await remoteDataSource.createReview(reviewModel);
      return const Right(null);
    } catch (e) {
      return Left(ReviewCreateFailure('Failed to create review: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReview(ReviewEntity review) async {
    try {
      final reviewModel = ReviewModel.fromEntity(review);
      await remoteDataSource.updateReview(reviewModel);
      return const Right(null);
    } catch (e) {
      return Left(ReviewUpdateFailure('Failed to update review: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      await remoteDataSource.deleteReview(reviewId);
      return const Right(null);
    } catch (e) {
      return Left(ReviewDeleteFailure('Failed to delete review: $e'));
    }
  }
}
