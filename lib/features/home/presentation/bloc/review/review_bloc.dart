import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/home/domain/usecases/get_restaurant_reviews_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_average_rating_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_rating_breakdown_usecase.dart';
import 'package:eservelink/features/home/presentation/bloc/review/review_event.dart';
import 'package:eservelink/features/home/presentation/bloc/review/review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetRestaurantReviewsUseCase getRestaurantReviews;
  final GetAverageRatingUseCase getAverageRating;
  final GetRatingBreakdownUseCase getRatingBreakdown;

  ReviewBloc({
    required this.getRestaurantReviews,
    required this.getAverageRating,
    required this.getRatingBreakdown,
  }) : super(ReviewInitial()) {
    on<LoadRestaurantReviewsEvent>(_onLoadRestaurantReviews);
  }

  Future<void> _onLoadRestaurantReviews(
    LoadRestaurantReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final reviewsResult = await getRestaurantReviews(
      GetRestaurantReviewsParams(restaurantId: event.restaurantId),
    );

    await reviewsResult.fold(
      (failure) async => emit(ReviewError(failure.message)),
      (reviews) async {
        if (reviews.isEmpty) {
          emit(const ReviewEmpty());
          return;
        }

        // Get both average rating and breakdown in parallel
        final averageRatingFuture = getAverageRating(
          GetAverageRatingParams(restaurantId: event.restaurantId),
        );
        final breakdownFuture = getRatingBreakdown(
          GetRatingBreakdownParams(restaurantId: event.restaurantId),
        );

        final results = await Future.wait([
          averageRatingFuture,
          breakdownFuture,
        ]);

        final averageRatingResult = results[0] as Either<Failure, double>;
        final breakdownResult = results[1] as Either<Failure, Map<int, int>>;

        averageRatingResult.fold(
          (failure) => emit(ReviewError(failure.message)),
          (averageRating) {
            breakdownResult.fold(
              (failure) => emit(ReviewError(failure.message)),
              (ratingBreakdown) {
                emit(
                  ReviewLoaded(
                    reviews: reviews,
                    averageRating: averageRating,
                    totalReviews: reviews.length,
                    ratingBreakdown: ratingBreakdown,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
