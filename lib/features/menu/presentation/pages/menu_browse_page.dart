import 'package:eservelink/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:eservelink/features/menu/presentation/bloc/menu_event.dart';
import 'package:eservelink/features/menu/presentation/bloc/menu_state.dart';
import 'package:eservelink/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuBrowsePage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const MenuBrowsePage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<MenuBrowsePage> createState() => _MenuBrowsePageState();
}

class _MenuBrowsePageState extends State<MenuBrowsePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load menu when page opens
    context.read<MenuBloc>().add(LoadMenuEvent(widget.restaurantId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.restaurantName),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is MenuLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (state is MenuError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load menu',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MenuBloc>().add(
                        LoadMenuEvent(widget.restaurantId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is MenuLoaded) {
            return Column(
              children: [
                // Search Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search menu items...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<MenuBloc>().add(
                                    const ClearSearchEvent(),
                                  );
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (query) {
                      context.read<MenuBloc>().add(SearchMenuItemsEvent(query));
                    },
                  ),
                ),

                // Category Chips
                if (state.categories.isNotEmpty)
                  Container(
                    height: 60,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // "All" chip
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: state.selectedCategory == null,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<MenuBloc>().add(
                                  const FilterByCategoryEvent('All'),
                                );
                              }
                            },
                            selectedColor: Colors.deepPurple,
                            labelStyle: TextStyle(
                              color:
                                  state.selectedCategory == null
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                          ),
                        ),
                        // Category chips
                        ...state.categories.map((category) {
                          final isSelected =
                              state.selectedCategory == category.name;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  context.read<MenuBloc>().add(
                                    FilterByCategoryEvent(category.name),
                                  );
                                }
                              },
                              selectedColor: Colors.deepPurple,
                              labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Menu Items Grid
                Expanded(
                  child:
                      state.displayedItems.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.searchQuery != null
                                      ? 'No items found'
                                      : 'No items in this category',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                          : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: state.displayedItems.length,
                            itemBuilder: (context, index) {
                              final item = state.displayedItems[index];
                              return MenuItemCard(item: item);
                            },
                          ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
