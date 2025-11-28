import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';
import 'package:eservelink/features/menu/domain/repositories/menu_repository.dart';

/// Get Single Menu Item Use Case
class GetMenuItemUseCase implements UseCase<MenuItemEntity, GetMenuItemParams> {
  final MenuRepository repository;

  GetMenuItemUseCase(this.repository);

  @override
  Future<Either<Failure, MenuItemEntity>> call(GetMenuItemParams params) {
    return repository.getMenuItem(itemId: params.itemId);
  }
}

class GetMenuItemParams extends Equatable {
  final String itemId;

  const GetMenuItemParams({required this.itemId});

  @override
  List<Object> get props => [itemId];
}
