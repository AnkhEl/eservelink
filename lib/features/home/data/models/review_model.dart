import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/home/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.restaurantId,
    required super.customerId,
    required super.customerName,
    required super.rating,
    super.comment,
    required super.type,
    required super.createdAt,
    super.sessionId,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReviewModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'],
      type: data['type'] ?? 'restaurant',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      sessionId: data['sessionId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      if (sessionId != null) 'sessionId': sessionId,
    };
  }

  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      customerId: entity.customerId,
      customerName: entity.customerName,
      rating: entity.rating,
      comment: entity.comment,
      type: entity.type,
      createdAt: entity.createdAt,
      sessionId: entity.sessionId,
    );
  }
}
