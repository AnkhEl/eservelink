import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:flutter/material.dart';

class OrderStatusWidget extends StatelessWidget {
  final OrderSubmissionStatus status;

  const OrderStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case OrderSubmissionStatus.pending:
        return Colors.orange;
      case OrderSubmissionStatus.confirmed:
        return Colors.blue;
      case OrderSubmissionStatus.preparing:
        return Colors.purple;
      case OrderSubmissionStatus.served:
        return Colors.green;
      case OrderSubmissionStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case OrderSubmissionStatus.pending:
        return Icons.hourglass_empty;
      case OrderSubmissionStatus.confirmed:
        return Icons.check_circle;
      case OrderSubmissionStatus.preparing:
        return Icons.restaurant;
      case OrderSubmissionStatus.served:
        return Icons.done_all;
      case OrderSubmissionStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText() {
    switch (status) {
      case OrderSubmissionStatus.pending:
        return 'Pending';
      case OrderSubmissionStatus.confirmed:
        return 'Confirmed';
      case OrderSubmissionStatus.preparing:
        return 'Preparing';
      case OrderSubmissionStatus.served:
        return 'Served';
      case OrderSubmissionStatus.cancelled:
        return 'Cancelled';
    }
  }
}
