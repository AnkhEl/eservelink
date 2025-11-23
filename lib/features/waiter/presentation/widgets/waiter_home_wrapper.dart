import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_event.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_state.dart';
import 'package:eservelink/features/notifications/presentation/widgets/notification_toast.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_bloc.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_state.dart';
import 'package:eservelink/features/waiter/presentation/pages/waiter_home_page.dart';
import 'package:eservelink/features/waiter/presentation/pages/waiter_session_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    print('🔔 Showing toast for notification: ${notification.id}');

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
