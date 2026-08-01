import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../model/notice_create_model.dart';
import '../provider/notice_form_provider.dart';

// ==========================================
// 🎨 APP DESIGN SYSTEM & COLOR PALETTE
// ==========================================
class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primarySoft = Color(0xFFEFF6FF);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF3B82F6);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}

// ==========================================
// 📱 MAIN SCREEN VIEW
// ==========================================
class CreateEditNoticeScreen extends StatelessWidget {
  final NoticeFormData? existing;

  const CreateEditNoticeScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoticeFormProvider(initial: existing),
      child: const _CreateEditNoticeView(),
    );
  }
}

class _CreateEditNoticeView extends StatefulWidget {
  const _CreateEditNoticeView();

  @override
  State<_CreateEditNoticeView> createState() => _CreateEditNoticeViewState();
}

class _CreateEditNoticeViewState extends State<_CreateEditNoticeView> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _departments = ['CSE', 'ECE', 'ME', 'CE', 'MBA'];
  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  final List<String> _roles = ['Students', 'Faculty', 'Staff'];

  // Local Form Controllers
  final TextEditingController _ctaLabelController = TextEditingController();
  final TextEditingController _ctaUrlController = TextEditingController();
  final TextEditingController _refNoController = TextEditingController();

  bool _hasCta = false;
  File? _coverFile;
  final List<File> _galleryFiles = [];
  final List<File> _attachmentFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<File?> _pickCoverImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<List<File>> _pickGalleryImages() async {
    final picked = await _picker.pickMultiImage();
    return picked.map((item) => File(item.path)).toList();
  }

  Future<File?> _pickFile() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return File(picked.path);
  }

  @override
  void dispose() {
    _ctaLabelController.dispose();
    _ctaUrlController.dispose();
    _refNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeFormProvider>();
    final form = provider.form;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              form.isEditMode ? 'Edit Notice' : 'Create Notice',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Publish to college portal & mobile app',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showPreviewModal(context, form),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Preview Card'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (provider.isSaving || provider.isPublishing)
              const LinearProgressIndicator(
                minHeight: 3,
                color: AppColors.primary,
                backgroundColor: AppColors.primarySoft,
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  // Publisher Info Banner
                  _buildPublisherCard(form),

                  const SizedBox(height: 16),

                  // 1. Core Notice Metadata
                  _FormCard(
                    title: '1. Notice Overview',
                    icon: Icons.article_outlined,
                    children: [
                      _buildLabel('Notice Title', isRequired: true),
                      TextFormField(
                        initialValue: form.title,
                        maxLength: 150,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                        decoration: _inputDecoration(
                          hint: 'e.g., Campus Placement Drive by Tech Corp - 2026 Batch',
                        ),
                        onChanged: provider.updateTitle,
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('Short Summary', isRequired: true),
                      TextFormField(
                        initialValue: form.summary,
                        maxLength: 220,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Summary is required' : null,
                        decoration: _inputDecoration(hint: 'A short description for the notice card'),
                        onChanged: provider.updateSummary,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Official Ref/Circular No.'),
                                TextFormField(
                                  controller: _refNoController,
                                  decoration: _inputDecoration(hint: 'CIR/2026/041'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Category', isRequired: true),
                                DropdownButtonFormField<String>(
                                  value: form.primaryCategory ?? 'General',
                                  decoration: _inputDecoration(),
                                  items: [
                                    'Placements',
                                    'Examinations',
                                    'Academics',
                                    'Fee & Scholarship',
                                    'Events & Clubs',
                                    'General'
                                  ]
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: provider.updateCategory,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // 2. Rich Body Content
                  _FormCard(
                    title: '2. Notice Description',
                    icon: Icons.notes_rounded,
                    children: [
                      _buildLabel('Full Details / Instructions', isRequired: true),
                      TextFormField(
                        initialValue: form.body,
                        maxLines: 7,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Body content is required' : null,
                        decoration: _inputDecoration(
                          hint: 'Write eligibility, schedule, venue, syllabus, or instructions here...',
                        ),
                        onChanged: provider.updateBody,
                      ),
                    ],
                  ),

                  // 3. Attachments & Media
                  _FormCard(
                    title: '3. Attachments & Files',
                    icon: Icons.attach_file_rounded,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final file = await _pickCoverImage();
                                if (file != null) {
                                  setState(() => _coverFile = file);
                                  provider.updateCoverImagePath(file.path);
                                }
                              },
                              icon: const Icon(Icons.image_outlined, size: 20),
                              label: const Text('Cover Image'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final files = await _pickGalleryImages();
                                if (files.isNotEmpty) {
                                  setState(() => _galleryFiles.addAll(files));
                                  provider.updateGalleryPaths(_galleryFiles.map((e) => e.path).toList());
                                }
                              },
                              icon: const Icon(Icons.photo_library_outlined, size: 20),
                              label: const Text('Gallery'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final file = await _pickFile();
                          if (file != null) {
                            setState(() {
                              _attachmentFiles.add(file);
                            });
                            provider.updateAttachmentPaths(_attachmentFiles.map((e) => e.path).toList());
                          }
                        },
                        icon: const Icon(Icons.attach_file_rounded, size: 20),
                        label: const Text('Attachments'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_attachmentFiles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ..._attachmentFiles.map((file) => _buildAttachmentTile(
                          file.path.split(Platform.pathSeparator).last,
                          '${file.lengthSync()} bytes',
                          Icons.attach_file_rounded,
                          AppColors.primary,
                        )),
                      ],
                    ],
                  ),

                  // 4. Granular Audience Targeting
                  _FormCard(
                    title: '4. Target Audience Filters',
                    icon: Icons.groups_outlined,
                    children: [
                      _buildLabel('Target User Roles'),
                      Wrap(
                        spacing: 8,
                        children: _roles.map((role) {
                          final isSelected = role == 'Students' || role == 'Faculty' || role == 'Staff';
                          return ChoiceChip(
                            label: Text(role),
                            selected: isSelected,
                            selectedColor: AppColors.primarySoft,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                            onSelected: (_) {},
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('Departments'),
                      Wrap(
                        spacing: 8,
                        children: _departments.map((dept) {
                          final isSelected = form.targetDepartments.contains(dept);
                          return FilterChip(
                            label: Text(dept),
                            selected: isSelected,
                            selectedColor: AppColors.primarySoft,
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                            ),
                            onSelected: (selected) {
                              final next = [...form.targetDepartments];
                              if (selected) {
                                next.add(dept);
                              } else {
                                next.remove(dept);
                              }
                              provider.updateAudienceLists(departments: next);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('Batches / Academic Years'),
                      Wrap(
                        spacing: 8,
                        children: _years.map((year) {
                          final isSelected = form.targetYears.contains(year);
                          return FilterChip(
                            label: Text(year),
                            selected: isSelected,
                            selectedColor: AppColors.primarySoft,
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                            ),
                            onSelected: (selected) {
                              final next = [...form.targetYears];
                              if (selected) {
                                next.add(year);
                              } else {
                                next.remove(year);
                              }
                              provider.updateAudienceLists(years: next);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // 5. Actionable Items, Deadlines & CTA
                  _FormCard(
                    title: '5. Action Link & Deadlines',
                    icon: Icons.event_available_outlined,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Add Action Button / Link',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Direct students to Google Forms, ERP, or portal',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        value: _hasCta,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _hasCta = val),
                      ),
                      if (_hasCta) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _ctaLabelController,
                                decoration: _inputDecoration(hint: 'e.g., Register Now'),
                                onChanged: (value) => provider.updateCta(text: value),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _ctaUrlController,
                                decoration: _inputDecoration(hint: 'https://forms.gle/...'),
                                onChanged: (value) => provider.updateCta(url: value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _DatePickerTile(
                              label: 'Event / Application Deadline',
                              value: form.scheduledAt,
                              icon: Icons.alarm_rounded,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(const Duration(days: 1)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) provider.updateScheduledAt(date);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DatePickerTile(
                              label: 'Auto-Archive Expiry Date',
                              value: form.expiresAt,
                              icon: Icons.auto_delete_outlined,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(const Duration(days: 30)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 730)),
                                );
                                if (date != null) provider.updateExpiresAt(date);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // 6. Priorities, Badging & Acknowledgements
                  _FormCard(
                    title: '6. Delivery Controls & Governance',
                    icon: Icons.notifications_active_outlined,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Mark as High Priority / Urgent',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Displays a red urgent badge on notice cards',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        value: form.isImportant,
                        activeColor: AppColors.error,
                        onChanged: provider.toggleImportant,
                      ),
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Pin to Top of Feed',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Keeps notice pinned at top regardless of age',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        value: form.isPinned,
                        activeColor: AppColors.primary,
                        onChanged: provider.togglePinned,
                      ),
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Allow Guest Access',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Lets visitors access the notice without logging in',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        value: form.allowGuestAccess,
                        activeColor: AppColors.warning,
                        onChanged: provider.updateAllowGuest,
                      ),
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Send Instant Push Notification',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Sends immediate push alert to targeted mobiles',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        value: form.sendPush,
                        activeColor: AppColors.primary,
                        onChanged: provider.togglePush,
                      ),
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Send Email Notification',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Includes the notice in email-based broadcasts',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        value: form.sendEmail,
                        activeColor: AppColors.primary,
                        onChanged: provider.toggleEmail,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: provider.isSaving || provider.isPublishing
                      ? null
                      : () async {
                    final ok = await provider.saveDraft();
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notice saved as draft')),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Draft', style: TextStyle(color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: provider.isSaving || provider.isPublishing
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      final ok = await provider.publish(
                        coverFiles: _coverFile == null ? const [] : [_coverFile!],
                        galleryFiles: _galleryFiles,
                        attachmentFiles: _attachmentFiles,
                      );
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notice published successfully!')),
                        );
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(form.publishType == PublishType.schedule ? 'Schedule Notice' : 'Publish Notice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Publisher Identity Card
  Widget _buildPublisherCard(NoticeFormData form) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.verified_user_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Publishing Authority',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(
                form.publisherName.isNotEmpty ? form.publisherName : 'Training & Placement Cell',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Uploaded Attachment Item Tile
  Widget _buildAttachmentTile(String fileName, String size, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(size, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // Live Student Preview Sheet
  void _showPreviewModal(BuildContext context, NoticeFormData form) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Student Feed Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            // Preview Notice Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          form.primaryCategory ?? 'General',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      if (form.isImportant) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    form.title.isNotEmpty ? form.title : 'Notice Title Placeholder',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    form.body.isNotEmpty ? form.body : 'Notice description content preview...',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String title, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderFocused, width: 1.5),
      ),
    );
  }
}

// ==========================================
// 🧩 REUSABLE HELPER WIDGETS
// ==========================================
class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.border),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final IconData icon;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(
                    value != null ? DateFormat('dd MMM yyyy').format(value!) : 'Select Date',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}