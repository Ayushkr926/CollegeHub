import 'package:college/Screen/Auth/widgets/animated_logo.dart';
import 'package:college/Screen/Auth/widgets/app_header.dart';
import 'package:college/Screen/Auth/widgets/custom_checkbox.dart';
import 'package:college/Screen/Auth/widgets/custom_text_field.dart';
import 'package:college/Screen/Auth/widgets/loading_button.dart';
import 'package:college/Screen/Auth/widgets/password_field.dart';
import 'package:college/Screen/Auth/widgets/section_title.dart';
import 'package:flutter/material.dart';

import '../../utils/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';

/// The very first screen shown on app launch.
/// Displays the app logo, name and tagline with a fade + scale entrance,
/// then automatically navigates to Onboarding after a short delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _textController;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    // Small delay so the logo animates in first, then the text follows.
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _textController.forward();
    });

    // TODO: Replace with real auth-state check (e.g. check stored session
    // token) once a backend/auth provider is integrated. For now this
    // always routes to Onboarding after a fixed delay.
    Future.delayed(AppDurations.splash, () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedLogo(size: 104),
            const SizedBox(height: AppSpacing.lg),
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Column(
                  children: [
                    Text('CampusHub', style: AppTextStyles.displayMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Events. Clubs. Community.',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
