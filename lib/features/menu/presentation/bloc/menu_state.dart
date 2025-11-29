import 'package:equatable/equatable.dart';
import 'package:eservelink/features/menu/domain/entities/menu_category_entity.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial();
}

class MenuLoading extends MenuState {
  const MenuLoading();
}

class MenuLoaded extends MenuState {
  final List<MenuCategoryEntity> categories;
  final List<MenuItemEntity> allItems;
  final List<MenuItemEntity> displayedItems;
  final String? selectedCategory;
  final String? searchQuery;

  const MenuLoaded({
    required this.categories,
    required this.allItems,
    required this.displayedItems,
    this.selectedCategory,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
    categories,
    allItems,
    displayedItems,
    selectedCategory,
    searchQuery,
  ];

  MenuLoaded copyWith({
    List<MenuCategoryEntity>? categories,
    List<MenuItemEntity>? allItems,
    List<MenuItemEntity>? displayedItems,
    String? selectedCategory,
    String? searchQuery,
    bool clearCategory = false,
    bool clearSearch = false,
  }) {
    return MenuLoaded(
      categories: categories ?? this.categories,
      allItems: allItems ?? this.allItems,
      displayedItems: displayedItems ?? this.displayedItems,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

class MenuItemDetailsLoaded extends MenuState {
  final MenuItemEntity item;

  const MenuItemDetailsLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
