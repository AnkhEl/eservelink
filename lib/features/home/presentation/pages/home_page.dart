import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eservelink/core/util/injection_container.dart' as di;
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/chat/presentation/pages/chat_page.dart';
import 'package:eservelink/features/home/presentation/pages/Home.dart';
import 'package:eservelink/features/history/presentation/pages/history.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_event.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_state.dart';
import 'package:eservelink/features/notifications/presentation/pages/notification_center_page.dart';
import 'package:eservelink/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:eservelink/features/notifications/presentation/widgets/notification_toast.dart';
import 'package:eservelink/features/profile/presentation/pages/profile.dart';
import 'package:eservelink/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'package:eservelink/features/sessions/data/models/session_model.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_event.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> pages;
  static bool _hasCheckedSession = false;
  String? _lastShownNotificationId;

  late Home home;
  late History history;
  late Profile profile;

  int _currentTabIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    home = const Home();
    history = const History();
    profile = const Profile();
    pages = [home, history, profile];
    super.initState();

    // Check for active session on init
    _checkForActiveSession();

    // Start listening to notifications
    _startListeningToNotifications();
  }

  void _checkForActiveSession() {
    if (_hasCheckedSession) return;
    _hasCheckedSession = true;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<SessionBloc>().add(
        LoadActiveSessionEvent(authState.user.uid),
      );
    }
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
    if (_lastShownNotificationId == notification.id) {
      return;
    }

    print('🔔 [Customer] Showing toast for notification: ${notification.id}');
    _lastShownNotificationId = notification.id;

    NotificationToast.show(
      context: context,
      notification: notification,
      onTap: () {
        print(
          '🔔 [Customer] Toast tapped for notification: ${notification.id}',
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

    print('💬 [Customer] Navigating to chat for session: $sessionId');

    try {
      // Fetch session to get waiter name and table number
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
      final waiterName = sessionData['waiterName'] as String?;
      final tableId = sessionData['tableId'] as String;
      final tableNumber = _extractTableNumber(tableId);

      // Navigate to chat page
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => ChatPage(
                  sessionId: sessionId,
                  otherUserName: senderName ?? waiterName ?? 'Waiter',
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
    print('🔍 [Customer] Fetching session: $sessionId');

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

      final sessionData = sessionDoc.data()!;

      // Check if session is active
      final status = sessionData['status'] as String;
      if (status != 'active') {
        print('⚠️ Session is not active (status: $status)');
        return;
      }

      // Create SessionEntity from Firestore data
      final session = SessionModel.fromFirestore(sessionDoc).toEntity();

      print('✅ Session fetched, navigating to session active page');

      // Navigate to session active page
      if (mounted) {
        context.read<SessionBloc>().add(ShowSessionActiveEvent(session));
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

  Future<void> _handleQrScan() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    // Navigate to QR scanner
    final scannedTableId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerPage()),
    );

    if (scannedTableId != null && mounted) {
      // Create session with scanned table ID
      context.read<SessionBloc>().add(
        CreateSessionEvent(
          tableId: scannedTableId,
          customerId: authState.user.uid,
          customerName: authState.user.displayName ?? 'Guest',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Session listener
        BlocListener<SessionBloc, SessionState>(
          listener: (context, state) {
            if (state is SessionWaitingForWaiter) {
              context.read<SessionBloc>().add(
                ShowSessionWaitingEvent(state.session),
              );
            } else if (state is SessionActive) {
              context.read<SessionBloc>().add(
                ShowSessionActiveEvent(state.session),
              );
            } else if (state is SessionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is PingSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Ping sent to waiter!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
        // Notification listener
        BlocListener<NotificationBloc, NotificationState>(
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
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // Notification bell with badge
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
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          height: 70,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: const Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          items: const [
            Icon(Icons.home, color: Colors.white, size: 30),
            Icon(Icons.history, color: Colors.white, size: 30),
            Icon(Icons.person, color: Colors.white, size: 30),
          ],
        ),
        body: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, sessionState) {
            return Stack(
              children: [
                IndexedStack(index: _currentTabIndex, children: pages),
                if (sessionState is SessionCreating)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(
                                color: Colors.deepPurple,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Creating session...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton:
            _currentTabIndex == 0
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton(
                    onPressed: _handleQrScan,
                    child: const Icon(Icons.qr_code),
                  ),
                )
                : null,
      ),
    );
  }
}
