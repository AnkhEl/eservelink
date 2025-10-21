import 'package:flutter/material.dart';

class RatingBreakdown extends StatelessWidget {
  final Map<int, int> breakdown;
  final int totalReviews;

  const RatingBreakdown({
    super.key,
    required this.breakdown,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          [5, 4, 3, 2, 1].map((star) {
            final count = breakdown[star] ?? 0;
            final percentage = totalReviews > 0 ? count / totalReviews : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '$star',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${(percentage * 100).toInt()}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
