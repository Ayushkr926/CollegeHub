import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';
/// A primary button that can display a loading spinner in place of its
/// label. Useful for async actions (currently simulated locally since no
/// backend is wired up yet).
class LoadingButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isLoading && onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.white.withOpacity(0.85),
          foregroundColor: AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          elevation: 0,
        ),
         child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isLoading
          ? Row(
        key: const ValueKey('loading'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.buttonLabel,
          ),
        ],
      )
          : Text(
        label,
        key: const ValueKey('label'),
        style: AppTextStyles.buttonLabel,
      ),
    ),
      ),
    );
  }
}
