import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';
import 'package:eservelink/features/menu/domain/repositories/menu_repository.dart';

/// Use case to get menu items for a specific restaurant.
class GetMenuItemsUseCase
    implements UseCase<List<MenuItemEntity>, GetMenuItemsParams> {
  final MenuRepository repository;

  GetMenuItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call(
    GetMenuItemsParams params,
  ) {
    return repository.getMenuItems(restaurantId: params.restaurantId);
  }
}

class GetMenuItemsParams extends Equatable {
  final String restaurantId;

  const GetMenuItemsParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}
