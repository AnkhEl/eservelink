import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_bloc.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_event.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_state.dart';
import 'package:eservelink/features/waiter/presentation/widgets/waiting_session_card.dart';
import 'package:eservelink/features/waiter/presentation/widgets/active_session_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaiterHomePage extends StatefulWidget {
  const WaiterHomePage({super.key});

  @override
  State<WaiterHomePage> createState() => _WaiterHomePageState();
}

class _WaiterHomePageState extends State<WaiterHomePage> {
  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      final user = authState.user;

      // Load waiting sessions for the restaurant
      context.read<WaiterBloc>().add(
        LoadWaitingSessionsEvent(user.restaurantId ?? ''),
      );

      // Load waiter's active sessions
      context.read<WaiterBloc>().add(LoadWaiterActiveSessionsEvent(user.uid));
    }
  }

  Future<void> _handleQrScan() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    final scannedTableId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerPage()),
    );

    if (scannedTableId != null && mounted) {
      context.read<WaiterBloc>().add(
        JoinSessionEvent(
          tableId: scannedTableId,
          waiterId: authState.user.uid,
          waiterName: authState.user.displayName ?? 'Waiter',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Waiter Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthSuccess) {
                context.read<WaiterBloc>().add(
                  RefreshSessionsEvent(
                    waiterId: authState.user.uid,
                    restaurantId: authState.user.restaurantId ?? '',
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<WaiterBloc, WaiterState>(
        listener: (context, state) {
          if (state is WaiterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SessionJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully joined session!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadSessions(); // Refresh after joining
          } else if (state is SessionEnded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _loadSessions(); // Refresh after ending
          }
        },
        builder: (context, state) {
          if (state is WaiterLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (state is WaiterSessionsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess) {
                  context.read<WaiterBloc>().add(
                    RefreshSessionsEvent(
                      waiterId: authState.user.uid,
                      restaurantId: authState.user.restaurantId ?? '',
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.hourglass_empty,
                            label: 'Waiting',
                            value: state.waitingSessions.length.toString(),
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.restaurant,
                            label: 'Active',
                            value: state.activeSessions.length.toString(),
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.notifications_active,
                            label: 'Pings',
                            value: state.totalPings.toString(),
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Waiting Sessions
                    if (state.waitingSessions.isNotEmpty) ...[
                      const Text(
                        'Waiting for Waiter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.waitingSessions.map(
                        (session) => WaitingSessionCard(session: session),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Active Sessions
                    if (state.activeSessions.isNotEmpty) ...[
                      const Text(
                        'Your Active Sessions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.activeSessions.map(
                        (session) => ActiveSessionCard(session: session),
                      ),
                    ],

                    // Empty State
                    if (state.waitingSessions.isEmpty &&
                        state.activeSessions.isEmpty) ...[
                      const SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sessions available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scan a QR code to join a session',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleQrScan,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan Table'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
