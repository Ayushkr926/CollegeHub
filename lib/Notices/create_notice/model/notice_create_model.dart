import '../../../utils/app_constants.dart';

enum PublishType { now, schedule, draft }
enum VisibilityType { public, collegeWide, campus, targeted }

extension PublishTypeX on PublishType {
  String get backendValue {
    switch (this) {
      case PublishType.now:
        return 'immediate';
      case PublishType.schedule:
        return 'scheduled';
      case PublishType.draft:
        return 'draft';
    }
  }
}

extension VisibilityTypeX on VisibilityType {
  String get backendValue {
    switch (this) {
      case VisibilityType.public:
        return 'public';
      case VisibilityType.collegeWide:
        return 'collegeWide';
      case VisibilityType.campus:
        return 'campus';
      case VisibilityType.targeted:
        return 'private';
    }
  }
}

class NoticeFormData {
  // 3.1 Basic
  String title;
  String summary;
  String publisherId;
  String publisherName;

  // 3.2 Content
  String body;
  String? coverImagePath;

  // 3.3 Classification
  String? primaryCategory;
  List<String> secondaryTags;
  List<String> customTags;

  // 3.4 Audience
  VisibilityType visibility;
  List<String> targetCampuses;
  List<String> targetDepartments;
  List<String> targetYears;
  List<String> targetProgrammes;
  bool allowGuestAccess;

  // 3.5 Schedule
  PublishType publishType;
  DateTime? scheduledAt;
  DateTime? expiresAt;
  bool autoArchive;

  // 3.6 Priority
  bool isImportant;
  bool isPinned;
  int? pinDurationHours;
  bool sendPush;
  bool sendEmail;

  // 3.7 Attachments
  List<String> attachmentPaths; // local paths for now

  // 3.8 Advanced
  String? templateId;
  String? internalRefNo;
  String? customCtaText;
  String? customCtaUrl;
  String? versionNotes; // edit mode only

  // Meta
  String? noticeId; // null = create mode
  bool get isEditMode => noticeId != null;

  NoticeFormData({
    this.title = '',
    this.summary = '',
    this.publisherId = '',
    this.publisherName = '',
    this.body = '',
    this.coverImagePath,
    this.primaryCategory,
    this.secondaryTags = const [],
    this.customTags = const [],
    this.visibility = VisibilityType.collegeWide,
    this.targetCampuses = const [],
    this.targetDepartments = const [],
    this.targetYears = const [],
    this.targetProgrammes = const [],
    this.allowGuestAccess = false,
    this.publishType = PublishType.now,
    this.scheduledAt,
    this.expiresAt,
    this.autoArchive = true,
    this.isImportant = false,
    this.isPinned = false,
    this.pinDurationHours,
    this.sendPush = true,
    this.sendEmail = false,
    this.attachmentPaths = const [],
    this.templateId,
    this.internalRefNo,
    this.customCtaText,
    this.customCtaUrl,
    this.versionNotes,
    this.noticeId,
  });

  NoticeFormData copyWith({
    String? title,
    String? summary,
    String? body,
    String? primaryCategory,
    List<String>? secondaryTags,
    List<String>? customTags,
    VisibilityType? visibility,
    PublishType? publishType,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    bool? isImportant,
    bool? isPinned,
    bool? sendPush,
    bool? sendEmail,
    bool? autoArchive,
    bool? allowGuestAccess,
    List<String>? attachmentPaths,
    List<String>? targetCampuses,
    List<String>? targetDepartments,
    List<String>? targetYears,
    List<String>? targetProgrammes,
    String? publisherId,
    String? publisherName,
    String? coverImagePath,
    String? templateId,
    String? internalRefNo,
    String? customCtaText,
    String? customCtaUrl,
    String? versionNotes,
    int? pinDurationHours,
    String? noticeId,
  }) {
    return NoticeFormData(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      secondaryTags: secondaryTags ?? this.secondaryTags,
      customTags: customTags ?? this.customTags,
      visibility: visibility ?? this.visibility,
      publishType: publishType ?? this.publishType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isImportant: isImportant ?? this.isImportant,
      isPinned: isPinned ?? this.isPinned,
      sendPush: sendPush ?? this.sendPush,
      sendEmail: sendEmail ?? this.sendEmail,
      autoArchive: autoArchive ?? this.autoArchive,
      allowGuestAccess: allowGuestAccess ?? this.allowGuestAccess,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      targetCampuses: targetCampuses ?? this.targetCampuses,
      targetDepartments: targetDepartments ?? this.targetDepartments,
      targetYears: targetYears ?? this.targetYears,
      targetProgrammes: targetProgrammes ?? this.targetProgrammes,
      publisherId: publisherId ?? this.publisherId,
      publisherName: publisherName ?? this.publisherName,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      templateId: templateId ?? this.templateId,
      internalRefNo: internalRefNo ?? this.internalRefNo,
      customCtaText: customCtaText ?? this.customCtaText,
      customCtaUrl: customCtaUrl ?? this.customCtaUrl,
      versionNotes: versionNotes ?? this.versionNotes,
      pinDurationHours: pinDurationHours ?? this.pinDurationHours,
      noticeId: noticeId ?? this.noticeId,
    );
  }

  Map<String, dynamic> toBackendPayload() {
    return {
      'title': title,
      'summary': summary,
      'body': body,
      'publisherId': publisherId,
      'publisherName': publisherName,
      'primaryCategory': primaryCategory,
      'secondaryTags': secondaryTags,
      'customTags': customTags,
        'visibility': visibility.backendValue,
        'targetCampuses': targetCampuses,
        'targetDepartments': AppConstants.normalizeBranches(targetDepartments),
        'targetYears': AppConstants.normalizeYears(targetYears),
        'targetProgrammes': AppConstants.normalizeCourses(targetProgrammes),
      'allowGuestAccess': allowGuestAccess,
      'publishType': publishType.backendValue,
      'scheduledAt': scheduledAt?.toUtc().toIso8601String(),
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
      'autoArchive': autoArchive,
      'isImportant': isImportant,
      'isPinned': isPinned,
      'pinDurationHours': pinDurationHours,
      'sendPush': sendPush,
      'sendEmail': sendEmail,
      'attachmentPaths': attachmentPaths,
      'templateId': templateId,
      'internalRefNo': internalRefNo,
      'customCtaText': customCtaText,
      'customCtaUrl': customCtaUrl,
      'versionNotes': versionNotes,
      'coverImagePath': coverImagePath,
    };
  }
}