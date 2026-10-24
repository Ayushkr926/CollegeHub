import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/notice_form_data.dart';
import '../providers/notice_provider.dart';
import '../../utils/app_constants.dart';
import 'notice_detail_screen.dart';

class NoticeFormScreen extends StatefulWidget {
  final NoticeModel? existingNotice;

  const NoticeFormScreen({super.key, this.existingNotice});

  bool get isEditing => existingNotice != null;

  @override
  State<NoticeFormScreen> createState() => _NoticeFormScreenState();
}

class _NoticeFormScreenState extends State<NoticeFormScreen> {
  late NoticeFormData _form;
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagInputController = TextEditingController();
  final _customTagInputController = TextEditingController();
  final _internalRefController = TextEditingController();
  final _ctaTextController = TextEditingController();
  final _ctaUrlController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  static const _categories = [
    'Academic', 'Events', 'Placement', 'Examination',
    'Administration', 'Sports', 'Other'
  ];
  static const _campuses = ['Main Campus', 'North Campus', 'South Campus'];
  static const _departments = AppConstants.branches;
  static const _years = AppConstants.years;
  static const _programmes = AppConstants.courses;

  // Dark theme colors
  static const _bg = Color(0xFF0D0D0D);
  static const _card = Color(0xFF161616);
  static const _border = Color(0xFF2A2A2A);
  static const _hint = Color(0xFF6B6B6B);
  static const _label = Color(0xFFB0B0B0);

