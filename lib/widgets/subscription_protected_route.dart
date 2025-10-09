import 'package:flutter/material.dart';
import '../services/subscription_guard_service.dart';

/// A wrapper widget that protects routes behind subscription check
class SubscriptionProtectedRoute extends StatelessWidget {
  final Widget child;
  final String? requiredFeatureName;
  
  const SubscriptionProtectedRoute({
    super.key,
    required this.child,
    this.requiredFeatureName,
  });

  @override
  Widget build(BuildContext context) {
    return SubscriptionGuardService.subscriptionProtectedRoute(
      child: child,
    );
  }
}

/// Mixin to add subscription checking functionality to any widget
mixin SubscriptionMixin<T extends StatefulWidget> on State<T> {
  
  /// Check subscription when widget initializes
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSubscription();
    });
  }

  Future<void> _checkSubscription() async {
    final hasAccess = await SubscriptionGuardService.checkSubscriptionAccess(context);
    if (!hasAccess) {
      // Navigation to subscription screen is handled by the service
      return;
    }
  }

  /// Call this method to perform periodic subscription checks
  Future<void> performSubscriptionCheck() async {
    await SubscriptionGuardService.performPeriodicSubscriptionCheck(context);
  }
}