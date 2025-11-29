import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/subscription/subscription_plans_screen.dart';

class SubscriptionGuardService {
  static const String _tag = 'SubscriptionGuardService';
  static bool _bypassNextCheck = false;
  static bool _isInRegistrationFlow = false;
  
  /// Temporarily bypass the next subscription check (useful after payment)
  static void bypassNextCheck() {
    _bypassNextCheck = true;
    debugPrint('$_tag: Next subscription check will be bypassed');
  }
  
  /// Mark that user is in registration flow (should not be redirected)
  static void setRegistrationFlow(bool inFlow) {
    _isInRegistrationFlow = inFlow;
    debugPrint('$_tag: Registration flow status: $inFlow');
  }
  
  /// Checks if user has an active subscription and redirects to plan selection if needed
  static Future<bool> checkSubscriptionAccess(BuildContext context) async {
    // Check if we should bypass this check
    if (_bypassNextCheck) {
      _bypassNextCheck = false;
      debugPrint('$_tag: Bypassing subscription check (payment processing)');
      return true;
    }
    
    // Check if user is in registration flow
    if (_isInRegistrationFlow) {
      debugPrint('$_tag: User in registration flow, allowing access');
      return true;
    }
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // If user is not logged in, don't check subscription
      if (!authProvider.isLoggedIn) {
        debugPrint('$_tag: User not logged in, allowing access');
        return true;
      }
      
      debugPrint('$_tag: User is logged in, checking subscription...');
      
      // Refresh user data to get latest subscription info
      await authProvider.getCurrentUser();
      
      final user = authProvider.user;
      final subscription = user?.subscription;
      
      debugPrint('$_tag: User subscription details:');
      debugPrint('  - Subscription exists: ${subscription != null}');
      debugPrint('  - Plan type: ${subscription?.planType}');
      debugPrint('  - Status: ${subscription?.status}');
      debugPrint('  - Days remaining: ${subscription?.daysRemaining}');
      debugPrint('  - Start date: ${subscription?.startDate}');
      debugPrint('  - End date: ${subscription?.endDate}');
      debugPrint('  - hasActiveSubscription: ${authProvider.hasActiveSubscription}');
      debugPrint('  - isSubscriptionExpired: ${authProvider.isSubscriptionExpired}');
      
      // Check if user has active subscription
      if (!authProvider.hasActiveSubscription || authProvider.isSubscriptionExpired) {
        debugPrint('$_tag: User subscription invalid or expired. Access allowed but limited.');
        // Don't redirect - just return false to indicate no active subscription
        return false;
      }
      
      debugPrint('$_tag: User has valid subscription, allowing access');
      return true;
    } catch (e) {
      debugPrint('$_tag: Error checking subscription: $e');
      // On error, allow access but show warning
      return false;
    }
  }
  
  /// Redirects user to subscription plans screen and clears navigation stack
  static void _redirectToSubscriptionPlans(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const SubscriptionPlansScreen(
          canGoBack: false,
          message: 'Your subscription has expired. Please select a plan to continue using the app.',
        ),
        settings: const RouteSettings(name: '/subscription-plans'),
      ),
      (route) => false, // Remove all previous routes
    );
  }
  
  /// Checks subscription status periodically when app is active
  static Future<void> performPeriodicSubscriptionCheck(BuildContext context) async {
    try {
      // Skip check if user is in registration flow
      if (_isInRegistrationFlow) {
        debugPrint('$_tag: User in registration flow, skipping subscription check');
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Only check if user is logged in
      if (!authProvider.isLoggedIn) return;
      
      // Refresh user data from server
      await authProvider.getCurrentUser();
      
      // Check if subscription has expired
      if (!authProvider.hasActiveSubscription || authProvider.isSubscriptionExpired) {
        debugPrint('$_tag: Subscription expired during app usage. User will see warning in dashboard.');
        // Don't redirect - let dashboard show the warning
        return;
      }
      
      // Show warning if subscription is expiring soon
      if (authProvider.shouldShowSubscriptionWarning) {
        debugPrint('$_tag: Subscription expiring soon (${authProvider.subscriptionDaysRemaining} days). User will see warning in dashboard.');
      }
    } catch (e) {
      debugPrint('$_tag: Error in periodic subscription check: $e');
    }
  }
  
  /// Shows subscription expiry warning dialog
  static void showSubscriptionExpiryWarning(
    BuildContext context, {
    required int daysRemaining,
    VoidCallback? onRenewPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text('Subscription Expiring'),
            ],
          ),
          content: Text(
            daysRemaining > 0
                ? 'Your subscription will expire in $daysRemaining ${daysRemaining == 1 ? 'day' : 'days'}. '
                  'Renew now to continue using all features.'
                : 'Your subscription has expired. Please renew to continue using the app.',
          ),
          actions: [
            if (daysRemaining > 0)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onRenewPressed != null) {
                  onRenewPressed();
                } else {
                  _redirectToSubscriptionPlans(context);
                }
              },
              child: const Text('Renew Now'),
            ),
          ],
        );
      },
    );
  }
  
  /// Creates a widget wrapper that checks subscription before showing content
  static Widget subscriptionProtectedRoute({
    required Widget child,
    Widget? fallbackWidget,
  }) {
    return Builder(
      builder: (context) {
        return FutureBuilder<bool>(
          future: checkSubscriptionAccess(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (snapshot.data == true) {
              return child;
            }
            
            // If subscription check failed, show fallback or subscription plans
            return fallbackWidget ?? const SubscriptionPlansScreen(
              canGoBack: false,
              message: 'Please select a subscription plan to access this feature.',
            );
          },
        );
      },
    );
  }
}