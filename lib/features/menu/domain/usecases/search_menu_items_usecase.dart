import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';
import 'package:eservelink/features/menu/domain/repositories/menu_repository.dart';

/// Use case to search menu items within a specific restaurant.
class SearchMenuItemsUseCase
    implements UseCase<List<MenuItemEntity>, SearchMenuItemsParams> {
  final MenuRepository repository;

  SearchMenuItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call(
    SearchMenuItemsParams params,
  ) {
    return repository.searchMenuItems(
      restaurantId: params.restaurantId,
      query: params.query,
    );
  }
}

class SearchMenuItemsParams extends Equatable {
  final String restaurantId;
  final String query;

  const SearchMenuItemsParams({
    required this.restaurantId,
    required this.query,
  });

  @override
  List<Object> get props => [restaurantId, query];
}
