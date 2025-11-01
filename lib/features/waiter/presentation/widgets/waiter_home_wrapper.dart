// lib/features/waiter/presentation/widgets/waiter_home_wrapper.dart

import 'package:eservelink/features/waiter/presentation/pages/waiter_home_page.dart';
import 'package:flutter/material.dart';

/// Wrapper for waiter navigation
/// Similar to HomeWrapper for customers
/// Can add navigation logic later (e.g., waiter profile, settings)
class WaiterHomeWrapper extends StatelessWidget {
  const WaiterHomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, directly show waiter home page
    // Later can add bottom navigation or drawer for waiter-specific features
    return const WaiterHomePage();
  }
}
