import 'package:eservelink/features/home/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  /// Get all reviews for a specific restaurant
  Future<List<ReviewEntity>> getRestaurantReviews(String restaurantId);

  /// Get rating breakdown for a restaurant
  Future<Map<int, int>> getRatingBreakdown(String restaurantId);

  /// Get average rating for a restaurant
  Future<double> getAverageRating(String restaurantId);

  /// Create a new review (for future implementation)
  Future<void> createReview(ReviewEntity review);

  /// Update an existing review (for future implementation)
  Future<void> updateReview(ReviewEntity review);

  /// Delete a review (for future implementation)
  Future<void> deleteReview(String reviewId);
}
