import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_state.dart';
import 'package:eservelink/features/notifications/presentation/pages/notification_center_page.dart';
import 'package:eservelink/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:eservelink/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_bloc.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_event.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_state.dart';
import 'package:eservelink/features/waiter/presentation/pages/waiter_session_page.dart';
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
  // Cache the last known sessions for intermediate states
  List<dynamic> _cachedWaitingSessions = [];
  List<dynamic> _cachedActiveSessions = [];

  @override
  void initState() {
    super.initState();
    _startWatchingSessions();
  }

  @override
  void dispose() {
    // Stop watching when page is disposed
    context.read<WaiterBloc>().add(StopWatchingSessionsEvent());
    super.dispose();
  }

  void _startWatchingSessions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      final user = authState.user;

      // Start watching sessions in real-time
      context.read<WaiterBloc>().add(
        StartWatchingSessionsEvent(
          restaurantId: user.restaurantId ?? '',
          waiterId: user.uid,
        ),
      );
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
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              final unreadCount =
                  state is NotificationsLoaded ? state.unreadCount : 0;

              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationCenterPage(),
                    ),
                  );
                },
                icon: BadgedWidget(
                  badgeCount: unreadCount,
                  child: const Icon(Icons.notifications),
                ),
              );
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
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully joined session!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate to the session detail page
            context.read<WaiterBloc>().add(
              ShowWaiterSessionEvent(state.session),
            );
          } else if (state is SessionEnded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is WaiterSessionsLoaded) {
            // Cache sessions whenever we get a loaded state
            _cachedWaitingSessions = state.waitingSessions;
            _cachedActiveSessions = state.activeSessions;
          }
        },
        builder: (context, state) {
          // Handle all states that should show the dashboard
          List<dynamic> waitingSessions = [];
          List<dynamic> activeSessions = [];
          bool isLoading = false;

          if (state is WaiterLoading) {
            // Show loading with cached sessions
            waitingSessions = _cachedWaitingSessions;
            activeSessions = _cachedActiveSessions;
            isLoading = true;
          } else if (state is WaiterSessionsLoaded) {
            waitingSessions = state.waitingSessions;
            activeSessions = state.activeSessions;
          } else if (state is SessionJoined || state is SessionEnded) {
            // Show cached sessions during intermediate states
            waitingSessions = _cachedWaitingSessions;
            activeSessions = _cachedActiveSessions;
          } else if (state is WaiterError) {
            // Show cached sessions even on error
            waitingSessions = _cachedWaitingSessions;
            activeSessions = _cachedActiveSessions;
          }

          // Build the dashboard UI
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  // Streams handle updates automatically
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sessions update automatically'),
                      duration: Duration(seconds: 1),
                    ),
                  );
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
                              value: waitingSessions.length.toString(),
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.restaurant,
                              label: 'Active',
                              value: activeSessions.length.toString(),
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.notifications_active,
                              label: 'Pings',
                              value:
                                  _calculateTotalPings(
                                    activeSessions,
                                  ).toString(),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Waiting Sessions
                      if (waitingSessions.isNotEmpty) ...[
                        const Text(
                          'Waiting for Waiter',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...waitingSessions.map(
                          (session) => WaitingSessionCard(session: session),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Active Sessions
                      if (activeSessions.isNotEmpty) ...[
                        const Text(
                          'Your Active Sessions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...activeSessions.map(
                          (session) => ActiveSessionCard(session: session),
                        ),
                      ],

                      // Empty State
                      if (waitingSessions.isEmpty &&
                          activeSessions.isEmpty) ...[
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
              ),

              // Loading overlay (only when truly loading, not during state transitions)
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  ),
                ),
            ],
          );
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

  int _calculateTotalPings(List<dynamic> sessions) {
    return sessions.where((session) => session.hasPing == true).length;
  }
}
