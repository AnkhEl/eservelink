import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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

              // Navigate to history tab by showing home and switching to history tab
              context.read<SessionBloc>().add(ShowSessionHomeEvent());

              // After a brief delay, we'll need to switch to history tab
              // This will be handled by the HomeWrapper listening to a signal
              // For now, just navigate home and the user can manually go to history
              // OR we can emit a special event to auto-navigate to history tab
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              // Ping button
              ElevatedButton.icon(
                onPressed: () {
                  context.read<SessionBloc>().add(
                    SendPingEvent(
                      sessionId: widget.session.id,
                      customerId: widget.session.customerId,
                      customerName: widget.session.customerName,
                      tableNumber: _extractTableNumber(widget.session.tableId),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('Ping Waiter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 16),

              // More features coming
              Text(
                'Chat and Bill features coming soon!',
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
