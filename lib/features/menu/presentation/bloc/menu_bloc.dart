import 'dart:async';
import 'package:eservelink/features/menu/domain/usecases/get_categories_usecase.dart';
import 'package:eservelink/features/menu/domain/usecases/get_menu_item_usecase.dart';
import 'package:eservelink/features/menu/domain/usecases/get_menu_items_by_category_usecase.dart';
import 'package:eservelink/features/menu/domain/usecases/get_menu_items_usecase.dart';
import 'package:eservelink/features/menu/domain/usecases/search_menu_items_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/menu/presentation/bloc/menu_event.dart';
import 'package:eservelink/features/menu/presentation/bloc/menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetCategoriesUseCase getCategories;
  final GetMenuItemsUseCase getMenuItems;
  final GetMenuItemsByCategoryUseCase getMenuItemsByCategory;
  final SearchMenuItemsUseCase searchMenuItems;
  final GetMenuItemUseCase getMenuItem;

  String? _currentRestaurantId;

  MenuBloc({
    required this.getCategories,
    required this.getMenuItems,
    required this.getMenuItemsByCategory,
    required this.searchMenuItems,
    required this.getMenuItem,
  }) : super(const MenuInitial()) {
    on<LoadMenuEvent>(_onLoadMenu);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<SearchMenuItemsEvent>(_onSearchMenuItems);
    on<ClearSearchEvent>(_onClearSearch);
    on<LoadMenuItemDetailsEvent>(_onLoadMenuItemDetails);
  }

  Future<void> _onLoadMenu(LoadMenuEvent event, Emitter<MenuState> emit) async {
    print('📚 Loading menu for restaurant: ${event.restaurantId}');
    emit(const MenuLoading());

    _currentRestaurantId = event.restaurantId;

    // Fetch categories
    final categoriesResult = await getCategories(
      GetCategoriesParams(restaurantId: event.restaurantId),
    );

    // Fetch menu items
    final itemsResult = await getMenuItems(
      GetMenuItemsParams(restaurantId: event.restaurantId),
    );

    categoriesResult.fold(
      (failure) {
        print('❌ Failed to load categories: ${failure.message}');
        emit(MenuError(failure.message));
      },
      (categories) {
        itemsResult.fold(
          (failure) {
            print('❌ Failed to load menu items: ${failure.message}');
            emit(MenuError(failure.message));
          },
          (items) {
            print(
              '✅ Loaded ${categories.length} categories and ${items.length} items',
            );
            emit(
              MenuLoaded(
                categories: categories,
                allItems: items,
                displayedItems: items,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<MenuState> emit,
  ) async {
    if (state is! MenuLoaded) return;

    final currentState = state as MenuLoaded;
    print('🔍 Filtering by category: ${event.category}');

    if (_currentRestaurantId == null) {
      emit(const MenuError('Restaurant ID not set'));
      return;
    }

    // If "All" is selected, show all items
    if (event.category == 'All') {
      emit(
        currentState.copyWith(
          displayedItems: currentState.allItems,
          selectedCategory: null,
          clearCategory: true,
          clearSearch: true,
        ),
      );
      return;
    }

    // Filter items by category
    final filteredItems =
        currentState.allItems
            .where((item) => item.category == event.category)
            .toList();

    emit(
      currentState.copyWith(
        displayedItems: filteredItems,
        selectedCategory: event.category,
        clearSearch: true,
      ),
    );

    print('✅ Filtered to ${filteredItems.length} items');
  }

  Future<void> _onSearchMenuItems(
    SearchMenuItemsEvent event,
    Emitter<MenuState> emit,
  ) async {
    if (state is! MenuLoaded) return;

    final currentState = state as MenuLoaded;
    print('🔍 Searching menu items: ${event.query}');

    if (event.query.isEmpty) {
      // If search is empty, show all items or category-filtered items
      if (currentState.selectedCategory != null) {
        final filteredItems =
            currentState.allItems
                .where((item) => item.category == currentState.selectedCategory)
                .toList();
        emit(
          currentState.copyWith(
            displayedItems: filteredItems,
            clearSearch: true,
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            displayedItems: currentState.allItems,
            clearSearch: true,
          ),
        );
      }
      return;
    }

    // Search within all items
    final searchLower = event.query.toLowerCase();
    final searchResults =
        currentState.allItems.where((item) {
          return item.name.toLowerCase().contains(searchLower) ||
              item.description.toLowerCase().contains(searchLower);
        }).toList();

    emit(
      currentState.copyWith(
        displayedItems: searchResults,
        searchQuery: event.query,
        clearCategory: true,
      ),
    );

    print('✅ Found ${searchResults.length} matching items');
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<MenuState> emit,
  ) async {
    if (state is! MenuLoaded) return;

    final currentState = state as MenuLoaded;
    print('🔍 Clearing search');

    // Return to showing all items or category-filtered items
    if (currentState.selectedCategory != null) {
      final filteredItems =
          currentState.allItems
              .where((item) => item.category == currentState.selectedCategory)
              .toList();
      emit(
        currentState.copyWith(displayedItems: filteredItems, clearSearch: true),
      );
    } else {
      emit(
        currentState.copyWith(
          displayedItems: currentState.allItems,
          clearSearch: true,
        ),
      );
    }
  }

  Future<void> _onLoadMenuItemDetails(
    LoadMenuItemDetailsEvent event,
    Emitter<MenuState> emit,
  ) async {
    print('📖 Loading item details: ${event.itemId}');
    emit(const MenuLoading());

    final result = await getMenuItem(GetMenuItemParams(itemId: event.itemId));

    result.fold(
      (failure) {
        print('❌ Failed to load item details: ${failure.message}');
        emit(MenuError(failure.message));
      },
      (item) {
        print('✅ Loaded item details: ${item.name}');
        emit(MenuItemDetailsLoaded(item));
      },
    );
  }
}
