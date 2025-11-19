import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;

  const NotificationBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(size * 0.2),
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Badge that can be positioned on any widget
class BadgedWidget extends StatelessWidget {
  final Widget child;
  final int badgeCount;
  final Color? badgeColor;
  final Alignment alignment;

  const BadgedWidget({
    super.key,
    required this.child,
    required this.badgeCount,
    this.badgeColor,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (badgeCount > 0)
          Positioned(
            top:
                alignment == Alignment.topRight ||
                        alignment == Alignment.topLeft
                    ? -4
                    : null,
            right:
                alignment == Alignment.topRight ||
                        alignment == Alignment.bottomRight
                    ? -4
                    : null,
            left:
                alignment == Alignment.topLeft ||
                        alignment == Alignment.bottomLeft
                    ? -4
                    : null,
            bottom:
                alignment == Alignment.bottomRight ||
                        alignment == Alignment.bottomLeft
                    ? -4
                    : null,
            child: NotificationBadge(
              count: badgeCount,
              backgroundColor: badgeColor,
            ),
          ),
      ],
    );
  }
}
