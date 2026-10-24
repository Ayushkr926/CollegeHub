import 'package:college/Screen/Auth/provider/register_provider.dart';
import 'package:college/Screen/Auth/widgets/app_header.dart';
import 'package:college/Screen/Auth/widgets/custom_checkbox.dart';
import 'package:college/Screen/Auth/widgets/custom_text_field.dart';
import 'package:college/Screen/Auth/widgets/loading_button.dart';
import 'package:college/Screen/Auth/widgets/password_field.dart';
import 'package:college/Screen/Auth/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';

/// Registration form for students, capturing academic details in addition
/// to standard account credentials.
class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    // IMPORTANT: use watch(), not read(), inside build().
    // read() does not subscribe to notifyListeners(), so this widget would
    // never rebuild on loading-state changes, terms-checkbox toggles, or
    // validation errors coming from the provider.
    final authProvider = context.watch<RegisterProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Form(
            key: authProvider.formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                const AppHeader(
                  title: 'Student Sign Up',
                  subtitle: 'Create your student account to get started.',
                ),
                const SectionTitle(text: 'PERSONAL DETAILS'),
                CustomTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: authProvider.fullNameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, fieldName: 'Full name'),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'College Email',
                  hint: 'you@college.edu',
                  controller: authProvider.emailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: 'Password',
                  controller: authProvider.passwordController,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: 'Confirm Password',
                  controller: authProvider.confirmPasswordController,
                  validator: (v) => Validators.confirmPassword(v, authProvider.passwordController.text),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Phone Number (Optional)',
                  hint: '9876543210',
                  controller: authProvider.phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phoneOptional,
                ),
                const SectionTitle(text: 'ACADEMIC DETAILS'),
                CustomTextField(
                  label: 'Roll Number',
                  hint: 'e.g. 21CS1042',
                  controller: authProvider.rollNumberController,
                  prefixIcon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => Validators.required(v, fieldName: 'Roll number'),
                ),
                const SizedBox(height: AppSpacing.md),
                _AcademicDropdown(
                  label: 'Course',
                  hint: 'Select course',
                  value: authProvider.courseController.text.isEmpty
                      ? null
                      : authProvider.courseController.text,
                  values: AppConstants.courses,
                  icon: Icons.menu_book_outlined,
                  onChanged: authProvider.setCourse,
                ),
                const SizedBox(height: AppSpacing.md),
                _AcademicDropdown(
                  label: 'Branch',
                  hint: 'Select branch',
                  value: authProvider.branchController.text.isEmpty
                      ? null
                      : authProvider.branchController.text,
                  values: AppConstants.branches,
                  icon: Icons.account_tree_outlined,
                  onChanged: authProvider.setBranch,
                ),
                const SizedBox(height: AppSpacing.md),
                _YearDropdown(
                  value: authProvider.selectedYear,
                  onChanged: (value) => authProvider.setSelectedYear(value),
                ),
                const SizedBox(height: AppSpacing.lg),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => authProvider.setAcceptedTerms(!authProvider.acceptedTerms),
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
                              color: authProvider.acceptedTerms ? AppColors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: authProvider.termsError && !authProvider.acceptedTerms ? AppColors.error : AppColors.border,
                                width: 1.4,
                              ),
                            ),
                            child: authProvider.acceptedTerms
                                ? const Icon(Icons.check, size: 16, color: AppColors.black)
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: AppTextStyles.bodyMuted,
                                children: [
                                  const TextSpan(text: 'I accept the '),
                                  TextSpan(text: 'Terms of Service', style: AppTextStyles.body),
                                  const TextSpan(text: ' and '),
                                  TextSpan(text: 'Privacy Policy', style: AppTextStyles.body),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (authProvider.termsError && !authProvider.acceptedTerms)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 30),
                        child: Text('Please accept to continue', style: AppTextStyles.error),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    // Was previously always non-null (ternary expression), so
                    // the button never visually disabled and kept its tap
                    // ripple while a request was in-flight.
                    onPressed: authProvider.isLoading
                        ? null
                        : () => authProvider.handleCreateAccount(context),
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
                      child: authProvider.isLoading
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
                            'Loading..',
                            style: AppTextStyles.buttonLabel,
                          ),
                        ],
                      )
                          : Text(
                        'Create Account',
                        key: const ValueKey('label'),
                        style: AppTextStyles.buttonLabel,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppTextStyles.bodyMuted),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login,
                            (route) => route.settings.name == AppRoutes.welcome || route.isFirst,
                      ),
                      child: Text('Login', style: AppTextStyles.link),
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

/// Dropdown for the student's current year, styled to match [CustomTextField].
class _YearDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _YearDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
          child: Text('Year', style: AppTextStyles.label),
        ),
        DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          dropdownColor: AppColors.cardSecondary,
          style: AppTextStyles.body,
          decoration: const InputDecoration(
            focusColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1.0,
              ),
            ),
            hintText: 'Select your year',
            prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
          items: AppConstants.years
              .map((year) => DropdownMenuItem(value: year, child: Text(year)))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Please select your year' : null,
        ),
      ],
    );
  }
}

class _AcademicDropdown extends StatelessWidget {
  const _AcademicDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.values,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> values;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
          child: Text(label, style: AppTextStyles.label),
        ),
        DropdownButtonFormField<String>(
          value: value != null && values.contains(value) ? value : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          dropdownColor: AppColors.cardSecondary,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
          items: values
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          validator: (item) => item == null ? 'Please select a $label' : null,
        ),
      ],
    );
  }
}