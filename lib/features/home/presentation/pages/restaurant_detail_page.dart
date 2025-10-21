import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/core/util/app_styles.dart';
import 'package:eservelink/features/home/data/datasources/review_remote_data_source.dart';
import 'package:eservelink/features/home/data/repositories/review_repository_impl.dart';
import 'package:eservelink/features/home/domain/entities/restaurant_entity.dart';
import 'package:eservelink/features/home/domain/entities/review_entity.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_bloc.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_event.dart';
import 'package:eservelink/features/home/presentation/widgets/reviews_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RestaurantDetailPage extends StatelessWidget {
  final RestaurantEntity restaurant;
  final double distance;
  final double userLatitude;
  final double userLongitude;

  const RestaurantDetailPage({
    super.key,
    required this.restaurant,
    required this.distance,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.black,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 28, color: Colors.white),
                  onPressed: () {
                    context.read<RestaurantBloc>().add(
                      const NavigateBackToRestaurantListEvent(),
                    );
                  },
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(restaurant.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${distance.toStringAsFixed(1)} km away',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        restaurant.categories.map((category) {
                          return Chip(
                            label: Text(category),
                            backgroundColor: Colors.deepPurple.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 24),

                  // Description Section
                  Text(
                    'About',
                    style: AppStyles.headingTextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 12),
                  Text(
                    restaurant.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Price Range
                  _buildInfoRow(
                    Icons.attach_money,
                    'Price Range',
                    restaurant.priceRange,
                  ),
                  SizedBox(height: 16),

                  // Contact Information
                  Text(
                    'Contact Information',
                    style: AppStyles.headingTextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.location_on,
                    'Address',
                    restaurant.address,
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.phone, 'Phone', restaurant.phoneNumber),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.email, 'Email', restaurant.email),
                  SizedBox(height: 24),

                  // Opening Hours
                  Text(
                    'Opening Hours',
                    style: AppStyles.headingTextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 12),
                  _buildOpeningHoursSection(),
                  SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement call functionality
                            _makePhoneCall(context, restaurant.phoneNumber);
                          },
                          icon: Icon(Icons.phone),
                          label: Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement directions functionality
                            _openDirections(context);
                          },
                          icon: Icon(Icons.directions),
                          label: Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.deepPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 24),

                  // REVIEWS SECTION - THIS IS THE NEW PART
                  FutureBuilder<Map<String, dynamic>>(
                    future: _getReviewsData(restaurant.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Error loading reviews',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return SizedBox.shrink();
                      }

                      final data = snapshot.data!;
                      final reviews = data['reviews'] as List<ReviewEntity>;
                      final avgRating = data['avgRating'] as double;
                      final breakdown = data['breakdown'] as Map<int, int>;

                      if (reviews.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No reviews yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Be the first to review this restaurant!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ReviewsSection(
                        restaurantId: restaurant.id,
                        reviews: reviews,
                        averageRating: avgRating,
                        totalReviews: reviews.length,
                        ratingBreakdown: breakdown,
                      );
                    },
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getReviewsData(String restaurantId) async {
    final repository = ReviewRepositoryImpl(
      remoteDataSource: ReviewRemoteDataSourceImpl(
        firestore: FirebaseFirestore.instance,
      ),
    );

    try {
      final reviews = await repository.getRestaurantReviews(restaurantId);
      final avgRating = await repository.getAverageRating(restaurantId);
      final breakdown = await repository.getRatingBreakdown(restaurantId);

      return {
        'reviews': reviews,
        'avgRating': avgRating,
        'breakdown': breakdown,
      };
    } catch (e) {
      print('Error fetching reviews: $e');
      rethrow;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepPurple, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningHoursSection() {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: List.generate(days.length, (index) {
          final day = days[index];
          final dayName = dayNames[index];
          final hours = restaurant.openingHours[day] ?? 'Closed';

          return Padding(
            padding: EdgeInsets.only(bottom: index < days.length - 1 ? 12 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  hours,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _makePhoneCall(BuildContext context, String phoneNumber) {
    // TODO: Implement actual phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phoneNumber...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openDirections(BuildContext context) {
    // TODO: Implement actual navigation/directions functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
