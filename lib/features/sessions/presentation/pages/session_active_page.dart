import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/chat/presentation/pages/chat_page.dart';
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
        // Mark as read
        context.read<NotificationBloc>().add(
          MarkNotificationReadEvent(notification.id),
        );
      },
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
        appBar: AppBar(
          title: Text('Table ${_extractTableNumber(widget.session.tableId)}'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              context.read<SessionBloc>().add(ShowSessionHomeEvent());
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 100),
                const SizedBox(height: 24),
                const Text(
                  'Session Active!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Connected with ${widget.session.waiterName}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),

                // Chat button
                ElevatedButton.icon(
                  onPressed: () {
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
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat with Waiter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 16),

                // Ping button with pending check
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

                    return Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              hasPendingPing
                                  ? null
                                  : () {
                                    context.read<SessionBloc>().add(
                                      SendPingEvent(
                                        sessionId: widget.session.id,
                                        customerId: widget.session.customerId,
                                        customerName:
                                            widget.session.customerName,
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
                          icon: Icon(
                            hasPendingPing
                                ? Icons.hourglass_empty
                                : Icons.notifications_active,
                          ),
                          label: Text(
                            hasPendingPing
                                ? 'Ping Sent - Waiting...'
                                : 'Ping Waiter',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                hasPendingPing
                                    ? Colors.grey
                                    : Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                        if (hasPendingPing) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Waiter has been notified',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // More features coming
                Text(
                  'Bill features coming soon!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
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
