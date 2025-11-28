import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';
import 'package:eservelink/features/menu/domain/repositories/menu_repository.dart';

/// Get Menu Items By Category Use Case
class GetMenuItemsByCategoryUseCase
    implements UseCase<List<MenuItemEntity>, GetMenuItemsByCategoryParams> {
  final MenuRepository repository;

  GetMenuItemsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call(
    GetMenuItemsByCategoryParams params,
  ) {
    return repository.getMenuItemsByCategory(
      restaurantId: params.restaurantId,
      category: params.category,
    );
  }
}

class GetMenuItemsByCategoryParams extends Equatable {
  final String restaurantId;
  final String category;

  const GetMenuItemsByCategoryParams({
    required this.restaurantId,
    required this.category,
  });

  @override
  List<Object> get props => [restaurantId, category];
}
