import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String customerId;
  final String customerName;
  final double rating;
  final String? comment;
  final String type; // 'restaurant' or 'waiter'
  final DateTime createdAt;
  final String? sessionId; // For future implementation when sessions are added

  const ReviewEntity({
    required this.id,
    required this.restaurantId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    this.comment,
    required this.type,
    required this.createdAt,
    this.sessionId,
  });

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    customerId,
    customerName,
    rating,
    comment,
    type,
    createdAt,
    sessionId,
  ];
}
