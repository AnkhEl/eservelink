import 'package:equatable/equatable.dart';
import 'package:eservelink/features/home/domain/entities/review_entity.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingBreakdown;

  const ReviewLoaded({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
  });

  @override
  List<Object> get props => [
    reviews,
    averageRating,
    totalReviews,
    ratingBreakdown,
  ];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object> get props => [message];
}

class ReviewEmpty extends ReviewState {
  const ReviewEmpty();
}
