import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/menu/domain/entities/menu_category_entity.dart';
import 'package:eservelink/features/menu/domain/repositories/menu_repository.dart';

/// Use case to get menu categories for a specific restaurant.
class GetCategoriesUseCase
    implements UseCase<List<MenuCategoryEntity>, GetCategoriesParams> {
  final MenuRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MenuCategoryEntity>>> call(
    GetCategoriesParams params,
  ) {
    return repository.getCategories(restaurantId: params.restaurantId);
  }
}

class GetCategoriesParams extends Equatable {
  final String restaurantId;

  const GetCategoriesParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}
