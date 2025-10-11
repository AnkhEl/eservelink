import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/home/domain/usecases/add_restaurant_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_restaurant_by_id_usecase.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_event.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetNearbyRestaurantsUseCase getNearbyRestaurantsUseCase;
  final GetRestaurantByIdUseCase getRestaurantByIdUseCase;
  final AddRestaurantUseCase addRestaurantUseCase;

  RestaurantBloc({
    required this.getNearbyRestaurantsUseCase,
    required this.getRestaurantByIdUseCase,
    required this.addRestaurantUseCase,
  }) : super(RestaurantInitial()) {
    on<LoadNearbyRestaurantsEvent>(_onLoadNearbyRestaurants);
    on<LoadRestaurantByIdEvent>(_onLoadRestaurantById);
    on<RefreshRestaurantsEvent>(_onRefreshRestaurants);
  }

  Future<void> _onLoadNearbyRestaurants(
    LoadNearbyRestaurantsEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());

    final result = await getNearbyRestaurantsUseCase(
      GetNearbyRestaurantsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusInKm: event.radiusInKm,
      ),
    );

    result.fold(
      (failure) => emit(RestaurantError(message: failure.message)),
      (restaurants) => emit(
        RestaurantNearbyLoaded(
          restaurants: restaurants,
          userLatitude: event.latitude,
          userLongitude: event.longitude,
        ),
      ),
    );
  }

  Future<void> _onLoadRestaurantById(
    LoadRestaurantByIdEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());

    final result = await getRestaurantByIdUseCase(
      GetRestaurantByIdParams(restaurantId: event.restaurantId),
    );

    result.fold(
      (failure) => emit(RestaurantError(message: failure.message)),
      (restaurant) => emit(RestaurantDetailLoaded(restaurant: restaurant)),
    );
  }

  Future<void> _onRefreshRestaurants(
    RefreshRestaurantsEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    await _onLoadNearbyRestaurants(
      LoadNearbyRestaurantsEvent(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusInKm: event.radiusInKm,
      ),
      emit,
    );
  }
}
