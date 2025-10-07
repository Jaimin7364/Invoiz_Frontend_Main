import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_button.dart';
import 'business_registration_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  late Timer _timer;
  int _remainingTime = AppConfig.otpResendTime;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingTime = AppConfig.otpResendTime;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _verifyOTP() async {
    if (_otpController.text.length != AppConfig.otpLength) {
      _showSnackBar('Please enter the complete OTP');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.verifyOTP(
      email: widget.email,
      otp: _otpController.text,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BusinessRegistrationScreen(),
        ),
      );
    } else {
      _showSnackBar(authProvider.error ?? 'OTP verification failed');
      _otpController.clear();
    }
  }

  void _resendOTP() async {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.resendOTP(email: widget.email);

    if (success) {
      _showSnackBar('OTP sent successfully!', isError: false);
      _startTimer();
    } else {
      _showSnackBar(authProvider.error ?? 'Failed to resend OTP');
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSizes.xl),
            
            // Email Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: AppSizes.iconXl,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Title and Description
            const Text(
              'Verify Your Email',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.md),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(
                    text: 'We\'ve sent a 6-digit verification code to\n',
                  ),
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xxl),

            // OTP Input
            PinCodeTextField(
              appContext: context,
              length: AppConfig.otpLength,
              controller: _otpController,
              keyboardType: TextInputType.number,
              autoFocus: true,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                fieldHeight: 60,
                fieldWidth: 50,
                activeFillColor: AppColors.surface,
                inactiveFillColor: AppColors.surface,
                selectedFillColor: AppColors.primaryLight,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                selectedColor: AppColors.primary,
              ),
              enableActiveFill: true,
              onCompleted: (value) {
                // Auto verify when OTP is complete
                _verifyOTP();
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: AppSizes.xl),

            // Verify Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return LoadingButton(
                  onPressed: _otpController.text.length == AppConfig.otpLength
                      ? _verifyOTP
                      : null,
                  isLoading: authProvider.isLoading,
                  text: 'Verify Email',
                );
              },
            ),
            const SizedBox(height: AppSizes.lg),

            // Resend OTP Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Didn\'t receive the code? ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_canResend)
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return GestureDetector(
                        onTap: authProvider.isLoading ? null : _resendOTP,
                        child: Text(
                          'Resend',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: authProvider.isLoading 
                                ? AppColors.textHint 
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  )
                else
                  Text(
                    'Resend in ${_formatTime(_remainingTime)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),

            // Help Text
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: AppSizes.iconMd,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Check your spam folder if you don\'t see the email in your inbox. The code expires in ${AppConfig.otpResendTime ~/ 60} minutes.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}