import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_event.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_state.dart';
import 'package:eservelink/features/sessions/presentation/pages/session_active_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class SessionWaitingPage extends StatelessWidget {
  final SessionEntity session;

  const SessionWaitingPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionActive) {
          // Waiter joined! Navigate to active session
          context.read<SessionBloc>().add(ShowSessionActiveEvent(state.session));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Table ${_extractTableNumber(session.tableId)}'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          leading: IconButton(
              onPressed: (){
                context.read<SessionBloc>().add(ShowSessionHomeEvent());
              },
              icon: Icon(Icons.arrow_back)
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _showCancelDialog(context),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading animation
                // You can replace this with Lottie animation if you have one
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    color: Colors.deepPurple,
                  ),
                ),

                SizedBox(height: 40),

                // Title
                Text(
                  'Waiting for Waiter',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16),

                // Description
                Text(
                  'Your table session has been created!\nA waiter will join shortly to assist you.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40),

                // Session info card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.table_restaurant,
                          'Table',
                          _extractTableNumber(session.tableId),
                        ),
                        Divider(height: 24),
                        _buildInfoRow(
                          Icons.person,
                          'Customer',
                          session.customerName,
                        ),
                        Divider(height: 24),
                        _buildInfoRow(
                          Icons.access_time,
                          'Started',
                          _formatTime(session.startTime),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Tip text
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Once a waiter scans your table QR, you\'ll be connected!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 24),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _extractTableNumber(String tableId) {
    // Extract table number from ID like "T_rest123_005" → "Table 5"
    final parts = tableId.split('_');
    if (parts.length >= 3) {
      return 'Table ${int.parse(parts[2])}';
    }
    return tableId;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}m ago';
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Cancel Session?'),
            content: Text(
              'Are you sure you want to cancel this session? You\'ll need to scan the QR code again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('No, Wait'),
              ),
              TextButton(
                onPressed: () {
                  context.read<SessionBloc>().add(
                    CancelSessionEvent(session.id),
                  );
                  Navigator.pop(dialogContext); // Close dialog
                  context.read<SessionBloc>().add(ShowSessionHomeEvent());
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Yes, Cancel'),
              ),
            ],
          ),
    );
  }
}
