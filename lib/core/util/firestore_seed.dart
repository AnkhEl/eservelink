import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class FirestoreSeed {
  static Future<void> seedRestaurants() async {
    final firestore = FirebaseFirestore.instance;

    // Johannesburg coordinates around Eastgate / Kensington / Parktown area
    final List<Map<String, dynamic>> restaurants = [
      {
        'name': 'The Grillhouse',
        'description': 'Premium steakhouse with a modern twist',
        'address': '7 Northumberland Road, South Kensington, Johannesburg',
        'phoneNumber': '+27 11 123 4567',
        'email': 'info@thegrillhouse.co.za',
        'imageUrl': 'assets/hotel1.jpg',
        'rating': 4.5,
        'categories': ['Steakhouse', 'Fine Dining'],
        'priceRange': 'R150 - R400',
        'openingHours': {
          'monday': '11:00-22:00',
          'tuesday': '11:00-22:00',
          'wednesday': '11:00-22:00',
          'thursday': '11:00-22:00',
          'friday': '11:00-23:00',
          'saturday': '12:00-23:00',
          'sunday': '12:00-21:00',
        },
        'position': GeoFirePoint(GeoPoint(-26.1871, 28.1183)).data,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Bella Italia',
        'description': 'Authentic Italian cuisine and fresh pasta',
        'address': '45 Main Street, Johannesburg CBD',
        'phoneNumber': '+27 11 234 5678',
        'email': 'info@bellaitalia.co.za',
        'imageUrl': 'assets/hotel2.jpg',
        'rating': 4.2,
        'categories': ['Italian', 'Pasta'],
        'priceRange': 'R120 - R300',
        'openingHours': {
          'monday': '12:00-22:00',
          'tuesday': '12:00-22:00',
          'wednesday': '12:00-22:00',
          'thursday': '12:00-22:00',
          'friday': '12:00-23:00',
          'saturday': '12:00-23:00',
          'sunday': '12:00-21:00',
        },
        'position': GeoFirePoint(GeoPoint(-26.2041, 28.0473)).data,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Dragon Palace',
        'description': 'Asian fusion with traditional recipes',
        'address': '78 Oxford Road, Rosebank, Johannesburg',
        'phoneNumber': '+27 11 345 6789',
        'email': 'info@dragonpalace.co.za',
        'imageUrl': 'assets/hotel3.jpg',
        'rating': 4.3,
        'categories': ['Asian', 'Fusion'],
        'priceRange': 'R180 - R350',
        'openingHours': {
          'monday': '11:30-22:30',
          'tuesday': '11:30-22:30',
          'wednesday': '11:30-22:30',
          'thursday': '11:30-22:30',
          'friday': '11:30-23:30',
          'saturday': '12:00-23:30',
          'sunday': '12:00-22:00',
        },
        'position': GeoFirePoint(GeoPoint(-26.1466, 28.0414)).data,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'The Burger Joint',
        'description': 'Gourmet burgers and craft beer',
        'address': '32 Park Road, Parktown, Johannesburg',
        'phoneNumber': '+27 11 456 7890',
        'email': 'info@burgerjoint.co.za',
        'imageUrl': 'assets/hotel1.jpg',
        'rating': 4.1,
        'categories': ['Burgers', 'Fast Food'],
        'priceRange': 'R100 - R250',
        'openingHours': {
          'monday': '10:00-22:00',
          'tuesday': '10:00-22:00',
          'wednesday': '10:00-22:00',
          'thursday': '10:00-22:00',
          'friday': '10:00-23:00',
          'saturday': '11:00-23:00',
          'sunday': '11:00-21:00',
        },
        'position': GeoFirePoint(GeoPoint(-26.1820, 28.0340)).data,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Sushi Master',
        'description': 'Fresh sushi and Japanese delicacies',
        'address': '12 Queens Road, Parktown, Johannesburg',
        'phoneNumber': '+27 11 567 8901',
        'email': 'info@sushimaster.co.za',
        'imageUrl': 'assets/hotel2.jpg',
        'rating': 4.6,
        'categories': ['Sushi', 'Japanese'],
        'priceRange': 'R150 - R350',
        'openingHours': {
          'monday': '12:00-22:00',
          'tuesday': '12:00-22:00',
          'wednesday': '12:00-22:00',
          'thursday': '12:00-22:00',
          'friday': '12:00-23:00',
          'saturday': '12:00-23:00',
          'sunday': '12:00-21:00',
        },
        'position': GeoFirePoint(GeoPoint(-26.1815, 28.0325)).data,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Sandton Sky Dining',
        'description': 'Upscale rooftop dining with panoramic views',
        'address': '123 Rivonia Road, Sandton, Johannesburg',
        'phoneNumber': '+27 11 678 9012',
        'email': 'info@sandtonsky.co.za',
        'imageUrl': 'assets/hotel3.jpg',
        'rating': 4.7,
        'categories': ['Fine Dining', 'International'],
        'priceRange': 'R250 - R600',
        'openingHours': {
          'monday': '12:00-23:00',
          'tuesday': '12:00-23:00',
          'wednesday': '12:00-23:00',
          'thursday': '12:00-23:00',
          'friday': '12:00-00:00',
          'saturday': '12:00-00:00',
          'sunday': '12:00-22:00',
        },
        // Sandton ~15 km north of Parktown
        'position': GeoFirePoint(GeoPoint(-26.1076, 28.0567)).data,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Pretoria Grill',
        'description': 'Traditional South African braai and grill',
        'address': '456 Church Street, Pretoria',
        'phoneNumber': '+27 12 345 6789',
        'email': 'info@pretoriagrill.co.za',
        'imageUrl': 'assets/hotel3.jpg',
        'rating': 4.4,
        'categories': ['South African', 'Grill'],
        'priceRange': 'R120 - R350',
        'openingHours': {
          'monday': '11:00-22:00',
          'tuesday': '11:00-22:00',
          'wednesday': '11:00-22:00',
          'thursday': '11:00-22:00',
          'friday': '11:00-23:00',
          'saturday': '12:00-23:00',
          'sunday': '12:00-21:00',
        },
        // Pretoria ~55 km north of Johannesburg
        'position': GeoFirePoint(GeoPoint(-25.7461, 28.1881)).data,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Soweto Flavors',
        'description': 'Authentic township cuisine with live music',
        'address': 'Vilakazi Street, Soweto, Johannesburg',
        'phoneNumber': '+27 11 765 4321',
        'email': 'info@sowetoflavors.co.za',
        'imageUrl': 'assets/hotel2.jpg',
        'rating': 4.3,
        'categories': ['African', 'Casual Dining'],
        'priceRange': 'R80 - R200',
        'openingHours': {
          'monday': '10:00-21:00',
          'tuesday': '10:00-21:00',
          'wednesday': '10:00-21:00',
          'thursday': '10:00-21:00',
          'friday': '10:00-23:00',
          'saturday': '11:00-23:00',
          'sunday': '11:00-20:00',
        },
        // Soweto ~20 km southwest of Parktown
        'position': GeoFirePoint(GeoPoint(-26.2485, 27.8540)).data,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Airport Bistro',
        'description': 'Quick bites and coffee near OR Tambo',
        'address': 'OR Tambo International Airport, Johannesburg',
        'phoneNumber': '+27 11 555 1234',
        'email': 'info@airportbistro.co.za',
        'imageUrl': 'assets/hotel1.jpg',
        'rating': 4.0,
        'categories': ['Cafe', 'Fast Food'],
        'priceRange': 'R50 - R150',
        'openingHours': {
          'monday': '06:00-22:00',
          'tuesday': '06:00-22:00',
          'wednesday': '06:00-22:00',
          'thursday': '06:00-22:00',
          'friday': '06:00-23:00',
          'saturday': '06:00-23:00',
          'sunday': '06:00-22:00',
        },
        // OR Tambo ~22 km east of Parktown
        'position': GeoFirePoint(GeoPoint(-26.1337, 28.2420)).data,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
    ];

    try {
      // Delete old restaurants first (optional, useful for reseeding)
      final existing = await firestore.collection('restaurants').get();
      for (final doc in existing.docs) {
        await doc.reference.delete();
      }

      // Add all restaurants
      for (final restaurant in restaurants) {
        await firestore.collection('restaurants').add(restaurant);
      }

      print('✅ Successfully seeded ${restaurants.length} restaurants');
    } catch (e) {
      print('❌ Error seeding restaurants: $e');
    }
  }

  /// Optional: Delete all restaurants (useful for testing)
  static Future<void> deleteAllRestaurants() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore.collection('restaurants').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Successfully deleted all restaurants');
    } catch (e) {
      print('❌ Error deleting restaurants: $e');
    }
  }

  static Future<void> seedReviews({
    int minReviewsPerRestaurant = 5,
    int maxReviewsPerRestaurant = 15,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final random = Random();

    final mockCustomers = [
      {'id': 'cust_1', 'name': 'Thabo Mbeki'},
      {'id': 'cust_2', 'name': 'Sarah Johnson'},
      {'id': 'cust_3', 'name': 'Naledi Mokoena'},
      {'id': 'cust_4', 'name': 'Michael van der Berg'},
      {'id': 'cust_5', 'name': 'Zanele Dlamini'},
      {'id': 'cust_6', 'name': 'David Robinson'},
      {'id': 'cust_7', 'name': 'Lerato Khumalo'},
      {'id': 'cust_8', 'name': 'John Patel'},
      {'id': 'cust_9', 'name': 'Nomsa Nkosi'},
      {'id': 'cust_10', 'name': 'James Cooper'},
      {'id': 'cust_11', 'name': 'Ayanda Zulu'},
      {'id': 'cust_12', 'name': 'Emma Williams'},
      {'id': 'cust_13', 'name': 'Sipho Ndlovu'},
      {'id': 'cust_14', 'name': 'Lisa Chen'},
      {'id': 'cust_15', 'name': 'Bongani Sithole'},
    ];

    final excellentComments = [
      'Absolutely outstanding! The food was exceptional and the service was impeccable.',
      'Best dining experience I\'ve had in Johannesburg. Will definitely be back!',
      'Amazing food and atmosphere. The staff went above and beyond.',
      'Perfect in every way! From the ambiance to the delicious food.',
      'Exceptional quality and service. Highly recommend this place!',
      'Loved everything about this restaurant. The chef is truly talented.',
      'Outstanding experience from start to finish. Worth every cent!',
      'This restaurant exceeded all expectations! From the moment we walked in, we were greeted warmly. The ambiance is absolutely perfect - dim lighting, soft music, and beautiful decor. Our waiter was incredibly knowledgeable about the menu and wine pairings. We started with the appetizers which were divine. The main course was even better - my steak was cooked to perfection, medium rare just as I ordered. My partner had the seafood pasta which was equally amazing. The portions were generous and the presentation was restaurant-quality. For dessert, we shared the chocolate lava cake which was the perfect ending to our meal. We will definitely be returning for special occasions!',
    ];

    final goodComments = [
      'Great food and friendly service. Really enjoyed our meal here.',
      'Very good experience overall. The menu has excellent variety.',
      'Solid choice for a nice meal. Would recommend to friends.',
      'Good atmosphere and tasty food. Will come back with family.',
      'Enjoyed the food and service. A few minor issues but overall great.',
      'Nice place with good food. Service was attentive and friendly.',
    ];

    final averageComments = [
      'Decent food but nothing extraordinary. Service was okay.',
      'Average experience. Food was good but a bit overpriced.',
      'It was alright. Expected more based on the reviews.',
      'Good food but the service could be improved.',
      'Not bad, but not amazing either. Worth trying once.',
    ];

    final poorComments = [
      'Food was okay but service was quite slow.',
      'Disappointed with the quality given the price.',
      'Service needs significant improvement.',
      'Food was mediocre and took too long to arrive.',
      'Not worth the money. Expected much better.',
    ];

    DateTime _pastDate(int daysAgo, int hoursOffset) {
      return DateTime.now().subtract(
        Duration(days: daysAgo, hours: hoursOffset),
      );
    }

    int _getWeightedRating(Random rng) {
      final weights = [5, 10, 15, 35, 35];
      final totalWeight = weights.reduce((a, b) => a + b);
      final randomValue = rng.nextInt(totalWeight);

      int cumulativeWeight = 0;
      for (int i = 0; i < weights.length; i++) {
        cumulativeWeight += weights[i];
        if (randomValue < cumulativeWeight) {
          return i + 1;
        }
      }
      return 5;
    }

    String? _getCommentForRating(int rating, Random rng) {
      if (rng.nextInt(10) < 3) return null;

      List<String> commentPool;
      switch (rating) {
        case 5:
          commentPool = excellentComments;
          break;
        case 4:
          commentPool = goodComments;
          break;
        case 3:
          commentPool = averageComments;
          break;
        case 2:
        case 1:
          commentPool = poorComments;
          break;
        default:
          commentPool = goodComments;
      }

      return commentPool[rng.nextInt(commentPool.length)];
    }

    try {
      final existingReviews = await firestore.collection('reviews').get();
      for (final doc in existingReviews.docs) {
        await doc.reference.delete();
      }

      final restaurantsSnap = await firestore.collection('restaurants').get();
      final restaurants = restaurantsSnap.docs;

      if (restaurants.isEmpty) {
        print('⚠️ No restaurants found. Please seed restaurants first.');
        return;
      }

      int totalReviews = 0;
      int operations = 0;
      WriteBatch batch = firestore.batch();

      for (final restaurant in restaurants) {
        final restaurantId = restaurant.id;
        final reviewCount =
            minReviewsPerRestaurant +
            random.nextInt(
              maxReviewsPerRestaurant - minReviewsPerRestaurant + 1,
            );

        final usedCustomers = <String>{};

        for (int i = 0; i < reviewCount; i++) {
          Map<String, dynamic> customer;
          int attempts = 0;
          do {
            customer = mockCustomers[random.nextInt(mockCustomers.length)];
            attempts++;
          } while (usedCustomers.contains(customer['id']) &&
              attempts < 10 &&
              usedCustomers.length < mockCustomers.length);

          usedCustomers.add(customer['id'] as String);

          final rating = _getWeightedRating(random);
          final comment = _getCommentForRating(rating, random);
          final daysAgo = random.nextInt(60);
          final hoursOffset = random.nextInt(24);
          final createdAt = Timestamp.fromDate(_pastDate(daysAgo, hoursOffset));

          final docRef = firestore.collection('reviews').doc();
          batch.set(docRef, {
            'restaurantId': restaurantId,
            'customerId': customer['id'],
            'customerName': customer['name'],
            'rating': rating,
            'comment': comment,
            'type': 'restaurant',
            'createdAt': createdAt,
          });

          operations++;
          totalReviews++;

          if (operations >= 450) {
            await batch.commit();
            batch = firestore.batch();
            operations = 0;
            print('⏳ Committed batch... Total reviews so far: $totalReviews');
          }
        }
      }

      if (operations > 0) {
        await batch.commit();
      }

      print(
        '✅ Successfully seeded $totalReviews reviews for ${restaurants.length} restaurants',
      );
      print(
        '📊 Average reviews per restaurant: ${(totalReviews / restaurants.length).toStringAsFixed(1)}',
      );
    } catch (e) {
      print('❌ Error seeding reviews: $e');
    }
  }

  static Future<void> deleteAllReviews() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore.collection('reviews').get();
      WriteBatch batch = firestore.batch();
      int operations = 0;

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        operations++;

        if (operations >= 450) {
          await batch.commit();
          batch = firestore.batch();
          operations = 0;
        }
      }

      if (operations > 0) {
        await batch.commit();
      }

      print('✅ Successfully deleted all reviews');
    } catch (e) {
      print('❌ Error deleting reviews: $e');
    }
  }

  /// Seed tables for all restaurants
  static Future<void> seedTables({int numberOfTablesPerRestaurant = 10}) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Delete existing tables first (optional, useful for reseeding)
      final existingTables = await firestore.collection('tables').get();
      for (final doc in existingTables.docs) {
        await doc.reference.delete();
      }

      // Get all restaurants
      final restaurants = await firestore.collection('restaurants').get();

      if (restaurants.docs.isEmpty) {
        print('⚠️ No restaurants found. Please seed restaurants first.');
        return;
      }

      int totalTables = 0;

      // Create tables for each restaurant
      for (final restaurant in restaurants.docs) {
        final restaurantId = restaurant.id;
        final restaurantName = restaurant.data()['name'] ?? 'Unknown';

        print('Creating tables for: $restaurantName');

        for (int i = 1; i <= numberOfTablesPerRestaurant; i++) {
          // Generate table ID: T_{restaurantId}_{tableNumber}
          final tableId = 'T_${restaurantId}_${i.toString().padLeft(3, '0')}';

          await firestore.collection('tables').doc(tableId).set({
            'restaurantId': restaurantId,
            'tableNumber': 'Table $i',
            'capacity': _calculateCapacity(i), // 2-6 seats
            'status': 'available',
            'createdAt': FieldValue.serverTimestamp(),
          });

          totalTables++;
        }
      }

      print(
        '✅ Successfully seeded $totalTables tables for ${restaurants.docs.length} restaurants',
      );
      print(
        '📊 Average: ${(totalTables / restaurants.docs.length).toStringAsFixed(1)} tables per restaurant',
      );
    } catch (e) {
      print('❌ Error seeding tables: $e');
    }
  }

  /// Calculate table capacity based on table number
  /// Returns variety: 2, 4, 6 seats
  static int _calculateCapacity(int tableNumber) {
    // Distribute capacity:
    // Tables 1-3: 2 seats (small)
    // Tables 4-7: 4 seats (medium)
    // Tables 8-10: 6 seats (large)
    if (tableNumber <= 3) return 2;
    if (tableNumber <= 7) return 4;
    return 6;
  }

  /// Delete all tables (useful for testing/reseeding)
  static Future<void> deleteAllTables() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore.collection('tables').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Successfully deleted all tables');
    } catch (e) {
      print('❌ Error deleting tables: $e');
    }
  }

  /// Seed everything at once (restaurants → tables → reviews)
  static Future<void> seedAll() async {
    print('🌱 Starting complete database seeding...\n');

    print('1️⃣ Seeding restaurants...');
    await seedRestaurants();

    print('\n2️⃣ Seeding tables...');
    await seedTables(numberOfTablesPerRestaurant: 10);

    print('\n3️⃣ Seeding reviews...');
    await seedReviews(minReviewsPerRestaurant: 5, maxReviewsPerRestaurant: 15);

    print('\n🎉 Complete! Database fully seeded.');
  }
}
