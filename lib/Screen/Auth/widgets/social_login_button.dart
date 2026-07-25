import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';
/// A social login option (Google, Apple, etc) that is visually designed
/// but intentionally disabled with a "Coming Soon" badge, since backend
/// OAuth integration is out of scope for this module.
class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.cardSecondary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text('Coming Soon', style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
    );
  }
}
