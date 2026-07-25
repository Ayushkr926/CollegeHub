import 'package:college/Screen/Auth/widgets/app_header.dart';
import 'package:college/Screen/Auth/widgets/custom_checkbox.dart';
import 'package:college/Screen/Auth/widgets/custom_text_field.dart';
import 'package:college/Screen/Auth/widgets/loading_button.dart';
import 'package:college/Screen/Auth/widgets/password_field.dart';
import 'package:college/Screen/Auth/widgets/section_title.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';


/// Registration form for club organizers. Includes an official club logo
/// placeholder, faculty coordinator details, and a confirmation checkbox
/// since club accounts require admin verification before use.
class ClubRegistrationScreen extends StatefulWidget {
  const ClubRegistrationScreen({super.key});

  @override
  State<ClubRegistrationScreen> createState() => _ClubRegistrationScreenState();
}

class _ClubRegistrationScreenState extends State<ClubRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _clubNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _facultyNameController = TextEditingController();
  final _facultyEmailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedCategory;
  bool _isOfficialClub = false;
  bool _officialClubError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _clubNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _facultyNameController.dispose();
    _facultyEmailController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isFormValid = _formKey.currentState!.validate();
    final isConfirmed = _isOfficialClub;

    setState(() => _officialClubError = !isConfirmed);

    if (!isFormValid || !isConfirmed) return;

    setState(() => _isLoading = true);

    // TODO: Wire this up to real backend registration (create club record
    // with status = pending_verification, notify admins for approval, etc).
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushNamed(AppRoutes.registrationSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                const AppHeader(
                  title: 'Club Sign Up',
                  subtitle: 'Register your club to start hosting events.',
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: _ClubLogoPlaceholder(
                    onTap: () {
                      // TODO: Hook up image picker + upload to storage once
                      // a backend is integrated.
                    },
                  ),
                ),
                const SectionTitle(text: 'CLUB DETAILS'),
                CustomTextField(
                  label: 'Club Name',
                  hint: 'e.g. Coding Club',
                  controller: _clubNameController,
                  prefixIcon: Icons.diversity_3_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, fieldName: 'Club name'),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Official Club Email',
                  hint: 'club@college.edu',
                  controller: _emailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: 'Password',
                  controller: _passwordController,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                ),
                const SizedBox(height: AppSpacing.md),
                _CategoryDropdown(
                  value: _selectedCategory,
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Description',
                  hint: 'Tell students what your club is about',
                  controller: _descriptionController,
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => Validators.required(v, fieldName: 'Description'),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Phone Number',
                  hint: '9876543210',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phoneRequired,
                ),
                const SectionTitle(text: 'FACULTY COORDINATOR'),
                CustomTextField(
                  label: 'Faculty Coordinator Name',
                  hint: 'Dr. Jane Smith',
                  controller: _facultyNameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, fieldName: 'Faculty coordinator name'),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Faculty Email',
                  hint: 'faculty@college.edu',
                  controller: _facultyEmailController,
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomCheckbox(
                  value: _isOfficialClub,
                  showError: _officialClubError,
                  onChanged: (value) => setState(() {
                    _isOfficialClub = value;
                    _officialClubError = false;
                  }),
                  label: Text(
                    'I confirm this is an official college club.',
                    style: AppTextStyles.bodyMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                LoadingButton(
                  label: 'Submit Club Request',
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Club accounts require admin verification before they can create events.',
                          style: AppTextStyles.bodyMuted.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
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

/// Tappable placeholder for uploading the club's logo.
class _ClubLogoPlaceholder extends StatelessWidget {
  final VoidCallback onTap;

  const _ClubLogoPlaceholder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary, size: 26),
            SizedBox(height: 4),
            Text('Club Logo', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

/// Dropdown for the club's category, styled to match [CustomTextField].
class _CategoryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
          child: Text('Category', style: AppTextStyles.label),
        ),
        DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          dropdownColor: AppColors.cardSecondary,
          style: AppTextStyles.body,
          decoration: const InputDecoration(
            hintText: 'Select a category',
            prefixIcon: Icon(Icons.category_outlined, color: AppColors.textSecondary, size: 20),
          ),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          items: AppConstants.clubCategories
              .map((category) => DropdownMenuItem(value: category, child: Text(category)))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Please select a category' : null,
        ),
      ],
    );
  }
}
