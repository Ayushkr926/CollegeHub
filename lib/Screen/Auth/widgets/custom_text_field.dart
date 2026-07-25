import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';

/// A premium, dark-filled text field used across every form in the module.
/// Wraps [TextFormField] with consistent styling, an animated focus state
/// (glow border + label color + subtle lift), and a clear button that
/// appears once the field has content.
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;

  /// Shows a small trailing "x" button to clear the field once it has
  /// content. Ignored automatically when [suffixIcon] is set or
  /// [maxLines] > 1, since those cases manage their own trailing layout.
  final bool showClearButton;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.focusNode,
    this.onChanged,
    this.showClearButton = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _handleTextChange() {
    // Rebuild so the clear button appears/disappears as text changes.
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    final canShowClear = widget.showClearButton &&
        widget.enabled &&
        widget.maxLines == 1 &&
        widget.suffixIcon == null &&
        hasText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: AppTextStyles.label.copyWith(
              color: _isFocused ? AppColors.white : AppColors.textSecondary,
            ),
            child: Text(widget.label),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: Colors.white.withOpacity(0.08),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            validator: widget.validator,
            onChanged: widget.onChanged,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            style: AppTextStyles.body,
            cursorColor: AppColors.white,
            cursorRadius: const Radius.circular(2),
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: _isFocused ? AppColors.cardSecondary : AppColors.card,
              prefixIcon: widget.prefixIcon != null
                  ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  widget.prefixIcon,
                  key: ValueKey(_isFocused),
                  color: _isFocused ? AppColors.white : AppColors.textSecondary,
                  size: 20,
                ),
              )
                  : null,
              suffixIcon: widget.suffixIcon ??
                  (canShowClear
                      ? IconButton(
                    splashRadius: 18,
                    icon: const Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                    },
                  )
                      : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(color: AppColors.white, width: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}