import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:eservelink/features/home/data/models/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  });

  Future<RestaurantModel> getRestaurantById({required String restaurantId});

  Future<void> addRestaurant({required RestaurantModel restaurant});
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final FirebaseFirestore firestore;

  RestaurantRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      final collection = firestore.collection('restaurants');
      final center = GeoFirePoint(GeoPoint(latitude, longitude));

      final query = GeoCollectionReference(collection).subscribeWithin(
        center: center,
        radiusInKm: radiusInKm,
        field: 'position',
        geopointFrom:
            (data) =>
                (data['position'] as Map<String, dynamic>)['geopoint']
                    as GeoPoint,
        strictMode: true,
      );

      List<RestaurantModel> restaurants = [];

      await for (final docs in query) {
        restaurants =
            docs
                .where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['isActive'] == true;
                })
                .map((doc) => RestaurantModel.fromFirestore(doc))
                .toList();
        break; // take the first snapshot only
      }

      return restaurants;
    } catch (e) {
      throw Exception('Error getting nearby restaurants: $e');
    }
  }

  @override
  Future<RestaurantModel> getRestaurantById({
    required String restaurantId,
  }) async {
    try {
      final doc =
          await firestore.collection('restaurants').doc(restaurantId).get();
      if (doc.exists) {
        return RestaurantModel.fromFirestore(doc);
      }
      throw Exception('Restaurant not found');
    } catch (e) {
      throw Exception('Error getting restaurant: $e');
    }
  }

  @override
  Future<void> addRestaurant({required RestaurantModel restaurant}) async {
    try {
      await firestore.collection('restaurants').add(restaurant.toFirestore());
    } catch (e) {
      throw Exception('Error adding restaurant: $e');
    }
  }
}
