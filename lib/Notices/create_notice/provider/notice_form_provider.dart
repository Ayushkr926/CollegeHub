import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import '../model/notice_create_model.dart';
import '../../repositories/notice_repository.dart';

class NoticeFormProvider extends ChangeNotifier {
  NoticeFormProvider({NoticeFormData? initial, NoticeRepository? repository})
      : _repository = repository ?? NoticeRepository(),
        form = initial ??
            NoticeFormData(
              publisherId: 'current_user',
              publisherName: 'Placement Cell',
            ) {
    _startAutoSave();
  }

  final NoticeRepository _repository;
  NoticeFormData form;
  bool isSaving = false;
  bool isPublishing = false;
  String? error;
  final Map<String, String?> fieldErrors = {};

  Timer? _autoSaveTimer;

  bool get isEditMode => form.isEditMode;

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (form.title.isNotEmpty || form.body.isNotEmpty) {
        saveDraft(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  // ── Field updaters ──────────────────────────────────────
  void updateTitle(String v) {
    form = form.copyWith(title: v);
    _validateTitle();
    notifyListeners();
  }

  void updateSummary(String v) {
    form = form.copyWith(summary: v);
    notifyListeners();
  }

  void updatePublisherName(String v) {
    form = form.copyWith(publisherName: v);
    notifyListeners();
  }

  void updateBody(String v) {
    form = form.copyWith(body: v);
    _validateBody();
    notifyListeners();
  }

  void updateCategory(String? v) {
    form = form.copyWith(primaryCategory: v);
    _validateCategory();
    notifyListeners();
  }

  void updateVisibility(VisibilityType v) {
    form = form.copyWith(visibility: v);
    notifyListeners();
  }

  void updatePublishType(PublishType v) {
    form = form.copyWith(publishType: v);
    notifyListeners();
  }

  void updateCoverImagePath(String? path) {
    form = form.copyWith(coverImagePath: path);
    notifyListeners();
  }

  void updateAttachmentPaths(List<String> paths) {
    form = form.copyWith(attachmentPaths: paths);
    notifyListeners();
  }

  void updateGalleryPaths(List<String> paths) {
    form = form.copyWith(attachmentPaths: paths);
    notifyListeners();
  }

  void updateTags({List<String>? secondaryTags, List<String>? customTags}) {
    form = form.copyWith(
      secondaryTags: secondaryTags ?? form.secondaryTags,
      customTags: customTags ?? form.customTags,
    );
    notifyListeners();
  }

  void updateAudienceLists({
    List<String>? campuses,
    List<String>? departments,
    List<String>? years,
    List<String>? programmes,
  }) {
    form = form.copyWith(
      targetCampuses: campuses ?? form.targetCampuses,
      targetDepartments: departments ?? form.targetDepartments,
      targetYears: years ?? form.targetYears,
      targetProgrammes: programmes ?? form.targetProgrammes,
    );
    notifyListeners();
  }

  void updateScheduledAt(DateTime? v) {
    form = form.copyWith(scheduledAt: v);
    notifyListeners();
  }

  void updateExpiresAt(DateTime? v) {
    form = form.copyWith(expiresAt: v);
    notifyListeners();
  }

  void toggleImportant(bool v) {
    form = form.copyWith(isImportant: v, sendPush: v ? true : form.sendPush);
    notifyListeners();
  }

  void togglePinned(bool v) {
    form = form.copyWith(isPinned: v);
    notifyListeners();
  }

  void togglePush(bool v) {
    form = form.copyWith(sendPush: v);
    notifyListeners();
  }

  void toggleEmail(bool v) {
    form = form.copyWith(sendEmail: v);
    notifyListeners();
  }

  void updateCta({String? text, String? url}) {
    form = form.copyWith(
      customCtaText: text ?? form.customCtaText,
      customCtaUrl: url ?? form.customCtaUrl,
    );
    notifyListeners();
  }

  void updateRefNo(String? refNo) {
    form = form.copyWith(internalRefNo: refNo);
    notifyListeners();
  }

  void updateVersionNotes(String? notes) {
    form = form.copyWith(versionNotes: notes);
    notifyListeners();
  }

  void updateAllowGuest(bool value) {
    form = form.copyWith(allowGuestAccess: value);
    notifyListeners();
  }

  // ── Validation ──────────────────────────────────────────
  void _validateTitle() {
    if (form.title.trim().isEmpty) {
      fieldErrors['title'] = 'Title is required';
    } else if (form.title.length > 180) {
      fieldErrors['title'] = 'Max 180 characters';
    } else {
      fieldErrors.remove('title');
    }
  }

  void _validateBody() {
    if (form.body.trim().isEmpty) {
      fieldErrors['body'] = 'Body content is required';
    } else {
      fieldErrors.remove('body');
    }
  }

  void _validateCategory() {
    if (form.primaryCategory == null || form.primaryCategory!.isEmpty) {
      fieldErrors['category'] = 'Please select a category';
    } else {
      fieldErrors.remove('category');
    }
  }

  bool validateAll() {
    _validateTitle();
    _validateBody();
    _validateCategory();

    if (form.publishType == PublishType.schedule && form.scheduledAt == null) {
      fieldErrors['scheduledAt'] = 'Please select schedule date & time';
    } else {
      fieldErrors.remove('scheduledAt');
    }

    notifyListeners();
    return fieldErrors.isEmpty;
  }

  // ── Actions ─────────────────────────────────────────────
  Future<bool> saveDraft({bool silent = false}) async {
    if (!silent) {
      isSaving = true;
      notifyListeners();
    }

    try {
      form = form.copyWith(publishType: PublishType.draft);
      if (form.noticeId == null) {
        await _repository.createNotice(form: form);
      } else {
        await _repository.updateNotice(id: form.noticeId!, form: form);
      }
      error = null;
      return true;
    } catch (e) {
      error = 'Failed to save draft';
      return false;
    } finally {
      if (!silent) {
        isSaving = false;
        notifyListeners();
      }
    }
  }

  Future<bool> publish({List<File> coverFiles = const [], List<File> galleryFiles = const [], List<File> attachmentFiles = const []}) async {
    if (!validateAll()) return false;

    isPublishing = true;
    notifyListeners();

    try {
      form = form.copyWith(publishType: form.publishType == PublishType.schedule ? PublishType.schedule : PublishType.now);
      if (form.noticeId == null) {
        await _repository.createNotice(
          form: form,
          coverFiles: coverFiles,
          galleryFiles: galleryFiles,
          attachmentFiles: attachmentFiles,
        );
      } else {
        await _repository.updateNotice(
          id: form.noticeId!,
          form: form,
          coverFiles: coverFiles,
          galleryFiles: galleryFiles,
          attachmentFiles: attachmentFiles,
        );
      }
      error = null;
      return true;
    } catch (e) {
      error = 'Failed to publish notice';
      return false;
    } finally {
      isPublishing = false;
      notifyListeners();
    }
  }
}