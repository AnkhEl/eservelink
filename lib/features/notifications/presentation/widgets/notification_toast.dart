import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter/material.dart';

class NotificationToast {
  static void show({
    required BuildContext context,
    required NotificationEntity notification,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => _NotificationToastWidget(
            notification: notification,
            onTap: () {
              overlayEntry.remove();
              onTap?.call();
            },
            onDismiss: () => overlayEntry.remove(),
          ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _NotificationToastWidget extends StatefulWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationToastWidget({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationToastWidget> createState() =>
      _NotificationToastWidgetState();
}

class _NotificationToastWidgetState extends State<_NotificationToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon based on notification type
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getIconColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getIcon(), color: _getIconColor(), size: 24),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.notification.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.notification.body,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Dismiss button
                    IconButton(
                      onPressed: _dismiss,
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.notification.type) {
      case NotificationType.ping:
        return Icons.notifications_active;
      case NotificationType.pingAcknowledged:
        return Icons.check_circle;
      case NotificationType.message:
        return Icons.chat_bubble;
      case NotificationType.order:
        return Icons.restaurant_menu;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.sessionEnded:
        return Icons.done_all;
      case NotificationType.general:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (widget.notification.type) {
      case NotificationType.ping:
        return Colors.orange;
      case NotificationType.pingAcknowledged:
        return Colors.green;
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.order:
        return Colors.purple;
      case NotificationType.payment:
        return Colors.teal;
      case NotificationType.sessionEnded:
        return Colors.grey;
      case NotificationType.general:
        return Colors.deepPurple;
    }
  }
}
