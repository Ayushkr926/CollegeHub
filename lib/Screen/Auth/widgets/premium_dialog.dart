import 'package:college/Screen/Auth/widgets/primary_button.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';
import 'custom_outlined_button.dart';
/// A reusable premium-styled alert dialog with a title, message and up to
/// two actions. Call [PremiumDialog.show] instead of constructing directly.
class PremiumDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  const PremiumDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  static Future<void> show({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback onPrimaryPressed,
    String? secondaryLabel,
    VoidCallback? onSecondaryPressed,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (_) => PremiumDialog(
        icon: icon,
        title: title,
        message: message,
        primaryLabel: primaryLabel,
        onPrimaryPressed: onPrimaryPressed,
        secondaryLabel: secondaryLabel,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.xLarge),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            PrimaryButton(label: primaryLabel, onPressed: onPrimaryPressed),
            if (secondaryLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              CustomOutlinedButton(label: secondaryLabel!, onPressed: onSecondaryPressed),
            ],
          ],
        ),
      ),
    );
  }
}
