import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Provider/profile_provider_student.dart';

class EditClubProfileScreen extends StatefulWidget {
  const EditClubProfileScreen({super.key});

  @override
  State<EditClubProfileScreen> createState() => _EditClubProfileScreenState();
}

class _EditClubProfileScreenState extends State<EditClubProfileScreen> {
  static const bg = Color(0xFF0E0E0E);
  static const card = Color(0xFF1A1A1A);
  static const subtitle = Color(0xFFA0A0A0);
  static const accent = Color(0xFFE94B4B);

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _clubNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _facultyNameCtrl;
  late final TextEditingController _facultyEmailCtrl;
  late final TextEditingController _phoneCtrl;

  File? _pickedImage;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final p = context.read<ProfileProvider>();

    _clubNameCtrl = TextEditingController(
      text: p.clubName.isNotEmpty ? p.clubName : p.fullName,
    );
    _usernameCtrl = TextEditingController(
      text: p.username.replaceFirst('@', ''),
    );
    _bioCtrl = TextEditingController(text: p.bio);
    _descriptionCtrl = TextEditingController(text: p.clubDescription);
    _websiteCtrl = TextEditingController(text: p.website);
    _categoryCtrl = TextEditingController(text: p.category);
    _facultyNameCtrl = TextEditingController(text: p.facultyName);
    _facultyEmailCtrl = TextEditingController(text: p.facultyEmail);
    _phoneCtrl = TextEditingController(text: p.phoneNumber);
  }

  @override
  void dispose() {
    _clubNameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _descriptionCtrl.dispose();
    _websiteCtrl.dispose();
    _categoryCtrl.dispose();
    _facultyNameCtrl.dispose();
    _facultyEmailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _pickedImage = File(file.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();

    final ok = await provider.submitProfileEdits(
      fullName: _clubNameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      clubName: _clubNameCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      clubDescription: _descriptionCtrl.text.trim(),
      facultyName: _facultyNameCtrl.text.trim(),
      facultyEmail: _facultyEmailCtrl.text.trim(),
      profileImage: _pickedImage,
      isorganiser: true
    );

    if (!mounted) return;

    if (ok) {
      final msg = provider.saveError == null
          ? 'Profile updated'
          : 'Saved locally — ${provider.saveError}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor:
          provider.saveError == null ? Colors.green.shade700 : Colors.orange.shade800,
        ),
      );

      if (provider.saveError == null) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.saveError ?? 'Failed to save'),
          backgroundColor: accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final isSaving = profile.isSaving;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: isSaving ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Club Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSaving ? null : _save,
            child: isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            // ---- Avatar ----
            Center(
              child: GestureDetector(
                onTap: isSaving ? null : _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF2A2A2A),
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (profile.avatarUrl.isNotEmpty
                            ? NetworkImage(profile.avatarUrl)
                            : null) as ImageProvider?,
                        child: (_pickedImage == null &&
                            profile.avatarUrl.isEmpty)
                            ? const Icon(Icons.school,
                            color: Colors.white70, size: 40)
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: bg, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap to change photo',
                style: TextStyle(color: subtitle, fontSize: 12),
              ),
            ),
            const SizedBox(height: 28),

            _sectionLabel('Club identity'),
            _field(
              controller: _clubNameCtrl,
              label: 'Club name',
              icon: Icons.groups_outlined,
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            _field(
              controller: _usernameCtrl,
              label: 'Username',
              icon: Icons.alternate_email,
              prefixText: '@',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.contains(' ')) return 'No spaces';
                return null;
              },
            ),
            _field(
              controller: _categoryCtrl,
              label: 'Category',
              icon: Icons.category_outlined,
              hint: 'e.g. Technical, Cultural',
            ),
            _field(
              controller: _bioCtrl,
              label: 'Tagline',
              icon: Icons.short_text,
              hint: 'Innovate • Build • Learn',
              maxLines: 2,
            ),
            _field(
              controller: _descriptionCtrl,
              label: 'Description',
              icon: Icons.notes_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 16),
            _sectionLabel('Contact'),
            _field(
              controller: _websiteCtrl,
              label: 'Website',
              icon: Icons.language,
              keyboardType: TextInputType.url,
              hint: 'https://...',
            ),
            _field(
              controller: _phoneCtrl,
              label: 'Phone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            _field(
              controller: _facultyNameCtrl,
              label: 'Faculty advisor',
              icon: Icons.person_outline,
            ),
            _field(
              controller: _facultyEmailCtrl,
              label: 'Faculty email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),

            if (profile.saveError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile.saveError!,
                        style: const TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black,
                  ),
                )
                    : const Text(
                  'Save changes',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: subtitle,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefixText,
          prefixIcon: Icon(icon, color: subtitle, size: 20),
          labelStyle: const TextStyle(color: subtitle),
          hintStyle: TextStyle(color: subtitle.withOpacity(0.5)),
          prefixStyle: const TextStyle(color: Colors.white70, fontSize: 15),
          filled: true,
          fillColor: card,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white38),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent),
          ),
        ),
      ),
    );
  }
}