import 'package:flutter/material.dart';
import 'package:eservelink/core/util/app_styles.dart';

class RestaurantCard extends StatelessWidget {
  final String imageAsset;
  final String restaurantName;
  final String location;
  final int rating; // Number of stars (1-5)

  const RestaurantCard({
    super.key,
    required this.imageAsset,
    required this.restaurantName,
    required this.location,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, // fixed width for horizontal scroll
      margin: const EdgeInsets.only(left: 20, bottom: 10),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 280, // increased height for better spacing
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.asset(
                  imageAsset,
                  width: double.infinity,
                  height: 220, // increased image height
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              // Name and Stars
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        restaurantName,
                        style: AppStyles.headingTextStyle(fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_outline,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location, // only first part
                        style: AppStyles.normalTextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Removed Spacer and added a fixed bottom padding for uniformity
              const SizedBox(
                height: 12,
              ), // Add space at the bottom for better visual balance
            ],
          ),
        ),
      ),
    );
  }
}
