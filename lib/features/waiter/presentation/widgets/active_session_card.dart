import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_bloc.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_event.dart';
import 'package:eservelink/features/waiter/presentation/pages/waiter_session_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActiveSessionCard extends StatelessWidget {
  final WaiterSessionEntity session;

  const ActiveSessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: session.hasPing ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            session.hasPing
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          context.read<WaiterBloc>().add(ShowWaiterSessionEvent(session));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          session.hasPing
                              ? Colors.red.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      session.hasPing
                          ? Icons.notifications_active
                          : Icons.play_circle,
                      color: session.hasPing ? Colors.red : Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Table info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _extractTableNumber(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.customerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time and ping indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getDuration(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (session.hasPing) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'PING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Session details
              Row(
                children: [
                  _buildInfoChip(
                    Icons.access_time,
                    timeago.format(session.startTime),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.attach_money,
                    'R ${session.totalAmount.toStringAsFixed(2)}',
                  ),
                  if (session.unreadMessages > 0) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.message,
                      '${session.unreadMessages}',
                      color: Colors.orange,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _extractTableNumber() {
    final parts = session.tableId.split('_');
    if (parts.length >= 3) {
      return 'Table ${int.parse(parts[2])}';
    }
    return session.tableId;
  }

  String _getDuration() {
    final duration = DateTime.now().difference(session.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
