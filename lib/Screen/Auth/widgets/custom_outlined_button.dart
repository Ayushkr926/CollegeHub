import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';
/// A full-width, white-outlined, transparent-fill secondary button.
/// Use this for secondary actions (Continue with Email on Welcome screen,
/// disabled social logins, etc).
class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final String? badgeText;

  const CustomOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;

    return Opacity(
      opacity: isEnabled ? 1 : 0.45,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            OutlinedButton(
              onPressed: isEnabled ? onPressed : null,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                foregroundColor: AppColors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: AppColors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppTextStyles.buttonLabelOutlined),
                ],
              ),
            ),
            if (badgeText != null)
              Positioned(
                right: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cardSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(badgeText!, style: AppTextStyles.caption),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
