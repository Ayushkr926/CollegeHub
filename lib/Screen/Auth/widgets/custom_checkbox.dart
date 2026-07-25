import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';
/// A custom-styled checkbox row with a tappable label, used for Terms &
/// Conditions / confirmation acceptance across registration screens.
class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;
  final bool showError;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: value ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: showError && !value ? AppColors.error : AppColors.border,
                    width: 1.4,
                  ),
                ),
                child: value
                    ? const Icon(Icons.check, size: 16, color: AppColors.black)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: label),
            ],
          ),
        ),
        if (showError && !value)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 30),
            child: Text('Please accept to continue', style: AppTextStyles.error),
          ),
      ],
    );
  }
}