  @override
  void initState() {
    super.initState();
    _form = widget.existingNotice != null
        ? NoticeFormData.fromNotice(widget.existingNotice!)
        : NoticeFormData();

    _titleController.text = _form.title;
    _summaryController.text = _form.summary;
    _bodyController.text = _form.body;
    _internalRefController.text = _form.internalRefNo ?? '';
    _ctaTextController.text = _form.customCtaText ?? '';
    _ctaUrlController.text = _form.customCtaUrl ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeProvider>().clearFormErrors();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _bodyController.dispose();
    _tagInputController.dispose();
    _customTagInputController.dispose();
    _internalRefController.dispose();
    _ctaTextController.dispose();
    _ctaUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _form.coverImageFile = File(picked.path));
    }
  }

  Future<void> _pickImages() async {
    final picked = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() => _form.imageFiles.addAll(picked.map((x) => File(x.path))));
    }
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _form.attachmentFiles.addAll(
          result.paths.whereType<String>().map((p) => File(p)),
        );
      });
    }
  }

  Future<void> _pickScheduledAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _form.scheduledAt ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: _card,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_form.scheduledAt ?? DateTime.now()),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: _card,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() {
      _form.scheduledAt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  Future<void> _pickExpiresAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _form.expiresAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: _card,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_form.expiresAt ?? DateTime.now()),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: _card,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() {
      _form.expiresAt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  void _syncControllersToForm() {
    _form.title = _titleController.text;
    _form.summary = _summaryController.text;
    _form.body = _bodyController.text;
    _form.internalRefNo =
    _internalRefController.text.trim().isEmpty ? null : _internalRefController.text.trim();
    _form.customCtaText =
    _ctaTextController.text.trim().isEmpty ? null : _ctaTextController.text.trim();
    _form.customCtaUrl =
    _ctaUrlController.text.trim().isEmpty ? null : _ctaUrlController.text.trim();
  }

  Future<void> _submit({bool asDraft = false}) async {
    _syncControllersToForm();
    if (asDraft) {
      _form.publishType = NoticePublishType.draft;
    }

    final provider = context.read<NoticeProvider>();
    final result = await provider.submitNotice(
      _form,
      existingId: widget.existingNotice?.id,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Notice updated' : 'Notice created'),
          backgroundColor: _card,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => NoticeDetailScreen(
            noticeId: result.id,
            canManageNotices: true,
          ),
        ),
      );
    } else if (provider.formErrors.isNotEmpty) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields.')),
      );
    } else if (provider.submitError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.submitError!)),
      );
    }
  }

  InputDecoration _inputDeco({
    String? label,
    String? hint,
    String? error,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      labelStyle: const TextStyle(color: _label, fontSize: 13),
      hintStyle: const TextStyle(color: _hint, fontSize: 14),
      filled: true,
      fillColor: _card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white54, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.isEditing ? 'Edit Notice' : 'Create Notice',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _submit(),
            child: const Text(
              'Publish',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<NoticeProvider>(
        builder: (context, provider, _) {
          final errors = provider.formErrors;

          return AbsorbPointer(
            absorbing: provider.isSubmitting,
            child: Opacity(
              opacity: provider.isSubmitting ? 0.55 : 1,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        // ── Cover Image ──────────────────────────────
                        _SectionTitle('Cover Image'),
                        const SizedBox(height: 8),
                        _CoverPicker(
                          form: _form,
                          onPick: _pickCoverImage,
                          onRemove: () => setState(() {
                            _form.coverImageFile = null;
                            _form.coverImagePath = null;
                          }),
                        ),

                        const SizedBox(height: 22),

                        // ── Title ────────────────────────────────────
                        _SectionTitle('Title'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: _inputDeco(
                            hint: 'Notice Title',
                            error: errors['title'],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Summary ──────────────────────────────────
                        _SectionTitle('Summary / Short description'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _summaryController,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: _inputDeco(
                            hint: 'Short preview shown in cards',
                            error: errors['summary'],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Body ─────────────────────────────────────
                        _SectionTitle('Body / Full content'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _bodyController,
                          maxLines: 7,
                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                          decoration: _inputDeco(
                            hint: 'Write the full notice content…',
                            error: errors['body'],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── Category + Tags ──────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionTitle('Category'),
                                  const SizedBox(height: 8),
                                  _DarkDropdown<String>(
                                    value: _form.primaryCategory.isEmpty
                                        ? null
                                        : _form.primaryCategory,
                                    hint: 'Select',
                                    items: _categories,
                                    error: errors['primaryCategory'],
                                    onChanged: (v) => setState(
                                          () => _form.primaryCategory = v ?? '',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionTitle('Tags'),
                                  const SizedBox(height: 8),
                                  _ChipInput(
                                    controller: _tagInputController,
                                    chips: _form.secondaryTags,
                                    onAdd: (v) => setState(() => _form.secondaryTags.add(v)),
                                    onRemove: (v) => setState(() => _form.secondaryTags.remove(v)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ── Visibility ───────────────────────────────
                        _SectionTitle('Visibility'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: NoticeVisibility.values.map((v) {
                            final selected = _form.visibility == v;
                            return ChoiceChip(
                              label: Text(v.label),
                              selected: selected,
                              onSelected: (_) => setState(() => _form.visibility = v),
                              selectedColor: Colors.white,
                              backgroundColor: _card,
                              labelStyle: TextStyle(
                                color: selected ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              side: BorderSide(
                                color: selected ? Colors.white : _border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }).toList(),
                        ),

                        // Audience targeting
                        if (_form.visibility != NoticeVisibility.public) ...[
                          const SizedBox(height: 16),
                          _SectionTitle('Audience'),
                          const SizedBox(height: 10),
                          if (_form.visibility == NoticeVisibility.campus ||
                              _form.visibility == NoticeVisibility.custom)
                            _MultiChipSelect(
                              label: 'Campus',
                              options: _campuses,
                              selected: _form.targetCampuses,
                              onChanged: (v) => setState(() => _form.targetCampuses = v),
                            ),
                          if (_form.visibility == NoticeVisibility.department ||
                              _form.visibility == NoticeVisibility.custom)
                            _MultiChipSelect(
                              label: 'Department',
                              options: _departments,
                              selected: _form.targetDepartments,
                              onChanged: (v) => setState(() => _form.targetDepartments = v),
                            ),
                          if (_form.visibility == NoticeVisibility.programme ||
                              _form.visibility == NoticeVisibility.custom)
                            _MultiChipSelect(
                              label: 'Programme',
                              options: _programmes,
                              selected: _form.targetProgrammes,
                              onChanged: (v) => setState(() => _form.targetProgrammes = v),
                            ),
                          if (_form.visibility == NoticeVisibility.custom)
                            _MultiChipSelect(
                              label: 'Year',
                              options: _years,
                              selected: _form.targetYears,
                              onChanged: (v) => setState(() => _form.targetYears = v),
                            ),
                        ],

                        const SizedBox(height: 22),

                        // ── Schedule ─────────────────────────────────
                        _SectionTitle('Schedule'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _DateTile(
                                label: 'Scheduled At',
                                value: _form.scheduledAt,
                                onTap: _pickScheduledAt,
                                onClear: () => setState(() => _form.scheduledAt = null),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DateTile(
                                label: 'Expires At',
                                value: _form.expiresAt,
                                onTap: _pickExpiresAt,
                                onClear: () => setState(() => _form.expiresAt = null),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Status toggles ───────────────────────────
                        _SectionTitle('Status'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ToggleChip(
                              label: 'Important',
                              selected: _form.isImportant,
                              onTap: () => setState(() => _form.isImportant = !_form.isImportant),
                            ),
                            _ToggleChip(
                              label: 'Pin',
                              selected: _form.isPinned,
                              onTap: () => setState(() => _form.isPinned = !_form.isPinned),
                            ),
                            _ToggleChip(
                              label: 'Auto-archive',
                              selected: _form.autoArchive,
                              onTap: () => setState(() => _form.autoArchive = !_form.autoArchive),
                            ),
                            _ToggleChip(
                              label: 'Draft',
                              selected: _form.publishType == NoticePublishType.draft,
                              onTap: () => setState(() {
                                _form.publishType = _form.publishType == NoticePublishType.draft
                                    ? NoticePublishType.now
                                    : NoticePublishType.draft;
                              }),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── CTA ──────────────────────────────────────
                        _SectionTitle('CTA'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ctaTextController,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: _inputDeco(hint: 'Custom CTA Text'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _ctaUrlController,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: _inputDeco(
                                  hint: 'URL',
                                  error: errors['customCtaUrl'],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Media ────────────────────────────────────
                        _SectionTitle('Media'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _MediaButton(
                              icon: Icons.attach_file_rounded,
                              label: 'Attachments',
                              count: _form.attachmentFiles.length +
                                  _form.existingAttachments.length,
                              onTap: _pickAttachments,
                            ),
                            const SizedBox(width: 10),
                            _MediaButton(
                              icon: Icons.photo_library_outlined,
                              label: 'Gallery',
                              count: _form.imageFiles.length +
                                  _form.existingImages.length,
                              onTap: _pickImages,
                            ),
                          ],
                        ),

                        // Show selected media previews
                        if (_form.imageFiles.isNotEmpty ||
                            _form.existingImages.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 72,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ..._form.existingImages.map(
                                      (m) => _Thumb(
                                    url: m.url,
                                    onRemove: () => setState(() {
                                      _form.existingImages.remove(m);
                                      _form.removedImageUrls.add(m.url);
                                    }),
                                  ),
                                ),
                                ..._form.imageFiles.map(
                                      (f) => _Thumb(
                                    file: f,
                                    onRemove: () =>
                                        setState(() => _form.imageFiles.remove(f)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (_form.attachmentFiles.isNotEmpty ||
                            _form.existingAttachments.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          ..._form.existingAttachments.map(
                                (m) => _AttachmentRow(
                              name: m.fileName ?? m.url.split('/').last,
                              onRemove: () => setState(() {
                                _form.existingAttachments.remove(m);
                                _form.removedAttachmentUrls.add(m.url);
                              }),
                            ),
                          ),
                          ..._form.attachmentFiles.map(
                                (f) => _AttachmentRow(
                              name: f.path.split(Platform.pathSeparator).last,
                              onRemove: () =>
                                  setState(() => _form.attachmentFiles.remove(f)),
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // ── Advanced ─────────────────────────────────
                        _SectionTitle('Advanced (Optional)'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _internalRefController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: _inputDeco(hint: 'Internal Reference No.'),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // ── Bottom Action Bar ────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      color: _bg,
                      border: Border(top: BorderSide(color: _border)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: provider.isSubmitting
                                    ? null
                                    : () => _submit(asDraft: true),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Save as Draft',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: FilledButton(
                                onPressed: provider.isSubmitting ? null : () => _submit(),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: provider.isSubmitting
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.black,
                                  ),
                                )
                                    : Text(
                                  widget.isEditing ? 'Save Changes' : 'Publish Notice',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small reusable widgets
// ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _CoverPicker extends StatelessWidget {
  final NoticeFormData form;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _CoverPicker({
    required this.form,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasCover = form.coverImageFile != null || form.coverImagePath != null;

    if (hasCover) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: form.coverImageFile != null
                ? Image.file(
              form.coverImageFile!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Image.network(
              form.coverImagePath!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            style: BorderStyle.solid,
            width: 1.2,
          ),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 32, color: Colors.white38),
                SizedBox(height: 8),
                Text(
                  'Add Cover Image',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3A3A3A)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(14),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DarkDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final String? error;
  final void Function(T?) onChanged;

  const _DarkDropdown({
    required this.value,
    required this.hint,
    required this.items,
    this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: const Color(0xFF1F1F1F),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
        errorText: error,
        filled: true,
        fillColor: const Color(0xFF161616),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _ChipInput extends StatelessWidget {
  final TextEditingController controller;
  final List<String> chips;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const _ChipInput({
    required this.controller,
    required this.chips,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Add tag',
            hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
            filled: true,
            fillColor: const Color(0xFF161616),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white54),
            ),
          ),
          onSubmitted: (v) {
            final t = v.trim();
            if (t.isNotEmpty && !chips.contains(t)) {
              onAdd(t);
              controller.clear();
            }
          },
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips
                .map(
                  (c) => Chip(
                label: Text(c, style: const TextStyle(fontSize: 12)),
                backgroundColor: const Color(0xFF1F1F1F),
                deleteIconColor: Colors.white54,
                labelStyle: const TextStyle(color: Colors.white),
                side: const BorderSide(color: Color(0xFF2A2A2A)),
                onDeleted: () => onRemove(c),
              ),
            )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _MultiChipSelect extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selected;
  final void Function(List<String>) onChanged;

  const _MultiChipSelect({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: options.map((opt) {
              final isSelected = selected.contains(opt);
              return FilterChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (sel) {
                  final updated = List<String>.from(selected);
                  if (sel) {
                    updated.add(opt);
                  } else {
                    updated.remove(opt);
                  }
                  onChanged(updated);
                },
                selectedColor: Colors.white,
                backgroundColor: const Color(0xFF161616),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected ? Colors.white : const Color(0xFF2A2A2A),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? '${value!.day}/${value!.month}/${value!.year}'
                        : 'Select',
                    style: TextStyle(
                      color: value != null ? Colors.white : const Color(0xFF6B6B6B),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (value != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(Icons.close, size: 14, color: Colors.white38),
                  )
                else
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: Colors.white38),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.white : const Color(0xFF2A2A2A),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                count > 0 ? '$label ($count)' : label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13.5,
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

class _Thumb extends StatelessWidget {
  final String? url;
  final File? file;
  final VoidCallback onRemove;

  const _Thumb({this.url, this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: file != null
                ? Image.file(file!, width: 72, height: 72, fit: BoxFit.cover)
                : Image.network(url!, width: 72, height: 72, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;

  const _AttachmentRow({required this.name, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              size: 18, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}