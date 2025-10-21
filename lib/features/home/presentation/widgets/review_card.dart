// lib/features/home/presentation/widgets/review_card.dart

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewCard extends StatefulWidget {
  final String customerName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewCard({
    super.key,
    required this.customerName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _isExpanded = false;
  static const int _maxLines = 3; // Show 3 lines before truncating
  static const int _charThreshold = 150; // ~150 characters = ~3 lines

  bool get _needsExpansion {
    if (widget.comment == null || widget.comment!.isEmpty) return false;
    return widget.comment!.length > _charThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Time, Stars
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  child: Text(
                    widget.customerName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customerName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        timeago.format(widget.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < widget.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),

            // Comment Section (with expand/collapse)
            if (widget.comment != null && widget.comment!.isNotEmpty) ...[
              SizedBox(height: 12),
              AnimatedCrossFade(
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                      maxLines: _maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_needsExpansion) ...[
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = true;
                          });
                        },
                        child: Text(
                          'Read more',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    if (_needsExpansion) ...[
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        child: Text(
                          'Read less',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                crossFadeState:
                    _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 200),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
