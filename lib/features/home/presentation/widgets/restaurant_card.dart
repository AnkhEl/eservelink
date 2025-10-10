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
      margin: const EdgeInsets.only(left: 20, bottom: 5),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Image
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  imageAsset,
                  width: MediaQuery.of(context).size.width / 1.2,
                  fit: BoxFit.cover,
                  height: 230,
                ),
              ),
              const SizedBox(height: 10),
              // Hotel Name and Rating
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Text(
                      restaurantName,
                      style: AppStyles.headingTextStyle(fontSize: 20),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 5.5),
                    // Star Rating
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < rating ? Icons.star : Icons.star_outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              // Location
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      location,
                      style: AppStyles.normalTextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
