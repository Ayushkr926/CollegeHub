import 'package:college/Screen/Auth/widgets/primary_button.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';
/// A reusable, rounded, glass-tinted bottom sheet with an icon, title,
/// message and single confirm action. Used for success states such as
/// "Reset link sent" on the Forgot Password screen.
class PremiumBottomSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const PremiumBottomSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  static Future<void> show({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onButtonPressed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      isScrollControlled: true,
      builder: (_) => PremiumBottomSheet(
        icon: icon,
        title: title,
        message: message,
        buttonLabel: buttonLabel,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.black, size: 30),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(message, style: AppTextStyles.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: buttonLabel, onPressed: onButtonPressed),
          ],
        ),
      ),
    );
  }
}
