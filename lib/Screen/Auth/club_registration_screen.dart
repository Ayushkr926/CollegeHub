import 'dart:io';

import 'package:college/Screen/Auth/provider/club_registration.dart';
import 'package:college/Screen/Auth/widgets/app_header.dart';
import 'package:college/Screen/Auth/widgets/custom_checkbox.dart';
import 'package:college/Screen/Auth/widgets/custom_text_field.dart';
import 'package:college/Screen/Auth/widgets/loading_button.dart';
import 'package:college/Screen/Auth/widgets/password_field.dart';
import 'package:college/Screen/Auth/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';

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
    // Reset provider so next visit starts clean
    context.read<ClubRegistrationProvider>().reset();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) return;

    final provider = context.read<ClubRegistrationProvider>();

    final ok = await provider.handleCreateClub(
      context,
      clubName: _clubNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      facultyName: _facultyNameController.text,
      facultyEmail: _facultyEmailController.text,
      description: _descriptionController.text,
      phone: _phoneController.text,
    );

    if (!mounted) return;

    if (!ok) {
      final error = provider.error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Navigator.of(context).pushNamed(AppRoutes.registrationSuccess);
  }

  Future<void> _showLogoSourceSheet() async {
    HapticFeedback.lightImpact();
    final provider = context.read<ClubRegistrationProvider>();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Club Logo', style: TextStyle(fontSize: 18,color: Colors.white)),
            const SizedBox(height: 20),
            _SourceTile(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(ctx);
                provider.pickLogo(source: ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
            _SourceTile(
              icon: Icons.camera_alt_rounded,
              label: 'Take a Photo',
              onTap: () {
                Navigator.pop(ctx);
                provider.pickLogo(source: ImageSource.camera);
              },
            ),
            if (provider.hasLogo) ...[
              const SizedBox(height: 10),
              _SourceTile(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Logo',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  provider.removeLogo();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
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

                // ── Logo ───────────────────────────────────────
                Center(
                  child: Consumer<ClubRegistrationProvider>(
                    builder: (context, provider, _) {
                      return _ClubLogoPicker(
                        file: provider.logoFile,
                        onTap: _showLogoSourceSheet,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: _showLogoSourceSheet,
                    child: Text(
                      'Upload Club Logo',
                      style: AppTextStyles.bodyMuted.copyWith(
                        color: Colors.black38,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // ── Club Details ───────────────────────────────
                const SectionTitle(text: 'CLUB DETAILS'),
                CustomTextField(
                  label: 'Club Name',
                  hint: 'e.g. Coding Club',
                  controller: _clubNameController,
                  prefixIcon: Icons.diversity_3_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Club name'),
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
                  validator: (v) => Validators.confirmPassword(
                    v,
                    _passwordController.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Category (driven by provider)
                Consumer<ClubRegistrationProvider>(
                  builder: (context, provider, _) {
                    return _CategoryDropdown(
                      value: provider.selectedCategory,
                      onChanged: provider.setCategory,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                CustomTextField(
                  label: 'Description',
                  hint: 'Tell students what your club is about',
                  controller: _descriptionController,
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Description'),
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

                // ── Faculty ────────────────────────────────────
                const SectionTitle(text: 'FACULTY COORDINATOR'),
                CustomTextField(
                  label: 'Faculty Coordinator Name',
                  hint: 'Dr. Jane Smith',
                  controller: _facultyNameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(
                    v,
                    fieldName: 'Faculty coordinator name',
                  ),
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

                // ── Confirmation checkbox ──────────────────────
                Consumer<ClubRegistrationProvider>(
                  builder: (context, provider, _) {
                    return CustomCheckbox(
                      value: provider.isOfficialClub,
                      showError: provider.officialClubError,
                      onChanged: provider.setOfficialClub,
                      label: Text(
                        'I confirm this is an official college club.',
                        style: AppTextStyles.bodyMuted,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Submit ─────────────────────────────────────
                Consumer<ClubRegistrationProvider>(
                  builder: (context, provider, _) {
                    return LoadingButton(
                      label: 'Submit Club Request',
                      isLoading: provider.isLoading,
                      onPressed: _handleSubmit,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Info banner
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
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
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

// ─────────────────────────────────────────────────────────────────
// LOGO PICKER
// ─────────────────────────────────────────────────────────────────
class _ClubLogoPicker extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;

  const _ClubLogoPicker({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: file != null
                  ? Image.file(
                file!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
                  : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.textSecondary,
                    size: 28,
                  ),
                  SizedBox(height: 6),
                  Text('Club Logo', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2.5),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SOURCE TILE (bottom sheet)
// ─────────────────────────────────────────────────────────────────
class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CATEGORY DROPDOWN
// ─────────────────────────────────────────────────────────────────
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
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.cardSecondary,
          style: AppTextStyles.body,
          decoration: const InputDecoration(
            hintText: 'Select a category',
            prefixIcon: Icon(
              Icons.category_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          items: AppConstants.clubCategories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Please select a category' : null,
        ),
      ],
    );
  }
}