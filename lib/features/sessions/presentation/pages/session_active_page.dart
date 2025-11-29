import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/core/util/injection_container.dart' as di;
import 'package:eservelink/features/chat/presentation/pages/chat_page.dart';
import 'package:eservelink/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:eservelink/features/menu/presentation/pages/menu_browse_page.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_event.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_state.dart';
import 'package:eservelink/features/notifications/presentation/widgets/notification_toast.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SessionActivePage extends StatefulWidget {
  final SessionEntity session;

  const SessionActivePage({super.key, required this.session});

  @override
  State<SessionActivePage> createState() => _SessionActivePageState();
}

class _SessionActivePageState extends State<SessionActivePage> {
  StreamSubscription<DocumentSnapshot>? _sessionSubscription;
  String? _lastShownNotificationId;

  @override
  void initState() {
    super.initState();
    _listenToSessionChanges();
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  void _listenToSessionChanges() {
    _sessionSubscription = FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.session.id)
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists) {
            return;
          }

          final data = snapshot.data();
          if (data == null) return;

          final status = data['status'] as String?;

          // If session is completed, navigate to history
          if (status == 'completed') {
            if (mounted) {
              // Show completion message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Session completed! Thank you for dining with us.',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );

              // Navigate to home
              context.read<SessionBloc>().add(ShowSessionHomeEvent());
            }
          }
        });
  }

  void _showToastForNotification(NotificationEntity notification) {
    // Don't show toast if we already showed it for this notification
    if (_lastShownNotificationId == notification.id) {
      return;
    }

    print(
      '🔔 [SessionActivePage] Showing toast for notification: ${notification.id}',
    );

    _lastShownNotificationId = notification.id;

    NotificationToast.show(
      context: context,
      notification: notification,
      onTap: () {
        print('🔔 [SessionActivePage] Toast tapped');

        // Mark as read
        context.read<NotificationBloc>().add(
          MarkNotificationReadEvent(notification.id),
        );

        // Navigate to chat if it's a message notification
        if (notification.type == NotificationType.message) {
          _navigateToChat(notification);
        }
        // Otherwise, we're already on the session page, so do nothing
      },
    );
  }

  Future<void> _navigateToChat(NotificationEntity notification) async {
    final senderName = notification.data['senderName'] as String?;

    print('💬 [SessionActivePage] Opening chat');

    // We already have session data, so just navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatPage(
              sessionId: widget.session.id,
              otherUserName:
                  senderName ?? widget.session.waiterName ?? "Waiter",
              tableNumber: _extractTableNumber(widget.session.tableId),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationsLoaded) {
          // Get the most recent unread notification
          final unreadNotifications =
              state.notifications.where((n) => !n.isRead).toList();

          if (unreadNotifications.isNotEmpty) {
            final latestNotification = unreadNotifications.first;
            _showToastForNotification(latestNotification);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text('Table ${_extractTableNumber(widget.session.tableId)}'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              context.read<SessionBloc>().add(ShowSessionHomeEvent());
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Session Active Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Session Active',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Table ${_extractTableNumber(widget.session.tableId)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Waiter Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          (widget.session.waiterName ?? 'W')[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Waiter',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.session.waiterName ?? 'Waiter',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions Title
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Chat Action Card
              _buildActionCard(
                icon: Icons.chat_bubble_outline,
                title: 'Chat with Waiter',
                subtitle: 'Send a message instantly',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatPage(
                            sessionId: widget.session.id,
                            otherUserName:
                                widget.session.waiterName ?? "Waiter",
                            tableNumber: _extractTableNumber(
                              widget.session.tableId,
                            ),
                          ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Ping Action Card with Real-time Check
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('pings')
                        .where('sessionId', isEqualTo: widget.session.id)
                        .where('isAcknowledged', isEqualTo: false)
                        .limit(1)
                        .snapshots(),
                builder: (context, snapshot) {
                  final hasPendingPing =
                      snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                  return _buildActionCard(
                    icon:
                        hasPendingPing
                            ? Icons.hourglass_empty
                            : Icons.notifications_active,
                    title:
                        hasPendingPing
                            ? 'Ping Sent - Waiting...'
                            : 'Ping Waiter',
                    subtitle:
                        hasPendingPing
                            ? 'Waiter has been notified'
                            : 'Need immediate attention?',
                    color: hasPendingPing ? Colors.grey : Colors.deepPurple,
                    onTap:
                        hasPendingPing
                            ? null
                            : () {
                              context.read<SessionBloc>().add(
                                SendPingEvent(
                                  sessionId: widget.session.id,
                                  customerId: widget.session.customerId,
                                  customerName: widget.session.customerName,
                                  tableNumber: _extractTableNumber(
                                    widget.session.tableId,
                                  ),
                                ),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ping sent! Waiter will be with you shortly.',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                  );
                },
              ),

              const SizedBox(height: 24),

              // Coming Soon Section
              const Text(
                'Coming Soon',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Menu Card (Disabled)
              _buildActionCard(
                icon: Icons.restaurant_menu,
                title: 'Browse Menu',
                subtitle: 'View available items',
                color: Colors.orange,
                isDisabled: false, // Changed from true to false
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BlocProvider(
                            create: (context) => di.sl<MenuBloc>(),
                            child: MenuBrowsePage(
                              restaurantId:
                                  widget
                                      .session
                                      .restaurantId, // You'll need to add this field
                              restaurantName:
                                  'Restaurant Menu', // Or pass restaurant name
                            ),
                          ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Bill Card (Disabled)
              _buildActionCard(
                icon: Icons.receipt_long,
                title: 'View Bill',
                subtitle: 'Check your current total',
                color: Colors.green,
                isDisabled: true,
                onTap: null,
              ),

              const SizedBox(height: 24),

              // Info Card
              Card(
                elevation: 1,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your session is active. Feel free to chat with your waiter or browse the menu when available.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Card(
      elevation: isDisabled ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isDisabled
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDisabled
                          ? Colors.grey.shade200
                          : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDisabled ? Colors.grey.shade400 : color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isDisabled ? Colors.grey.shade500 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDisabled
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDisabled)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Soon',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractTableNumber(String tableId) {
    final parts = tableId.split('_');
    if (parts.length >= 3) {
      return 'Table ${int.parse(parts[2])}';
    }
    return tableId;
  }
}
