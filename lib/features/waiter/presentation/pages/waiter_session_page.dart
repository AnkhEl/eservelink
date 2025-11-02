import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_bloc.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_event.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class WaiterSessionPage extends StatelessWidget {
  final WaiterSessionEntity session;

  const WaiterSessionPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_extractTableNumber()),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed:
              () => context.read<WaiterBloc>().add(ShowWaiterHomeEvent()),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: BlocListener<WaiterBloc, WaiterState>(
        listener: (context, state) {
          if (state is SessionEnded) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is WaiterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.person,
                        'Customer',
                        session.customerName,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.access_time,
                        'Duration',
                        _getDuration(),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.schedule,
                        'Started',
                        timeago.format(session.startTime),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.attach_money,
                        'Total',
                        'R ${session.totalAmount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.chat, color: Colors.blue),
                      title: const Text('Chat'),
                      subtitle: const Text('Message customer'),
                      trailing:
                          session.unreadMessages > 0
                              ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${session.unreadMessages}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              : const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat feature coming soon!'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.green,
                      ),
                      title: const Text('View Orders'),
                      subtitle: Text('${session.items.length} items'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order management coming soon!'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.payment, color: Colors.purple),
                      title: const Text('Request Payment'),
                      subtitle: const Text('Ask customer to pay'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment request coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // End Session Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEndSessionDialog(context),
                  icon: const Icon(Icons.done_all),
                  label: const Text(
                    'Complete Session',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Complete the session when the customer is ready to leave.',
                        style: TextStyle(color: Colors.blue[900], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _extractTableNumber() {
    final parts = session.tableId.split('_');
    if (parts.length >= 3) {
      return 'Table ${int.parse(parts[2])}';
    }
    return session.tableId;
  }

  String _getDuration() {
    final duration = DateTime.now().difference(session.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void _showEndSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Complete Session?'),
            content: Text(
              'Are you sure you want to complete this session for ${session.customerName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<WaiterBloc>().add(EndSessionEvent(session.id));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Complete'),
              ),
            ],
          ),
    );
  }
}
