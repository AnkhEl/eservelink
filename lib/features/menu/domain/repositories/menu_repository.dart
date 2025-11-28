import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/menu/domain/entities/menu_category_entity.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';

abstract class MenuRepository {
  /// Get all categories for a restaurant
  Future<Either<Failure, List<MenuCategoryEntity>>> getCategories({
    required String restaurantId,
  });

  /// Get all menu items for a restaurant
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems({
    required String restaurantId,
  });

  /// Get menu items by category
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItemsByCategory({
    required String restaurantId,
    required String category,
  });

  /// Search menu items
  Future<Either<Failure, List<MenuItemEntity>>> searchMenuItems({
    required String restaurantId,
    required String query,
  });

  /// Get a single menu item
  Future<Either<Failure, MenuItemEntity>> getMenuItem({required String itemId});

  /// Stream menu items for real-time updates
  Stream<Either<Failure, List<MenuItemEntity>>> streamMenuItems({
    required String restaurantId,
  });
}
