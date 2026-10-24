// -----------------------------------------------------------------------
// edit_profile_screen.dart
// -----------------------------------------------------------------------
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Provider/profile_provider_student.dart';
import '../../utils/app_constants.dart';

class AppColors {
  static const bg = Color(0xFF0A0A0A);
  static const card = Color(0xFF161616);
  static const cardBorder = Color(0xFF2A2A2A);
  static const divider = Color(0xFF262626);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF9C9C9C);
  static const textMuted = Color(0xFF6E6E6E);
  static const accent = Color(0xFFE8B84B);
  static const errorRed = Color(0xFFE85B5B);
  static const success = Color(0xFF2ECC71);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _rollNumberCtrl;
  late final TextEditingController _clubCtrl;
  late final TextEditingController _clubRoleCtrl;

  late String _branch;
  late String _course;
  late int _year;
  late String _initialSnapshot;

  // Avatar state
  String _avatarUrl = '';          // existing network URL
  File? _pickedImage;              // newly selected local file

  static const _bioMaxLength = 160;
  static const _years = AppConstants.yearNumbers;
  static const _courses = AppConstants.courses;
  static const _branches = AppConstants.branches;

  @override
  @override
  void initState() {
    super.initState();

    final p = context.read<ProfileProvider>();

    _fullNameCtrl = TextEditingController(text: p.fullName);
    _usernameCtrl = TextEditingController(
      text: p.username.startsWith('@')
          ? p.username.substring(1)
          : p.username,
    );
    _bioCtrl = TextEditingController(text: p.bio);
    _websiteCtrl = TextEditingController(text: p.website);
    _phoneCtrl = TextEditingController(text: p.phoneNumber);
    _rollNumberCtrl = TextEditingController(text: p.rollNumber);
    _branch = AppConstants.normalizeBranch(p.branch);

    // ✅ Missing controllers
    _clubCtrl = TextEditingController(
      text: p.clubName,
    );

    _clubRoleCtrl = TextEditingController(
      text: "student",
    );

    _avatarUrl = p.avatarUrl;
    _course = AppConstants.normalizeCourse(p.course).isEmpty
      ? 'Other'
      : AppConstants.normalizeCourse(p.course);
    _year = p.yearNumber > 0 ? p.yearNumber.clamp(1, 5) : 1;

    _initialSnapshot = _snapshot();
  }

  String _snapshot() => [
    _fullNameCtrl.text,
    _usernameCtrl.text,
    _bioCtrl.text,
    _websiteCtrl.text,
    _phoneCtrl.text,
    _rollNumberCtrl.text,
    _branch,
    _clubCtrl.text,
    _clubRoleCtrl.text,
    _avatarUrl,
    _pickedImage?.path ?? '',
    _course,
    _year.toString(),
  ].join('|');

  bool get _isDirty => _snapshot() != _initialSnapshot;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _websiteCtrl.dispose();
    _phoneCtrl.dispose();
    _rollNumberCtrl.dispose();
    _clubCtrl.dispose();
    _clubRoleCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // IMAGE PICKER
  // ─────────────────────────────────────────────────────────────
  Future<void> _showImageSourceSheet() async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            _ImageSourceTile(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
            _ImageSourceTile(
              icon: Icons.camera_alt_rounded,
              label: 'Take a Photo',
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_avatarUrl.isNotEmpty || _pickedImage != null) ...[
              const SizedBox(height: 10),
              _ImageSourceTile(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _pickedImage = null;
                    _avatarUrl = '';
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      setState(() {
        _pickedImage = File(file.path);
        // Keep network URL until save so we can fall back if needed
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pick image: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // VALIDATORS & HELPERS
  // ─────────────────────────────────────────────────────────────
  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Discard changes?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          "You have unsaved changes. If you leave now, they'll be lost.",
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Keep editing',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text(
              'Discard',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  String? _phoneValidator(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return null;
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digitsOnly.length < 7) return 'Enter a valid phone number';
    return null;
  }

  String? _urlValidator(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return null;
    final withScheme = value.startsWith('http') ? value : 'https://$value';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || !uri.hasAuthority) return 'Enter a valid URL';
    return null;
  }

  String _normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.startsWith('http') ? trimmed : 'https://$trimmed';
  }

  // ─────────────────────────────────────────────────────────────
  // SAVE
  // ─────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    HapticFeedback.mediumImpact();

    final provider = context.read<ProfileProvider>();

    final ok = await provider.submitProfileEdits(
      fullName: _fullNameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      website: _normalizeUrl(_websiteCtrl.text),
      phoneNumber: _phoneCtrl.text.trim(),
      rollNumber: _rollNumberCtrl.text.trim(),
      branch: AppConstants.normalizeBranch(_branch),
      course: _course,
      yearOfStudy: _year,

      // Pass the picked image directly
      profileImage: _pickedImage,
    );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't save your changes. Please try again."),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final syncWarning = provider.saveError;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          syncWarning ?? 'Profile updated successfully',
        ),
        backgroundColor: syncWarning != null
            ? Colors.orange.shade800
            : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    _initialSnapshot = _snapshot();

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProfileProvider>().isSaving;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Custom App Bar ────────────────────────────────
              _buildAppBar(isSaving),

              // ── Form ──────────────────────────────────────────
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    children: [
                      // Avatar
                      Center(
                        child: _AvatarPicker(
                          networkUrl: _avatarUrl,
                          localFile: _pickedImage,
                          onTap: _showImageSourceSheet,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _showImageSourceSheet,
                          child: const Text(
                            'Change Photo',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Personal
                      const _SectionLabel('PERSONAL INFO'),
                      _FormCard(
                        children: [
                          _FieldWrap(
                            label: 'Full name',
                            child: TextFormField(
                              controller: _fullNameCtrl,
                              textCapitalization: TextCapitalization.words,
                              validator: _requiredValidator,
                              style: _fieldStyle,
                              decoration: _inputDecoration('Your full name'),
                            ),
                          ),
                          _FieldWrap(
                            label: 'Username',
                            child: TextFormField(
                              controller: _usernameCtrl,
                              style: _fieldStyle,
                              decoration: _inputDecoration('username')
                                  .copyWith(prefixText: '@  '),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9._]'),
                                ),
                              ],
                            ),
                          ),
                          _FieldWrap(
                            label: 'Bio',
                            child: TextFormField(
                              controller: _bioCtrl,
                              maxLines: 3,
                              maxLength: _bioMaxLength,
                              style: _fieldStyle,
                              decoration: _inputDecoration(
                                'Tell people a bit about yourself',
                              ),
                            ),
                          ),
                          _FieldWrap(
                            label: 'Website',
                            isLast: true,
                            child: TextFormField(
                              controller: _websiteCtrl,
                              keyboardType: TextInputType.url,
                              validator: _urlValidator,
                              style: _fieldStyle,
                              decoration: _inputDecoration('yourwebsite.com'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _FormCard(
                        children: [
                          _FieldWrap(
                            label: 'Phone number',
                            isLast: true,
                            child: TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              validator: _phoneValidator,
                              style: _fieldStyle,
                              decoration:
                              _inputDecoration('+91 98765 43210'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),
                      const _SectionLabel('ACADEMIC INFO'),
                      _FormCard(
                        children: [
                          _FieldWrap(
                            label: 'Roll number',
                            child: TextFormField(
                              controller: _rollNumberCtrl,
                              style: _fieldStyle,
                              decoration:
                              _inputDecoration('e.g. 21BCS1042'),
                            ),
                          ),
                          _FieldWrap(
                            label: 'Branch',
                            child: DropdownButtonFormField<String>(
                              value: _branches.contains(_branch) ? _branch : null,
                              dropdownColor: AppColors.card,
                              style: _fieldStyle,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 6),
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textMuted),
                              items: _branches
                                  .map((branch) => DropdownMenuItem(
                                        value: branch,
                                        child: Text(branch),
                                      ))
                                  .toList(),
                              onChanged: (value) => setState(
                                () => _branch = value ?? _branch,
                              ),
                            ),
                          ),
                          _FieldWrap(
                            label: 'Course',
                            child: DropdownButtonFormField<String>(
                              value: _course,
                              dropdownColor: AppColors.card,
                              style: _fieldStyle,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 6),
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textMuted),
                              items: _courses
                                  .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _course = v ?? _course),
                            ),
                          ),
                          _FieldWrap(
                            label: 'Year of study',
                            isLast: true,
                            child: DropdownButtonFormField<int>(
                              value: _year,
                              dropdownColor: AppColors.card,
                              style: _fieldStyle,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 6),
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textMuted),
                              items: _years
                                  .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(_yearLabel(y)),
                              ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _year = v ?? _year),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),
                      const _SectionLabel('CLUB INFO'),
                      _FormCard(
                        children: [
                          _FieldWrap(
                            label: 'Club',
                            child: TextFormField(
                              controller: _clubCtrl,
                              textCapitalization: TextCapitalization.words,
                              style: _fieldStyle,
                              decoration:
                              _inputDecoration('e.g. GDSC / Robotics Club'),
                            ),
                          ),
                          _FieldWrap(
                            label: 'Club role',
                            isLast: true,
                            child: TextFormField(
                              controller: _clubRoleCtrl,
                              textCapitalization: TextCapitalization.words,
                              style: _fieldStyle,
                              decoration: _inputDecoration(
                                  'e.g. Lead Developer / President'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isSaving) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
            onPressed: () async {
              if (await _confirmDiscard() && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          const Expanded(
            child: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          TextButton(
            onPressed: isSaving ? null : _save,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              disabledForegroundColor: AppColors.textMuted,
            ),
            child: isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.accent,
              ),
            )
                : const Text(
              'SAVE',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _fieldStyle => const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: AppColors.textMuted,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(vertical: 6),
    counterStyle: const TextStyle(
      color: AppColors.textMuted,
      fontSize: 11,
    ),
  );

  String _yearLabel(int y) {
    const suffixes = {1: 'st', 2: 'nd', 3: 'rd'};
    final suffix = (y >= 11 && y <= 13) ? 'th' : (suffixes[y] ?? 'th');
    return '$y$suffix Year';
  }
}

// ─────────────────────────────────────────────────────────────────
// AVATAR PICKER
// ─────────────────────────────────────────────────────────────────
class _AvatarPicker extends StatelessWidget {
  final String networkUrl;
  final File? localFile;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.networkUrl,
    required this.localFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.06),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.grey.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F0F0F),
                ),
                child: ClipOval(
                  child: _buildImage(),
                ),
              ),
            ),
          ),
          // Edit badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bg, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.camera_alt_rounded,
                size: 17, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (localFile != null) {
      return Image.file(
        localFile!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => const ColoredBox(
    color: Color(0xFF1A1A1A),
    child: Icon(Icons.person_rounded, color: Colors.white38, size: 52),
  );
}

// ─────────────────────────────────────────────────────────────────
// IMAGE SOURCE TILE
// ─────────────────────────────────────────────────────────────────
class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.errorRed : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
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
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// FORM CARD
// ─────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// FIELD WRAP
// ─────────────────────────────────────────────────────────────────
class _FieldWrap extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isLast;

  const _FieldWrap({
    required this.label,
    required this.child,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ),
        child,
        if (!isLast)
          const Divider(height: 16, thickness: 0.7, color: AppColors.divider),
      ],
    );
  }
}