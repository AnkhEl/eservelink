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
    on<NavigateToRestaurantDetailEvent>(_onNavigateToRestaurantDetail);
    on<NavigateBackToRestaurantListEvent>(_onNavigateBackToRestaurantList);
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

  Future<void> _onNavigateToRestaurantDetail(
    NavigateToRestaurantDetailEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    final currentState = state;

    emit(
      RestaurantShowDetail(
        restaurant: event.restaurant,
        distance: event.distance,
        userLatitude: event.userLatitude,
        userLongitude: event.userLongitude,
        previousState: currentState,
      ),
    );
  }

  Future<void> _onNavigateBackToRestaurantList(
    NavigateBackToRestaurantListEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    if (state is RestaurantShowDetail) {
      final detailState = state as RestaurantShowDetail;
      emit(detailState.previousState); // Restore the saved state
    } else {
      // Fallback to initial state
      emit(RestaurantInitial());
    }
  }
}
