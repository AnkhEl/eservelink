import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:eservelink/features/menu/domain/entities/menu_category_entity.dart';
import 'package:eservelink/features/menu/domain/entities/menu_item_entity.dart';
import 'package:eservelink/features/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;

  MenuRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MenuCategoryEntity>>> getCategories({
    required String restaurantId,
  }) async {
    try {
      final categories = await remoteDataSource.getCategories(
        restaurantId: restaurantId,
      );
      return Right(categories.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems({
    required String restaurantId,
  }) async {
    try {
      final items = await remoteDataSource.getMenuItems(
        restaurantId: restaurantId,
      );
      return Right(items.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItemsByCategory({
    required String restaurantId,
    required String category,
  }) async {
    try {
      final items = await remoteDataSource.getMenuItemsByCategory(
        restaurantId: restaurantId,
        category: category,
      );
      return Right(items.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> searchMenuItems({
    required String restaurantId,
    required String query,
  }) async {
    try {
      final items = await remoteDataSource.searchMenuItems(
        restaurantId: restaurantId,
        query: query,
      );
      return Right(items.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> getMenuItem({
    required String itemId,
  }) async {
    try {
      final item = await remoteDataSource.getMenuItem(itemId: itemId);
      return Right(item.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<MenuItemEntity>>> streamMenuItems({
    required String restaurantId,
  }) {
    try {
      return remoteDataSource
          .streamMenuItems(restaurantId: restaurantId)
          .map(
            (items) => Right<Failure, List<MenuItemEntity>>(
              items.map((model) => model.toEntity()).toList(),
            ),
          )
          .handleError((error) {
            return Left<Failure, List<MenuItemEntity>>(
              ServerFailure(error.toString()),
            );
          });
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }
}
