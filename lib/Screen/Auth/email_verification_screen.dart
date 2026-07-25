
import 'package:college/Screen/Auth/widgets/custom_outlined_button.dart';

import 'package:college/Screen/Auth/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

import '../../utils/app_routes.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';


/// Prompts the user to verify their email before continuing.
/// Includes a resend action (rate-limited UI-side once wired to a backend)
/// and a continue action for once verification is complete.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;

  Future<void> _handleResend() async {
    setState(() => _isResending = true);

    // TODO: Trigger a real "resend verification email" backend call.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email resent.')),
    );
  }

  void _handleContinue() {
    // TODO: Check real verification status from backend before proceeding.
    Navigator.of(context).pushNamed(AppRoutes.registrationSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.mark_email_unread_outlined, size: 84, color: AppColors.white),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Verify Your Email', style: AppTextStyles.headline, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Please verify your email before continuing.',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              PrimaryButton(label: 'Continue', onPressed: _handleContinue),
              const SizedBox(height: AppSpacing.sm),
              CustomOutlinedButton(
                label: _isResending ? 'Resending...' : 'Resend Email',
                enabled: !_isResending,
                onPressed: _handleResend,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
