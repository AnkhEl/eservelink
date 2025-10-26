import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class SessionHistoryCard extends StatelessWidget {
  final SessionEntity session;

  const SessionHistoryCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showSessionDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Restaurant & Table Info
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
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeago.format(session.startTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (session.endTime != null)
                        Text(
                          _getDuration(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Details Row
              Row(
                children: [
                  // Waiter Info
                  Expanded(
                    child: _buildInfoChip(
                      Icons.person,
                      session.waiterName ?? 'No waiter',
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Total Amount
                  _buildInfoChip(
                    Icons.attach_money,
                    'R ${session.totalAmount.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
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

  String _getStatusText() {
    switch (session.status) {
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.active:
        return 'Active';
      case SessionStatus.waitingForWaiter:
        return 'Waiting';
      case SessionStatus.paymentRequested:
        return 'Payment Requested';
    }
  }

  Color _getStatusColor() {
    switch (session.status) {
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.cancelled:
        return Colors.red;
      case SessionStatus.active:
        return Colors.blue;
      case SessionStatus.waitingForWaiter:
        return Colors.orange;
      case SessionStatus.paymentRequested:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon() {
    switch (session.status) {
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.cancelled:
        return Icons.cancel;
      case SessionStatus.active:
        return Icons.play_circle;
      case SessionStatus.waitingForWaiter:
        return Icons.hourglass_empty;
      case SessionStatus.paymentRequested:
        return Icons.payment;
    }
  }

  String _getDuration() {
    if (session.endTime == null) return '';
    final duration = session.endTime!.difference(session.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void _showSessionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // This empty onTap allows taps outside the draggable area to dismiss
            Navigator.of(context).pop();
          },
          child: GestureDetector(
            onTap: () {}, // Prevent taps inside from closing
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Session Details',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildDetailRow('Table', _extractTableNumber()),
                              _buildDetailRow('Status', _getStatusText()),
                              _buildDetailRow('Customer', session.customerName),
                              _buildDetailRow(
                                'Waiter',
                                session.waiterName ?? 'No waiter assigned',
                              ),
                              _buildDetailRow(
                                'Started',
                                _formatDateTime(session.startTime),
                              ),
                              if (session.endTime != null)
                                _buildDetailRow(
                                  'Ended',
                                  _formatDateTime(session.endTime!),
                                ),
                              _buildDetailRow(
                                'Duration',
                                session.endTime != null
                                    ? _getDuration()
                                    : 'Ongoing',
                              ),
                              _buildDetailRow(
                                'Total Amount',
                                'R ${session.totalAmount.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }


  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
