import 'package:card_loading/card_loading.dart';
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
import 'dart:math' as math;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LocationService _locationService = LocationService();
  String _currentLocation = 'Getting location...';
  bool _locationLoading = true;

  // Filter state variables
  double _selectedRadius = 10;
  double? _selectedRating;
  List<String> _selectedCategories = [];
  String? _selectedPriceRange;

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

          if (mounted) {
            context.read<RestaurantBloc>().add(
              LoadNearbyRestaurantsEvent(
                latitude: position.latitude,
                longitude: position.longitude,
                radiusInKm: _selectedRadius,
              ),
            );
          }
        } catch (e) {
          setState(() {
            _currentLocation = 'Could not fetch location name';
            _locationLoading = false;
          });

          if (mounted) {
            context.read<RestaurantBloc>().add(
              LoadNearbyRestaurantsEvent(
                latitude: position.latitude,
                longitude: position.longitude,
                radiusInKm: _selectedRadius,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "The most relevant",
                            style: AppStyles.headingTextStyle(fontSize: 25),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: GestureDetector(
                              onTap: _showFilterModal,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.tune,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      _getActiveFilterText(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    BlocBuilder<RestaurantBloc, RestaurantState>(
                      builder: (context, restaurantState) {
                        if (_locationLoading) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 310,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: List.generate(
                                    4,
                                    (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: CardLoading(
                                        height: 280,
                                        width: 220,
                                        borderRadius: BorderRadius.circular(15),
                                        margin: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  "Places Near you",
                                  style: AppStyles.headingTextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  children: List.generate(
                                    3,
                                    (index) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 15,
                                      ),
                                      child: CardLoading(
                                        height: 80,
                                        width: double.infinity,
                                        borderRadius: BorderRadius.circular(10),
                                        margin: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        if (restaurantState is RestaurantLoading) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 310,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: List.generate(
                                    4,
                                    (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: CardLoading(
                                        height: 280,
                                        width: 220,
                                        borderRadius: BorderRadius.circular(15),
                                        margin: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  "Places Near you",
                                  style: AppStyles.headingTextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  children: List.generate(
                                    3,
                                    (index) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 15,
                                      ),
                                      child: CardLoading(
                                        height: 80,
                                        width: double.infinity,
                                        borderRadius: BorderRadius.circular(10),
                                        margin: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

                          final filteredRestaurants = _applyFilters(
                            restaurantState.restaurants,
                          );

                          if (filteredRestaurants.isEmpty) {
                            return SizedBox(
                              height: 310,
                              child: Center(
                                child: Text(
                                  'No restaurants match your filters',
                                  style: AppStyles.headingTextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }

                          final firstFour =
                              filteredRestaurants.take(4).toList();
                          final remaining =
                              filteredRestaurants.skip(4).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 310,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: firstFour.length,
                                  itemBuilder: (context, index) {
                                    final restaurant = firstFour[index];
                                    final distance = _calculateDistance(
                                      restaurantState.userLatitude,
                                      restaurantState.userLongitude,
                                      restaurant.geolocation.latitude,
                                      restaurant.geolocation.longitude,
                                    );

                                    return RestaurantCard(
                                      imageAsset: restaurant.imageUrl,
                                      restaurantName: restaurant.name,
                                      location: restaurant.address,
                                      rating: restaurant.rating.toInt(),
                                      distance: distance,
                                    );
                                  },
                                ),
                              ),
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
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: false,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemCount: remaining.length,
                                      itemBuilder: (context, index) {
                                        final restaurant = remaining[index];
                                        final distance = _calculateDistance(
                                          restaurantState.userLatitude,
                                          restaurantState.userLongitude,
                                          restaurant.geolocation.latitude,
                                          restaurant.geolocation.longitude,
                                        );

                                        return Card(
                                          margin: EdgeInsets.only(bottom: 15),
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
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  restaurant.address,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      '${distance.toStringAsFixed(1)} km away',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
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
                              ],
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

  List<dynamic> _applyFilters(List<dynamic> restaurants) {
    return restaurants.where((restaurant) {
      if (_selectedRating != null && restaurant.rating < _selectedRating!) {
        return false;
      }

      if (_selectedCategories.isNotEmpty) {
        final hasMatchingCategory = restaurant.categories.any(
          (category) => _selectedCategories.contains(category),
        );
        if (!hasMatchingCategory) return false;
      }

      if (_selectedPriceRange != null &&
          restaurant.priceRange != _selectedPriceRange) {
        return false;
      }

      return true;
    }).toList();
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadiusKm = 6371;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);

    final double a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  String _getActiveFilterText() {
    int activeFilters = 0;
    if (_selectedRating != null) activeFilters++;
    if (_selectedCategories.isNotEmpty) activeFilters++;
    if (_selectedPriceRange != null) activeFilters++;

    if (activeFilters == 0) {
      return '${_selectedRadius.toInt()}km';
    }
    return '${_selectedRadius.toInt()}km (+$activeFilters)';
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filters',
                          style: AppStyles.headingTextStyle(fontSize: 22),
                        ),
                        SizedBox(height: 30),
                        _buildRadiusFilterSection(setModalState),
                        Divider(height: 40),
                        _buildRatingFilterSection(setModalState),
                        Divider(height: 40),
                        _buildCategoryFilterSection(setModalState),
                        Divider(height: 40),
                        _buildPriceRangeFilterSection(setModalState),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(() {
                                    _selectedRadius = 10;
                                    _selectedRating = null;
                                    _selectedCategories = [];
                                    _selectedPriceRange = null;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  side: BorderSide(color: Colors.deepPurple),
                                ),
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _locationLoading = true;
                                  });
                                  _initializeLocationAndFetchRestaurants();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: Text(
                                  'Apply Filters',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRadiusFilterSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Radius',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.deepPurple),
              SizedBox(width: 10),
              Text(
                '${_selectedRadius.toInt()} km',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Slider(
          value: _selectedRadius,
          min: 1,
          max: 50,
          divisions: 49,
          label: '${_selectedRadius.toInt()} km',
          onChanged: (value) {
            setModalState(() {
              _selectedRadius = value;
            });
          },
        ),
        SizedBox(height: 15),
        Text(
          'Quick Select',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children:
              [5, 10, 15, 25].map((radius) {
                return ElevatedButton(
                  onPressed: () {
                    setModalState(() {
                      _selectedRadius = radius.toDouble();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedRadius == radius
                            ? Colors.deepPurple
                            : Colors.grey[300],
                  ),
                  child: Text(
                    '${radius}km',
                    style: TextStyle(
                      color:
                          _selectedRadius == radius
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingFilterSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          children:
              [1.0, 2.0, 3.0, 4.0, 4.5].map((rating) {
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color:
                            _selectedRating == rating
                                ? Colors.white
                                : Colors.amber,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text('${rating.toStringAsFixed(1)}+'),
                    ],
                  ),
                  selected: _selectedRating == rating,
                  onSelected: (selected) {
                    setModalState(() {
                      _selectedRating = selected ? rating : null;
                    });
                  },
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color:
                        _selectedRating == rating ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterSection(StateSetter setModalState) {
    final categories = [
      'Italian',
      'Asian',
      'Burgers',
      'Sushi',
      'Steakhouse',
      'Fast Food',
      'Fine Dining',
      'Japanese',
      'Fusion',
      'South African',
      'Grill',
      'African',
      'Casual Dining',
      'Cafe',
      'International',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setModalState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilterSection(StateSetter setModalState) {
    final priceRanges = [
      {'label': 'Budget', 'range': 'R50 - R150'},
      {'label': 'Moderate', 'range': 'R100 - R300'},
      {'label': 'Premium', 'range': 'R150 - R400'},
      {'label': 'Luxury', 'range': 'R250 - R600'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              priceRanges.map((priceRange) {
                final isSelected = _selectedPriceRange == priceRange['range'];
                return ChoiceChip(
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        priceRange['label']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        priceRange['range']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setModalState(() {
                      _selectedPriceRange =
                          selected ? priceRange['range'] : null;
                    });
                  },
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.grey[200],
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
        ),
      ],
    );
  }
}
