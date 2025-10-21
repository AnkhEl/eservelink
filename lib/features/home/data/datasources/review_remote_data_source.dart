import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/home/data/models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getRestaurantReviews(String restaurantId);
  Future<void> createReview(ReviewModel review);
  Future<void> updateReview(ReviewModel review);
  Future<void> deleteReview(String reviewId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseFirestore firestore;

  ReviewRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ReviewModel>> getRestaurantReviews(String restaurantId) async {
    try {
      final querySnapshot =
          await firestore
              .collection('reviews')
              .where('restaurantId', isEqualTo: restaurantId)
              .where('type', isEqualTo: 'restaurant')
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  @override
  Future<void> createReview(ReviewModel review) async {
    try {
      await firestore.collection('reviews').add(review.toFirestore());
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    try {
      await firestore
          .collection('reviews')
          .doc(review.id)
          .update(review.toFirestore());
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
