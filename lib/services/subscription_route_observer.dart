import 'package:flutter/material.dart';
import '../services/subscription_guard_service.dart';

/// Route observer that checks subscription status on navigation
class SubscriptionRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  static final SubscriptionRouteObserver _instance = SubscriptionRouteObserver._internal();
  
  factory SubscriptionRouteObserver() => _instance;
  
  SubscriptionRouteObserver._internal();

  /// Routes that don't require subscription check
  static const Set<String> _exemptRoutes = {
    '/splash',
    '/welcome',
    '/login',
    '/register',
    '/otp-verification',
    '/business-registration',
    '/subscription-plans',
  };

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _checkSubscriptionForRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _checkSubscriptionForRoute(newRoute);
    }
  }

  void _checkSubscriptionForRoute(Route<dynamic> route) {
    // Get route name
    final routeName = route.settings.name;
    
    // Skip check for exempt routes
    if (routeName != null && _exemptRoutes.contains(routeName)) {
      return;
    }

    // Skip check for subscription-related routes
    if (routeName?.contains('subscription') == true) {
      return;
    }

    // Perform subscription check with a delay to avoid navigation conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = route.navigator?.context;
      if (context != null) {
        await SubscriptionGuardService.performPeriodicSubscriptionCheck(context);
      }
    });
  }
}