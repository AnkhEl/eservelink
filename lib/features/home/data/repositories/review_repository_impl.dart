import 'package:eservelink/features/home/data/datasources/review_remote_data_source.dart';
import 'package:eservelink/features/home/data/models/review_model.dart';
import 'package:eservelink/features/home/domain/entities/review_entity.dart';
import 'package:eservelink/features/home/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ReviewEntity>> getRestaurantReviews(String restaurantId) async {
    try {
      final reviews = await remoteDataSource.getRestaurantReviews(restaurantId);
      return reviews;
    } catch (e) {
      throw Exception('Failed to get restaurant reviews: $e');
    }
  }

  @override
  Future<Map<int, int>> getRatingBreakdown(String restaurantId) async {
    try {
      final reviews = await remoteDataSource.getRestaurantReviews(restaurantId);
      final breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var review in reviews) {
        final ratingKey = review.rating.round();
        breakdown[ratingKey] = (breakdown[ratingKey] ?? 0) + 1;
      }

      return breakdown;
    } catch (e) {
      throw Exception('Failed to get rating breakdown: $e');
    }
  }

  @override
  Future<double> getAverageRating(String restaurantId) async {
    try {
      final reviews = await remoteDataSource.getRestaurantReviews(restaurantId);

      if (reviews.isEmpty) return 0.0;

      final sum = reviews.fold(0.0, (sum, review) => sum + review.rating);
      return sum / reviews.length;
    } catch (e) {
      throw Exception('Failed to get average rating: $e');
    }
  }

  @override
  Future<void> createReview(ReviewEntity review) async {
    try {
      final reviewModel = ReviewModel.fromEntity(review);
      await remoteDataSource.createReview(reviewModel);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  @override
  Future<void> updateReview(ReviewEntity review) async {
    try {
      final reviewModel = ReviewModel.fromEntity(review);
      await remoteDataSource.updateReview(reviewModel);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await remoteDataSource.deleteReview(reviewId);
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
