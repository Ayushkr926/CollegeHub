import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';

/// A small uppercase-ish label used to divide long forms into logical
/// sections (e.g. "Personal Details", "Academic Details").
class SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? padding;

  const SectionTitle({
    super.key,
    required this.text,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.md),
      child: Text(text, style: AppTextStyles.label.copyWith(letterSpacing: 0.6)),
    );
  }
}
