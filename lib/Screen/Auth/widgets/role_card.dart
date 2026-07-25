import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';
/// A large, tappable card representing a selectable role
/// (Student / Club Organizer) with an animated selection state.
class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.cardSecondary : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.xLarge),
          border: Border.all(
            color: selected ? AppColors.white : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.white : AppColors.cardSecondary,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.black : AppColors.textPrimary,
                size: 26,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMuted.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? const Icon(
                      Icons.check_circle,
                      key: ValueKey('selected'),
                      color: AppColors.white,
                      size: 24,
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      key: ValueKey('unselected'),
                      color: AppColors.textTertiary,
                      size: 24,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
