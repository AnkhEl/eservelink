import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/chat/presentation/pages/chat_page.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_event.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_state.dart';
import 'package:eservelink/features/notifications/presentation/widgets/notification_toast.dart';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_bloc.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_event.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_state.dart';
import 'package:eservelink/features/waiter/presentation/pages/waiter_home_page.dart';
import 'package:eservelink/features/waiter/presentation/pages/waiter_session_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eservelink/features/waiter/data/models/waiter_session_model.dart';

class WaiterHomeWrapper extends StatefulWidget {
  const WaiterHomeWrapper({super.key});

  @override
  State<WaiterHomeWrapper> createState() => _WaiterHomeWrapperState();
}

class _WaiterHomeWrapperState extends State<WaiterHomeWrapper> {
  String? _lastShownNotificationId;

  @override
  void initState() {
    super.initState();
    _startListeningToNotifications();
  }

  void _startListeningToNotifications() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<NotificationBloc>().add(
        StartListeningToNotificationsEvent(authState.user.uid),
      );
    }
  }

  void _showToastForNotification(NotificationEntity notification) {
    // Don't show toast if we already showed it for this notification
    if (_lastShownNotificationId == notification.id) {
      return;
    }

    print(
      '🔔 [WaiterWrapper] Showing toast for notification: ${notification.id}',
    );

    _lastShownNotificationId = notification.id;

    NotificationToast.show(
      context: context,
      notification: notification,
      onTap: () {
        print(
          '🔔 [WaiterWrapper] Toast tapped for notification: ${notification.id}',
        );

        // Mark as read
        context.read<NotificationBloc>().add(
          MarkNotificationReadEvent(notification.id),
        );

        // Navigate based on notification type
        _handleNotificationNavigation(notification);
      },
    );
  }

  Future<void> _handleNotificationNavigation(
    NotificationEntity notification,
  ) async {
    // Get session ID from notification data
    final sessionId = notification.data['sessionId'] as String?;
    if (sessionId == null) {
      print('❌ No sessionId in notification data');
      return;
    }

    // For message notifications, navigate directly to chat
    if (notification.type == NotificationType.message) {
      _navigateToChat(notification);
      return;
    }

    // For ping notifications, navigate to session page
    if (notification.type == NotificationType.ping ||
        notification.type == NotificationType.pingAcknowledged) {
      _navigateToSession(sessionId);
      return;
    }
  }

  Future<void> _navigateToChat(NotificationEntity notification) async {
    final sessionId = notification.data['sessionId'] as String?;
    final senderName = notification.data['senderName'] as String?;

    if (sessionId == null) {
      print('❌ No sessionId for chat navigation');
      return;
    }

    print('💬 [WaiterWrapper] Navigating to chat for session: $sessionId');

    try {
      // Fetch session to get table number
      final sessionDoc =
          await FirebaseFirestore.instance
              .collection('sessions')
              .doc(sessionId)
              .get();

      if (!sessionDoc.exists) {
        print('❌ Session not found: $sessionId');
        return;
      }

      final sessionData = sessionDoc.data()!;
      final tableId = sessionData['tableId'] as String;
      final tableNumber = _extractTableNumber(tableId);

      // Navigate to chat page
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => ChatPage(
                  sessionId: sessionId,
                  otherUserName: senderName ?? 'Customer',
                  tableNumber: tableNumber,
                ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error navigating to chat: $e');
    }
  }

  Future<void> _navigateToSession(String sessionId) async {
    print('🔍 [WaiterWrapper] Fetching session: $sessionId');

    try {
      // Fetch session from Firestore
      final sessionDoc =
          await FirebaseFirestore.instance
              .collection('sessions')
              .doc(sessionId)
              .get();

      if (!sessionDoc.exists) {
        print('❌ Session not found: $sessionId');
        return;
      }

      final session = WaiterSessionModel.fromFirestore(sessionDoc).toEntity();

      print('✅ Session fetched, navigating to session page');

      // Navigate to session page
      if (mounted) {
        context.read<WaiterBloc>().add(ShowWaiterSessionEvent(session));
      }
    } catch (e) {
      print('❌ Error fetching session: $e');
    }
  }

  String _extractTableNumber(String tableId) {
    final parts = tableId.split('_');
    if (parts.length >= 3) {
      return 'Table ${int.parse(parts[2])}';
    }
    return tableId;
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

            // Show toast for the latest unread notification if we haven't shown it yet
            _showToastForNotification(latestNotification);
          }
        }
      },
      child: BlocBuilder<WaiterBloc, WaiterState>(
        builder: (context, state) {
          if (state is ShowWaiterSessionPage) {
            return WaiterSessionPage(session: state.session);
          }
          if (state is ShowWaiterHomePage) {
            return const WaiterHomePage();
          }
          return const WaiterHomePage();
        },
      ),
    );
  }
}
