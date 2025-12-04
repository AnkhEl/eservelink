import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/orders/presentation/bloc/cart/cart_bloc.dart';
import 'package:eservelink/features/orders/presentation/bloc/cart/cart_event.dart';
import 'package:eservelink/features/orders/presentation/bloc/cart/cart_state.dart';
import 'package:eservelink/features/orders/presentation/bloc/order/order_bloc.dart';
import 'package:eservelink/features/orders/presentation/bloc/order/order_event.dart';
import 'package:eservelink/features/orders/presentation/bloc/order/order_state.dart';
import 'package:eservelink/features/orders/presentation/widgets/cart_item_widget.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartPage extends StatelessWidget {
  final SessionEntity session;

  const CartPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear cart',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderSubmitted) {
            // Clear cart after successful submission
            context.read<CartBloc>().add(const ClearCartEvent());

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order submitted successfully! 🎉'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back
            Navigator.pop(context);
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, orderState) {
          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is CartEmpty) {
                return _buildEmptyCart(context);
              }

              if (cartState is CartLoaded) {
                return Column(
                  children: [
                    // Cart items list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartState.items.length,
                        itemBuilder: (context, index) {
                          final item = cartState.items[index];
                          return CartItemWidget(
                            cartItem: item,
                            onIncrement: () {
                              context.read<CartBloc>().add(
                                IncrementCartItemEvent(item.menuItem.id),
                              );
                            },
                            onDecrement: () {
                              context.read<CartBloc>().add(
                                DecrementCartItemEvent(item.menuItem.id),
                              );
                            },
                            onRemove: () {
                              context.read<CartBloc>().add(
                                RemoveFromCartEvent(item.menuItem.id),
                              );
                            },
                            onUpdateInstructions: (instructions) {
                              context.read<CartBloc>().add(
                                UpdateCartItemInstructionsEvent(
                                  menuItemId: item.menuItem.id,
                                  specialInstructions: instructions,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Summary and submit button
                    _buildCartSummary(context, cartState, orderState),
                  ],
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from the menu to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Browse Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    CartLoaded cartState,
    OrderState orderState,
  ) {
    final isLoading = orderState is OrderLoading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal
            _buildSummaryRow(
              'Subtotal',
              'R ${cartState.subtotal.toStringAsFixed(2)}',
              false,
            ),
            const SizedBox(height: 8),

            // Tax
            _buildSummaryRow(
              'Tax (15%)',
              'R ${cartState.tax.toStringAsFixed(2)}',
              false,
            ),
            const Divider(height: 24),

            // Total
            _buildSummaryRow(
              'Total',
              'R ${cartState.total.toStringAsFixed(2)}',
              true,
            ),
            const SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isLoading
                        ? null
                        : () {
                          _submitOrder(context, cartState);
                        },
                icon:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.send),
                label: Text(
                  isLoading ? 'Submitting...' : 'Submit Order',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Colors.deepPurple : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _submitOrder(BuildContext context, CartLoaded cartState) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    // Get cart items from CartBloc
    final cartItems = context.read<CartBloc>().getCartItems();

    context.read<OrderBloc>().add(
      SubmitOrderEvent(
        sessionId: session.id,
        customerId: session.customerId,
        customerName: session.customerName,
        waiterId: session.waiterId ?? '',
        waiterName: session.waiterName ?? '',
        restaurantId: session.restaurantId,
        cartItems: cartItems,
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Clear Cart?'),
            content: const Text(
              'Are you sure you want to remove all items from your cart?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<CartBloc>().add(const ClearCartEvent());
                  Navigator.pop(dialogContext);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }
}
