import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/custom_app_bar.dart';

class SubscriptionStatusScreen extends StatelessWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Subscription Status',
      ),
      body: const Center(
        child: Text(
          'Subscription Status\nComing Soon!',
          style: AppTextStyles.h4,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}