import 'package:college/Screen/Auth/widgets/animated_logo.dart';
import 'package:college/Screen/Auth/widgets/app_header.dart';
import 'package:college/Screen/Auth/widgets/custom_checkbox.dart';
import 'package:college/Screen/Auth/widgets/custom_text_field.dart';
import 'package:college/Screen/Auth/widgets/loading_button.dart';
import 'package:college/Screen/Auth/widgets/password_field.dart';
import 'package:college/Screen/Auth/widgets/primary_button.dart';
import 'package:college/Screen/Auth/widgets/section_title.dart';
import 'package:flutter/material.dart';

import '../../utils/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';


/// The landing screen after onboarding: introduces the app and offers the
/// two entry points into the auth flow — creating an account via email, or
/// logging in if the user already has one.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              const AnimatedLogo(size: 88),
              const Spacer(flex: 1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome', style: AppTextStyles.displayLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Everything happening on your campus in one place.',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: 'Continue with Email',
                icon: Icons.mail_outline_rounded,
                onPressed: () {
                  // TODO: Hook up to backend once available — this simply
                  // routes into the registration flow for now.
                  Navigator.of(context).pushNamed(AppRoutes.selectRole);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: AppTextStyles.bodyMuted),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.login),
                    child: Text('Login', style: AppTextStyles.link),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.caption,
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
