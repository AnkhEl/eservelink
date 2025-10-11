import 'package:eservelink/core/services/location_service.dart';
import 'package:eservelink/core/util/app_styles.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_bloc.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_event.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_state.dart';
import 'package:eservelink/features/home/presentation/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LocationService _locationService = LocationService();
  String _currentLocation = 'Getting location...';
  bool _locationLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndFetchRestaurants();
  }

  Future<void> _initializeLocationAndFetchRestaurants() async {
    final locationResult = await _locationService.getCurrentLocation();

    locationResult.fold(
      (failure) {
        setState(() {
          _currentLocation = failure.message;
          _locationLoading = false;
        });
      },
      (position) async {
        try {
          // Get address from coordinates using geocoding
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            setState(() {
              _currentLocation =
                  "${place.country}, ${place.locality ?? place.administrativeArea}";
              _locationLoading = false;
            });
          } else {
            setState(() {
              _currentLocation = 'Location found';
              _locationLoading = false;
            });
          }

          // Fetch nearby restaurants
          if (mounted) {
            context.read<RestaurantBloc>().add(
              LoadNearbyRestaurantsEvent(
                latitude: position.latitude,
                longitude: position.longitude,
                radiusInKm: 40,
              ),
            );
          }
        } catch (e) {
          setState(() {
            _currentLocation = 'Could not fetch location name';
            _locationLoading = false;
          });

          // Still try to fetch restaurants even if geocoding fails
          if (mounted) {
            context.read<RestaurantBloc>().add(
              LoadNearbyRestaurantsEvent(
                latitude: position.latitude,
                longitude: position.longitude,
                radiusInKm: 10,
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 241, 241),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess) {
            final userName =
                authState.user.displayName ??
                authState.user.email.split('@')[0];

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _currentLocation = 'Getting location...';
                  _locationLoading = true;
                });
                await _initializeLocationAndFetchRestaurants();
              },
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          child: Image.asset(
                            'assets/home.jpg',
                            width: MediaQuery.of(context).size.width,
                            height: 280,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 40, left: 20),
                          width: MediaQuery.of(context).size.width,
                          height: 280,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(90, 0, 0, 0),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.white),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _currentLocation,
                                      style: AppStyles.whiteTextStyle(
                                        fontSize: 20,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              Text(
                                "Hi $userName, tell us where you want to dine...",
                                style: AppStyles.whiteTextStyle(fontSize: 24),
                              ),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.only(bottom: 5, top: 5),
                                margin: EdgeInsets.only(right: 20),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(103, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                    hintText: "Search Places...",
                                    hintStyle: AppStyles.whiteTextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: Text(
                        "The most relevant",
                        style: AppStyles.headingTextStyle(fontSize: 25),
                      ),
                    ),
                    SizedBox(height: 20),
                    BlocBuilder<RestaurantBloc, RestaurantState>(
                      builder: (context, restaurantState) {
                        if (restaurantState is RestaurantLoading) {
                          return SizedBox(
                            height: 310,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (restaurantState is RestaurantError) {
                          return SizedBox(
                            height: 310,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      restaurantState.message,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      _initializeLocationAndFetchRestaurants();
                                    },
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (restaurantState is RestaurantNearbyLoaded) {
                          if (restaurantState.restaurants.isEmpty) {
                            return SizedBox(
                              height: 310,
                              child: Center(
                                child: Text(
                                  'No restaurants found nearby',
                                  style: AppStyles.headingTextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }

                          final firstFour =
                              restaurantState.restaurants.take(4).toList();
                          final remaining =
                              restaurantState.restaurants.skip(4).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ===== HORIZONTAL LIST (First 4) =====
                              SizedBox(
                                height: 310,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: firstFour.length,
                                  itemBuilder: (context, index) {
                                    final restaurant = firstFour[index];

                                    return RestaurantCard(
                                      imageAsset: restaurant.imageUrl,
                                      restaurantName: restaurant.name,
                                      location: restaurant.address,
                                      rating: restaurant.rating.toInt(),
                                    );
                                  },
                                ),
                              ),
                              // ======================================

                              // ===== NEW: Vertically scrollable list with lazy loading =====
                              if (remaining.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    top: 30,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    "Places Near you",
                                    style: AppStyles.headingTextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                                // ===== NEW: Fixed height container for vertical scrolling =====
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: ListView.builder(
                                      // ===== NEW: Changed to allow independent scrolling =====
                                      shrinkWrap: false,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      // ====================================================
                                      itemCount: remaining.length,
                                      itemBuilder: (context, index) {
                                        final restaurant = remaining[index];

                                        return Card(
                                          margin: EdgeInsets.only(bottom: 15),
                                          color: Colors.white,
                                          child: ListTile(
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.asset(
                                                restaurant.imageUrl,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            title: Text(restaurant.name),
                                            subtitle: Text(restaurant.address),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  restaurant.rating
                                                      .toStringAsFixed(1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // =========================================================
                              ],

                              // ============================================================
                              SizedBox(height: 20),
                            ],
                          );
                        }

                        return SizedBox(
                          height: 310,
                          child: Center(
                            child: Text(
                              'No restaurants available',
                              style: AppStyles.headingTextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
