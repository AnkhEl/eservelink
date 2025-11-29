import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuEvent extends MenuEvent {
  final String restaurantId;

  const LoadMenuEvent(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class FilterByCategoryEvent extends MenuEvent {
  final String category;

  const FilterByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchMenuItemsEvent extends MenuEvent {
  final String query;

  const SearchMenuItemsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends MenuEvent {
  const ClearSearchEvent();
}

class LoadMenuItemDetailsEvent extends MenuEvent {
  final String itemId;

  const LoadMenuItemDetailsEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
