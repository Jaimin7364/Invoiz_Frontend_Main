import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/subscription_guard_service.dart';
import 'auth/welcome_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  void _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Initialize auth provider
    await authProvider.initialize();
    
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      // Navigate based on auth status
      if (authProvider.isLoggedIn) {
        try {
          // Check subscription status for logged-in users
          final hasValidSubscription = await SubscriptionGuardService.checkSubscriptionAccess(context);
          
          if (hasValidSubscription) {
            // User has active subscription, navigate to home
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
          // If subscription is invalid, SubscriptionGuardService already handles redirect
        } catch (e) {
          print('Splash: Error checking subscription: $e');
          // On error, try to navigate to home anyway and let guards handle it
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        // User not logged in, go to welcome screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          size: AppSizes.iconXl,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.xl),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Invoiz',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Business Management Made Easy',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textOnPrimary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xxl),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}