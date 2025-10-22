// lib/features/home/domain/repositories/review_repository.dart

import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/home/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  /// Get all reviews for a specific restaurant
  Future<Either<Failure, List<ReviewEntity>>> getRestaurantReviews(
    String restaurantId,
  );

  /// Get rating breakdown for a restaurant (returns map of star rating to count)
  Future<Either<Failure, Map<int, int>>> getRatingBreakdown(
    String restaurantId,
  );

  /// Get average rating for a restaurant
  Future<Either<Failure, double>> getAverageRating(String restaurantId);

  /// Create a new review
  Future<Either<Failure, void>> createReview(ReviewEntity review);

  /// Update an existing review
  Future<Either<Failure, void>> updateReview(ReviewEntity review);

  /// Delete a review
  Future<Either<Failure, void>> deleteReview(String reviewId);
}
