import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/menu/data/models/menu_category_model.dart';
import 'package:eservelink/features/menu/data/models/menu_item_model.dart';

abstract class MenuRemoteDataSource {
  Future<List<MenuCategoryModel>> getCategories({required String restaurantId});

  Future<List<MenuItemModel>> getMenuItems({required String restaurantId});

  Future<List<MenuItemModel>> getMenuItemsByCategory({
    required String restaurantId,
    required String category,
  });

  Future<List<MenuItemModel>> searchMenuItems({
    required String restaurantId,
    required String query,
  });

  Future<MenuItemModel> getMenuItem({required String itemId});

  Stream<List<MenuItemModel>> streamMenuItems({required String restaurantId});
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final FirebaseFirestore firestore;

  MenuRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<MenuCategoryModel>> getCategories({
    required String restaurantId,
  }) async {
    try {
      print('📚 Fetching categories for restaurant: $restaurantId');

      final querySnapshot =
          await firestore
              .collection('menu_categories')
              .where('restaurantId', isEqualTo: restaurantId)
              .orderBy('order')
              .get();

      final categories =
          querySnapshot.docs
              .map((doc) => MenuCategoryModel.fromFirestore(doc))
              .toList();

      print('✅ Fetched ${categories.length} categories');
      return categories;
    } catch (e) {
      print('❌ Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItems({
    required String restaurantId,
  }) async {
    try {
      print('🍽️ Fetching menu items for restaurant: $restaurantId');

      final querySnapshot =
          await firestore
              .collection('menu_items')
              .where('restaurantId', isEqualTo: restaurantId)
              .where('isAvailable', isEqualTo: true)
              .orderBy('category')
              .orderBy('name')
              .get();

      final items =
          querySnapshot.docs
              .map((doc) => MenuItemModel.fromFirestore(doc))
              .toList();

      print('✅ Fetched ${items.length} menu items');
      return items;
    } catch (e) {
      print('❌ Error fetching menu items: $e');
      throw Exception('Failed to fetch menu items: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByCategory({
    required String restaurantId,
    required String category,
  }) async {
    try {
      print('🍽️ Fetching items for category: $category');

      final querySnapshot =
          await firestore
              .collection('menu_items')
              .where('restaurantId', isEqualTo: restaurantId)
              .where('category', isEqualTo: category)
              .where('isAvailable', isEqualTo: true)
              .orderBy('name')
              .get();

      final items =
          querySnapshot.docs
              .map((doc) => MenuItemModel.fromFirestore(doc))
              .toList();

      print('✅ Fetched ${items.length} items in category');
      return items;
    } catch (e) {
      print('❌ Error fetching items by category: $e');
      throw Exception('Failed to fetch items by category: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> searchMenuItems({
    required String restaurantId,
    required String query,
  }) async {
    try {
      print('🔍 Searching menu items: $query');

      // Get all items for the restaurant
      final querySnapshot =
          await firestore
              .collection('menu_items')
              .where('restaurantId', isEqualTo: restaurantId)
              .where('isAvailable', isEqualTo: true)
              .get();

      // Filter by search query (case-insensitive)
      final searchLower = query.toLowerCase();
      final items =
          querySnapshot.docs
              .map((doc) => MenuItemModel.fromFirestore(doc))
              .where(
                (item) =>
                    item.name.toLowerCase().contains(searchLower) ||
                    item.description.toLowerCase().contains(searchLower),
              )
              .toList();

      print('✅ Found ${items.length} matching items');
      return items;
    } catch (e) {
      print('❌ Error searching menu items: $e');
      throw Exception('Failed to search menu items: $e');
    }
  }

  @override
  Future<MenuItemModel> getMenuItem({required String itemId}) async {
    try {
      print('📖 Fetching menu item: $itemId');

      final doc = await firestore.collection('menu_items').doc(itemId).get();

      if (!doc.exists) {
        throw Exception('Menu item not found');
      }

      final item = MenuItemModel.fromFirestore(doc);
      print('✅ Fetched menu item: ${item.name}');
      return item;
    } catch (e) {
      print('❌ Error fetching menu item: $e');
      throw Exception('Failed to fetch menu item: $e');
    }
  }

  @override
  Stream<List<MenuItemModel>> streamMenuItems({required String restaurantId}) {
    print('🔄 Streaming menu items for restaurant: $restaurantId');

    return firestore
        .collection('menu_items')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('category')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          print('🔄 Menu items stream updated: ${snapshot.docs.length} items');
          return snapshot.docs
              .map((doc) => MenuItemModel.fromFirestore(doc))
              .toList();
        });
  }
}
