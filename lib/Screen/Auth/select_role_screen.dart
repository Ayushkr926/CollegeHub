import 'package:college/Screen/Auth/widgets/app_header.dart';
import 'package:college/Screen/Auth/widgets/custom_checkbox.dart';
import 'package:college/Screen/Auth/widgets/custom_text_field.dart';
import 'package:college/Screen/Auth/widgets/loading_button.dart';
import 'package:college/Screen/Auth/widgets/password_field.dart';
import 'package:college/Screen/Auth/widgets/primary_button.dart';
import 'package:college/Screen/Auth/widgets/role_card.dart';
import 'package:college/Screen/Auth/widgets/section_title.dart';
import 'package:flutter/material.dart';
import '../../Model/user_role.dart';

import '../../utils/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';

/// Lets the user choose whether they're registering as a Student or a
/// Club Organizer, which determines which registration form is shown next.
class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  Role? _selectedRole;

  void _continue() {
    if (_selectedRole == null) return;

    final route = _selectedRole == Role.student
        ? AppRoutes.studentRegistration
        : AppRoutes.clubRegistration;

    Navigator.of(context).pushNamed(route, arguments: RoleArguments(_selectedRole!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              const AppHeader(
                title: 'Join CampusHub',
                subtitle: 'Tell us how you\'ll be using the app.',
              ),
              const SizedBox(height: AppSpacing.xl),
              RoleCard(
                icon: Role.student.icon,
                title: Role.student.title,
                description: Role.student.description,
                selected: _selectedRole == Role.student,
                onTap: () => setState(() => _selectedRole = Role.student),
              ),
              const SizedBox(height: AppSpacing.md),
              RoleCard(
                icon: Role.clubHead.icon,
                title: Role.clubHead.title,
                description: Role.clubHead.description,
                selected: _selectedRole == Role.clubHead,
                onTap: () => setState(() => _selectedRole = Role.clubHead),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continue',
                enabled: _selectedRole != null,
                onPressed: _selectedRole != null ? _continue : null,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
