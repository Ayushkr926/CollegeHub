import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_spacing.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/validators.dart';

/// A password input with a show/hide toggle, styled consistently with
/// [CustomTextField]: animated focus glow, animated label color, and an
/// animated eye-icon swap. Optionally shows a live strength meter, handy
/// on registration screens.
class PasswordField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;


  final bool showStrengthIndicator;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.showStrengthIndicator = false,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _obscure = true;
  bool _isFocused = false;
  int _strength = 0;

  static const _strengthLabels = ['Weak', 'Fair', 'Good', 'Strong'];

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
    if (widget.showStrengthIndicator) {
      widget.controller.addListener(_handleTextChange);
      _strength = Validators.passwordStrength(widget.controller.text);
    }
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _handleTextChange() {
    if (!mounted) return;
    setState(() => _strength = Validators.passwordStrength(widget.controller.text));
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.showStrengthIndicator) {
      widget.controller.removeListener(_handleTextChange);
    }
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  Color _segmentColor(int index) {
    if (index >= _strength) return AppColors.border;
    switch (_strength) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.textSecondary;
      case 3:
      case 4:
        return AppColors.white;
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    final showMeter = widget.showStrengthIndicator && hasText;

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
            obscureText: _obscure,
            validator: widget.validator,
            onChanged: widget.onChanged,
            style: AppTextStyles.body,
            cursorColor: AppColors.white,
            cursorRadius: const Radius.circular(2),
            decoration: InputDecoration(
              hintText: widget.hint ?? 'Enter your password',
              filled: true,
              fillColor: _isFocused ? AppColors.cardSecondary : AppColors.card,
              prefixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.lock_outline,
                  key: ValueKey(_isFocused),
                  color: _isFocused ? AppColors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                splashRadius: 18,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    key: ValueKey(_obscure),
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
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
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: showMeter
              ? Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm, left: 2, right: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: _segmentColor(index),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  _strength == 0
                      ? ''
                      : _strengthLabels[(_strength - 1).clamp(0, 3)],
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}