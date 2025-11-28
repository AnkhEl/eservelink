import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';
import 'package:eservelink/features/menu/domain/repositories/menu_repository.dart';

/// Use case to stream menu items for a specific restaurant.
class StreamMenuItemsUseCase {
  final MenuRepository repository;

  StreamMenuItemsUseCase(this.repository);

  Stream<Either<Failure, List<MenuItemEntity>>> call(
    StreamMenuItemsParams params,
  ) {
    return repository.streamMenuItems(restaurantId: params.restaurantId);
  }
}

class StreamMenuItemsParams extends Equatable {
  final String restaurantId;

  const StreamMenuItemsParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}
