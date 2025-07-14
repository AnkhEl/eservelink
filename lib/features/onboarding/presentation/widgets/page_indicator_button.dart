import 'package:flutter/material.dart';

class PageIndicatorButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final PageController controller;

  const PageIndicatorButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}
