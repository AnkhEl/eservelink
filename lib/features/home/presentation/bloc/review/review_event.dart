import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class LoadRestaurantReviewsEvent extends ReviewEvent {
  final String restaurantId;

  const LoadRestaurantReviewsEvent(this.restaurantId);

  @override
  List<Object> get props => [restaurantId];
}
