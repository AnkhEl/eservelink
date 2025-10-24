import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eservelink/core/util/injection_container.dart' as di;
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/home/presentation/pages/Home.dart';
import 'package:eservelink/features/history/presentation/pages/history.dart';
import 'package:eservelink/features/profile/presentation/pages/profile.dart';
import 'package:eservelink/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_event.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_state.dart';
import 'package:eservelink/features/sessions/presentation/pages/session_waiting_page.dart';
import 'package:eservelink/features/sessions/presentation/pages/session_active_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> pages;

  late Home home;
  late History history;
  late Profile profile;

  int _currentTabIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    home = Home();
    history = History();
    profile = Profile();
    pages = [home, history, profile];
    super.initState();

    // Check for active session on init
    _checkForActiveSession();
  }

  void _checkForActiveSession() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<SessionBloc>().add(
        LoadActiveSessionEvent(authState.user.uid),
      );
    }
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
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionWaitingForWaiter) {
          // Navigate to waiting screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionWaitingPage(session: state.session),
            ),
          );
        } else if (state is SessionActive) {
          // Navigate to active session screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionActivePage(session: state.session),
            ),
          );
        } else if (state is SessionError) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is PingSent) {
          // Show ping confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Ping sent to waiter!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          height: 70,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          items: [
            Icon(Icons.home, color: Colors.white, size: 30),
            Icon(Icons.history, color: Colors.white, size: 30),
            Icon(Icons.person, color: Colors.white, size: 30),
          ],
        ),
        body: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, sessionState) {
            // Show loading overlay when creating session
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
                            children: [
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
