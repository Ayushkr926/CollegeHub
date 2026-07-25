
import 'package:college/Screen/Auth/provider/login_provider.dart';
import 'package:college/Screen/Auth/widgets/app_header.dart';
import 'package:college/Screen/Auth/widgets/custom_text_field.dart';
import 'package:college/Screen/Auth/widgets/loading_button.dart';
import 'package:college/Screen/Auth/widgets/password_field.dart';
import 'package:college/Screen/Auth/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';

/// Login screen: email + password with remember-me, forgot password, and
/// disabled social login placeholders.
///
/// This widget's only job is to own the [LoginProvider] instance and hand
/// it down to [_LoginView]; all form state and the actual login call live
/// in the provider so they survive rebuilds and are testable in isolation.


class LoginScreen  extends StatelessWidget {
  const LoginScreen ();

  @override
  Widget build(BuildContext context) {

    final loginProvider = context.watch<LoginProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Form(
            key: loginProvider.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                const AppHeader(
                  title: 'Login',
                  subtitle: 'Welcome back! Please enter your details.',
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomTextField(
                  label: 'Email',
                  hint: 'you@college.edu',
                  controller: loginProvider.emailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: 'Password',
                  controller: loginProvider.passwordController,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password is required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: loginProvider.toggleRememberMe,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: loginProvider.rememberMe ? AppColors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppColors.border, width: 1.4),
                            ),
                            child: loginProvider.rememberMe
                                ? const Icon(Icons.check, size: 14, color: AppColors.black)
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Remember Me', style: AppTextStyles.bodyMuted),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                      child: Text('Forgot Password?', style: AppTextStyles.link),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                LoadingButton(
                  label: 'Login',
                  isLoading: loginProvider.isLoading,
                  onPressed: () => loginProvider.handleLogin(context),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text('or continue with', style: AppTextStyles.caption),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const SocialLoginButton(icon: Icons.g_mobiledata_rounded, label: 'Google'),
                const SizedBox(height: AppSpacing.sm),
                const SocialLoginButton(icon: Icons.apple_rounded, label: 'Apple'),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: AppTextStyles.bodyMuted),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.selectRole),
                      child: Text('Create Account', style: AppTextStyles.link),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}