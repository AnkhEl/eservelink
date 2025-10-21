import 'package:flutter/material.dart';
import 'package:eservelink/features/home/domain/entities/review_entity.dart';
import 'package:eservelink/features/home/presentation/widgets/rating_breakdown.dart';
import 'package:eservelink/features/home/presentation/widgets/review_card.dart';

class ReviewsSection extends StatefulWidget {
  final String restaurantId;
  final List<ReviewEntity> reviews;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingBreakdown;

  const ReviewsSection({
    super.key,
    required this.restaurantId,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  int _displayedReviews = 5;

  @override
  Widget build(BuildContext context) {
    final reviewsToShow = widget.reviews.take(_displayedReviews).toList();
    final hasMoreReviews = _displayedReviews < widget.reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Reviews & Ratings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    widget.averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.averageRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${widget.totalReviews} reviews',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(width: 24),
              Expanded(
                child: RatingBreakdown(
                  breakdown: widget.ratingBreakdown,
                  totalReviews: widget.totalReviews,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Sort by:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Most Recent', style: TextStyle(fontSize: 12)),
                    Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children:
                reviewsToShow.map((review) {
                  return ReviewCard(
                    customerName: review.customerName,
                    rating: review.rating,
                    comment: review.comment,
                    createdAt: review.createdAt,
                  );
                }).toList(),
          ),
        ),
        if (hasMoreReviews)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _displayedReviews += 5;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.deepPurple),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Load More Reviews',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
