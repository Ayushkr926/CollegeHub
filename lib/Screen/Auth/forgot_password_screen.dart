import 'package:college/Screen/Auth/widgets/app_header.dart';
import 'package:college/Screen/Auth/widgets/custom_text_field.dart';
import 'package:college/Screen/Auth/widgets/loading_button.dart';
import 'package:college/Screen/Auth/widgets/premium_bottom_sheet.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/validators.dart';

/// Lets the user request a password reset link via email.
/// On "success" (no backend yet) a premium bottom sheet confirms the send.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Replace with real "send password reset email" backend call.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);

    PremiumBottomSheet.show(
      context: context,
      icon: Icons.mark_email_read_outlined,
      title: 'Check Your Inbox',
      message:
          'If an account exists for ${_emailController.text.trim()}, a reset link has been sent.',
      buttonLabel: 'Done',
      onButtonPressed: () {
        Navigator.of(context).pop(); // close sheet
        Navigator.of(context).pop(); // back to login
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                const AppHeader(
                  title: 'Forgot Password',
                  subtitle: "Enter your email and we'll send you a reset link.",
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomTextField(
                  label: 'Email',
                  hint: 'you@college.edu',
                  controller: _emailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.xl),
                LoadingButton(
                  label: 'Send Reset Link',
                  isLoading: _isLoading,
                  onPressed: _handleSendResetLink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
