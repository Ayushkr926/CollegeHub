import 'dart:io';
import '../../utils/app_constants.dart';

/// Publish type for a notice.
enum NoticePublishType { draft, now, scheduled }

/// Visibility scope for a notice.
enum NoticeVisibility { public, campus, department, programme, custom }

extension NoticePublishTypeX on NoticePublishType {
  String get apiValue {
    switch (this) {
      case NoticePublishType.draft:
        return 'draft';
      case NoticePublishType.now:
        return 'immediate';
      case NoticePublishType.scheduled:
        return 'scheduled';
    }
  }

  static NoticePublishType fromApi(String? value) {
    switch (value) {
      case 'now':
        return NoticePublishType.now;
      case 'scheduled':
        return NoticePublishType.scheduled;
      case 'draft':
      default:
        return NoticePublishType.draft;
    }
  }

  String get label {
    switch (this) {
      case NoticePublishType.draft:
        return 'Save as Draft';
      case NoticePublishType.now:
        return 'Publish Now';
      case NoticePublishType.scheduled:
        return 'Schedule';
    }
  }
}

extension NoticeVisibilityX on NoticeVisibility {
  String get apiValue {
    switch (this) {
      case NoticeVisibility.public:
        return 'public';
      case NoticeVisibility.campus:
        return 'campus';
      case NoticeVisibility.department:
        return 'department';
      case NoticeVisibility.programme:
        return 'programme';
      case NoticeVisibility.custom:
        return 'custom';
    }
  }

  static NoticeVisibility fromApi(String? value) {
    switch (value) {
      case 'campus':
        return NoticeVisibility.campus;
      case 'department':
        return NoticeVisibility.department;
      case 'programme':
        return NoticeVisibility.programme;
      case 'custom':
        return NoticeVisibility.custom;
      case 'public':
      default:
        return NoticeVisibility.public;
    }
  }

  String get label {
    switch (this) {
      case NoticeVisibility.public:
        return 'Public';
      case NoticeVisibility.campus:
        return 'Campus';
      case NoticeVisibility.department:
        return 'Department';
      case NoticeVisibility.programme:
        return 'Programme';
      case NoticeVisibility.custom:
        return 'Custom Audience';
    }
  }
}

/// Represents an attachment/media item already stored on the backend.
class NoticeMediaItem {
  final String url;
  final String? id;
  final String? fileName;
  final String? mimeType;
  final int? sizeBytes;

  const NoticeMediaItem({
    required this.url,
    this.id,
    this.fileName,
    this.mimeType,
    this.sizeBytes,
  });

  factory NoticeMediaItem.fromJson(Map<String, dynamic> json) {
    return NoticeMediaItem(
      url: json['url']?.toString() ?? '',
      id: json['id']?.toString() ?? json['_id']?.toString(),
      fileName: json['fileName']?.toString() ?? json['name']?.toString(),
      mimeType: json['mimeType']?.toString() ?? json['type']?.toString(),
      sizeBytes: json['sizeBytes'] is int
          ? json['sizeBytes'] as int
          : int.tryParse(json['sizeBytes']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        if (id != null) 'id': id,
        if (fileName != null) 'fileName': fileName,
        if (mimeType != null) 'mimeType': mimeType,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
      };
}

/// Full form-data model used by the Create/Edit Notice screen.
///
/// Local `File` fields (coverImageFile, imageFiles, attachmentFiles) are used
/// for newly picked media that must be uploaded via multipart/form-data.
/// The `existing*` fields hold media already on the server that should be
/// preserved unless explicitly removed (see [removedImageUrls] and
/// [removedAttachmentUrls]).
class NoticeFormData {
  // Core content
  String title;
  String summary;
  String body;
  String? publisherId;
  String? publisherName;

  // Categorization
  String primaryCategory;
  List<String> secondaryTags;
  List<String> customTags;

  // Visibility / targeting
  NoticeVisibility visibility;
  List<String> targetCampuses;
  List<String> targetDepartments;
  List<String> targetYears;
  List<String> targetProgrammes;
  bool allowGuestAccess;

  // Publishing
  NoticePublishType publishType;
  DateTime? scheduledAt;
  DateTime? expiresAt;
  bool autoArchive;

  // Prominence
  bool isImportant;
  bool isPinned;
  int? pinDurationHours;

  // Notifications
  bool sendPush;
  bool sendEmail;

  // Media - existing (already uploaded, from server)
  String? coverImagePath; // existing cover image URL
  List<NoticeMediaItem> existingImages;
  List<NoticeMediaItem> existingAttachments;

  // Media - newly picked local files (to be uploaded)
  File? coverImageFile;
  List<File> imageFiles;
  List<File> attachmentFiles;

  // Media - removals (existing media the user removed while editing)
  List<String> removedImageUrls;
  List<String> removedAttachmentUrls;

  // Misc / advanced
  String? templateId;
  String? internalRefNo;
  String? customCtaText;
  String? customCtaUrl;
  String? versionNotes;

  // Server-assigned (populated when editing an existing notice)
  String? id;

  NoticeFormData({
    this.id,
    this.title = '',
    this.summary = '',
    this.body = '',
    this.publisherId,
    this.publisherName,
    this.primaryCategory = '',
    List<String>? secondaryTags,
    List<String>? customTags,
    this.visibility = NoticeVisibility.public,
    List<String>? targetCampuses,
    List<String>? targetDepartments,
    List<String>? targetYears,
    List<String>? targetProgrammes,
    this.allowGuestAccess = false,
    this.publishType = NoticePublishType.draft,
    this.scheduledAt,
    this.expiresAt,
    this.autoArchive = false,
    this.isImportant = false,
    this.isPinned = false,
    this.pinDurationHours,
    this.sendPush = false,
    this.sendEmail = false,
    this.coverImagePath,
    List<NoticeMediaItem>? existingImages,
    List<NoticeMediaItem>? existingAttachments,
    this.coverImageFile,
    List<File>? imageFiles,
    List<File>? attachmentFiles,
    List<String>? removedImageUrls,
    List<String>? removedAttachmentUrls,
    this.templateId,
    this.internalRefNo,
    this.customCtaText,
    this.customCtaUrl,
    this.versionNotes,
  })  : secondaryTags = secondaryTags ?? [],
        customTags = customTags ?? [],
        targetCampuses = targetCampuses ?? [],
        targetDepartments = targetDepartments ?? [],
        targetYears = targetYears ?? [],
        targetProgrammes = targetProgrammes ?? [],
        existingImages = existingImages ?? [],
        existingAttachments = existingAttachments ?? [],
        imageFiles = imageFiles ?? [],
        attachmentFiles = attachmentFiles ?? [],
        removedImageUrls = removedImageUrls ?? [],
        removedAttachmentUrls = removedAttachmentUrls ?? [];

  /// Build form data from an existing NoticeModel (edit flow).
  factory NoticeFormData.fromNotice(NoticeModel notice) {
    return NoticeFormData(
      id: notice.id,
      title: notice.title,
      summary: notice.summary,
      body: notice.body,
      publisherId: notice.publisherId,
      publisherName: notice.publisherName,
      primaryCategory: notice.primaryCategory,
      secondaryTags: List<String>.from(notice.secondaryTags),
      customTags: List<String>.from(notice.customTags),
      visibility: notice.visibility,
      targetCampuses: List<String>.from(notice.targetCampuses),
      targetDepartments: AppConstants.normalizeBranches(notice.targetDepartments),
      targetYears: AppConstants.yearLabels(notice.targetYears),
      targetProgrammes: AppConstants.normalizeCourses(notice.targetProgrammes),
      allowGuestAccess: notice.allowGuestAccess,
      publishType: notice.isDraft
          ? NoticePublishType.draft
          : (notice.scheduledAt != null && notice.scheduledAt!.isAfter(DateTime.now()))
              ? NoticePublishType.scheduled
              : NoticePublishType.now,
      scheduledAt: notice.scheduledAt,
      expiresAt: notice.expiresAt,
      autoArchive: notice.autoArchive,
      isImportant: notice.isImportant,
      isPinned: notice.isPinned,
      pinDurationHours: notice.pinDurationHours,
      sendPush: false,
      sendEmail: false,
      coverImagePath: notice.coverImageUrl,
      existingImages: List<NoticeMediaItem>.from(notice.images),
      existingAttachments: List<NoticeMediaItem>.from(notice.attachments),
      templateId: notice.templateId,
      internalRefNo: notice.internalRefNo,
      customCtaText: notice.customCtaText,
      customCtaUrl: notice.customCtaUrl,
      versionNotes: null,
    );
  }

  /// Validation. Returns a map of field -> error message. Empty if valid.
  Map<String, String> validate() {
    final errors = <String, String>{};

    if (title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    } else if (title.trim().length < 3) {
      errors['title'] = 'Title must be at least 3 characters';
    } else if (title.trim().length > 150) {
      errors['title'] = 'Title must be under 150 characters';
    }

    if (summary.trim().isEmpty) {
      errors['summary'] = 'Summary is required';
    } else if (summary.trim().length > 300) {
      errors['summary'] = 'Summary must be under 300 characters';
    }

    if (body.trim().isEmpty) {
      errors['body'] = 'Body content is required';
    }

    if (primaryCategory.trim().isEmpty) {
      errors['primaryCategory'] = 'Please select a category';
    }

    if (publishType == NoticePublishType.scheduled && scheduledAt == null) {
      errors['scheduledAt'] = 'Please pick a scheduled date/time';
    }
    if (publishType == NoticePublishType.scheduled &&
        scheduledAt != null &&
        scheduledAt!.isBefore(DateTime.now())) {
      errors['scheduledAt'] = 'Scheduled time must be in the future';
    }

    if (expiresAt != null && scheduledAt != null && expiresAt!.isBefore(scheduledAt!)) {
      errors['expiresAt'] = 'Expiry must be after the scheduled/publish time';
    }
    if (expiresAt != null &&
        publishType != NoticePublishType.scheduled &&
        expiresAt!.isBefore(DateTime.now())) {
      errors['expiresAt'] = 'Expiry must be in the future';
    }

    if (isPinned && pinDurationHours != null && pinDurationHours! <= 0) {
      errors['pinDurationHours'] = 'Pin duration must be greater than 0';
    }

    if (visibility == NoticeVisibility.campus && targetCampuses.isEmpty) {
      errors['targetCampuses'] = 'Select at least one campus';
    }
    if (visibility == NoticeVisibility.department && targetDepartments.isEmpty) {
      errors['targetDepartments'] = 'Select at least one department';
    }
    if (visibility == NoticeVisibility.programme && targetProgrammes.isEmpty) {
      errors['targetProgrammes'] = 'Select at least one programme';
    }

    if ((customCtaText != null && customCtaText!.trim().isNotEmpty) &&
        (customCtaUrl == null || customCtaUrl!.trim().isEmpty)) {
      errors['customCtaUrl'] = 'CTA URL is required when CTA text is set';
    }
    if ((customCtaUrl != null && customCtaUrl!.trim().isNotEmpty)) {
      final uri = Uri.tryParse(customCtaUrl!.trim());
      if (uri == null || !(uri.isScheme('HTTP') || uri.isScheme('HTTPS'))) {
        errors['customCtaUrl'] = 'Enter a valid URL (http/https)';
      }
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  /// Fields (non-file) as a JSON-serializable map for the request body.
  /// File fields are handled separately by the API service as multipart parts.
  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'summary': summary.trim(),
      'body': body,
      if (publisherId != null) 'publisherId': publisherId,
      if (publisherName != null) 'publisherName': publisherName,
      'primaryCategory': primaryCategory,
      'secondaryTags': secondaryTags,
      'customTags': customTags,
      'visibility': visibility.apiValue,
      'targetCampuses': targetCampuses,
      'targetDepartments': AppConstants.normalizeBranches(targetDepartments),
      'targetYears': AppConstants.normalizeYears(targetYears),
      'targetProgrammes': AppConstants.normalizeCourses(targetProgrammes),
      'allowGuestAccess': allowGuestAccess,
      'publishType': publishType.apiValue,
      if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      'autoArchive': autoArchive,
      'isImportant': isImportant,
      'isPinned': isPinned,
      if (pinDurationHours != null) 'pinDurationHours': pinDurationHours,
      'sendPush': sendPush,
      'sendEmail': sendEmail,
      if (templateId != null && templateId!.isNotEmpty) 'templateId': templateId,
      if (internalRefNo != null && internalRefNo!.isNotEmpty) 'internalRefNo': internalRefNo,
      if (customCtaText != null && customCtaText!.isNotEmpty) 'customCtaText': customCtaText,
      if (customCtaUrl != null && customCtaUrl!.isNotEmpty) 'customCtaUrl': customCtaUrl,
      if (versionNotes != null && versionNotes!.isNotEmpty) 'versionNotes': versionNotes,
      // Preserve remaining existing media (server merges this with new uploads)
      'existingImageUrls': existingImages.map((e) => e.url).toList(),
      'existingAttachmentUrls': existingAttachments.map((e) => e.url).toList(),
      if (removedImageUrls.isNotEmpty) 'removedImageUrls': removedImageUrls,
      if (removedAttachmentUrls.isNotEmpty) 'removedAttachmentUrls': removedAttachmentUrls,
      if (coverImageFile == null && coverImagePath != null) 'existingCoverImageUrl': coverImagePath,
    };
  }

  NoticeFormData copyWith({
    String? title,
    String? summary,
    String? body,
    String? primaryCategory,
    List<String>? secondaryTags,
    List<String>? customTags,
    NoticeVisibility? visibility,
    List<String>? targetCampuses,
    List<String>? targetDepartments,
    List<String>? targetYears,
    List<String>? targetProgrammes,
    bool? allowGuestAccess,
    NoticePublishType? publishType,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    bool? autoArchive,
    bool? isImportant,
    bool? isPinned,
    int? pinDurationHours,
    bool? sendPush,
    bool? sendEmail,
    File? coverImageFile,
    List<File>? imageFiles,
    List<File>? attachmentFiles,
    String? templateId,
    String? internalRefNo,
    String? customCtaText,
    String? customCtaUrl,
    String? versionNotes,
  }) {
    return NoticeFormData(
      id: id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      publisherId: publisherId,
      publisherName: publisherName,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      secondaryTags: secondaryTags ?? List<String>.from(this.secondaryTags),
      customTags: customTags ?? List<String>.from(this.customTags),
      visibility: visibility ?? this.visibility,
      targetCampuses: targetCampuses ?? List<String>.from(this.targetCampuses),
      targetDepartments: targetDepartments ?? List<String>.from(this.targetDepartments),
      targetYears: targetYears ?? List<String>.from(this.targetYears),
      targetProgrammes: targetProgrammes ?? List<String>.from(this.targetProgrammes),
      allowGuestAccess: allowGuestAccess ?? this.allowGuestAccess,
      publishType: publishType ?? this.publishType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      autoArchive: autoArchive ?? this.autoArchive,
      isImportant: isImportant ?? this.isImportant,
      isPinned: isPinned ?? this.isPinned,
      pinDurationHours: pinDurationHours ?? this.pinDurationHours,
      sendPush: sendPush ?? this.sendPush,
      sendEmail: sendEmail ?? this.sendEmail,
      coverImagePath: coverImagePath,
      existingImages: List<NoticeMediaItem>.from(existingImages),
      existingAttachments: List<NoticeMediaItem>.from(existingAttachments),
      coverImageFile: coverImageFile ?? this.coverImageFile,
      imageFiles: imageFiles ?? List<File>.from(this.imageFiles),
      attachmentFiles: attachmentFiles ?? List<File>.from(this.attachmentFiles),
      removedImageUrls: List<String>.from(removedImageUrls),
      removedAttachmentUrls: List<String>.from(removedAttachmentUrls),
      templateId: templateId ?? this.templateId,
      internalRefNo: internalRefNo ?? this.internalRefNo,
      customCtaText: customCtaText ?? this.customCtaText,
      customCtaUrl: customCtaUrl ?? this.customCtaUrl,
      versionNotes: versionNotes ?? this.versionNotes,
    );
  }
}

/// Read model returned by the backend for list/detail views.
class NoticeModel {
  final String id;
  final String title;
  final String summary;
  final String body;
  final String? publisherId;
  final String? publisherName;
  final String? publisherAvatarUrl;

  final String primaryCategory;
  final List<String> secondaryTags;
  final List<String> customTags;

  final NoticeVisibility visibility;
  final List<String> targetCampuses;
  final List<String> targetDepartments;
  final List<String> targetYears;
  final List<String> targetProgrammes;
  final bool allowGuestAccess;

  final bool isDraft;
  final bool isPublished;
  final bool isArchived;
  final bool isExpired;
  final bool isDeleted;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;
  final bool autoArchive;

  final bool isImportant;
  final bool isPinned;
  final int? pinDurationHours;
  final DateTime? pinnedAt;

  final String? coverImageUrl;
  final List<NoticeMediaItem> images;
  final List<NoticeMediaItem> attachments;

  final String? templateId;
  final String? internalRefNo;
  final String? customCtaText;
  final String? customCtaUrl;

  final int viewCount;
  final int likeCount;
  final int bookmarkCount;
  final bool isLikedByMe;
  final bool isBookmarkedByMe;
  final bool isReadByMe;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    this.publisherId,
    this.publisherName,
    this.publisherAvatarUrl,
    required this.primaryCategory,
    this.secondaryTags = const [],
    this.customTags = const [],
    this.visibility = NoticeVisibility.public,
    this.targetCampuses = const [],
    this.targetDepartments = const [],
    this.targetYears = const [],
    this.targetProgrammes = const [],
    this.allowGuestAccess = false,
    this.isDraft = false,
    this.isPublished = false,
    this.isArchived = false,
    this.isExpired = false,
    this.isDeleted = false,
    this.scheduledAt,
    this.expiresAt,
    this.autoArchive = false,
    this.isImportant = false,
    this.isPinned = false,
    this.pinDurationHours,
    this.pinnedAt,
    this.coverImageUrl,
    this.images = const [],
    this.attachments = const [],
    this.templateId,
    this.internalRefNo,
    this.customCtaText,
    this.customCtaUrl,
    this.viewCount = 0,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.isLikedByMe = false,
    this.isBookmarkedByMe = false,
    this.isReadByMe = false,
    required this.createdAt,
    this.updatedAt,
  });

  bool get hasCta =>
      (customCtaText != null && customCtaText!.trim().isNotEmpty) &&
      (customCtaUrl != null && customCtaUrl!.trim().isNotEmpty);

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    List<String> parseStringList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    List<NoticeMediaItem> parseMediaList(dynamic v) {
      if (v is List) {
        return v.map((e) {
          if (e is Map<String, dynamic>) return NoticeMediaItem.fromJson(e);
          if (e is String) return NoticeMediaItem(url: e);
          return const NoticeMediaItem(url: '');
        }).where((m) => m.url.isNotEmpty).toList();
      }
      return [];
    }

    final status = json['status']?.toString().toLowerCase();

    return NoticeModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      publisherId: json['publisherId']?.toString(),
      publisherName: json['publisherName']?.toString(),
      publisherAvatarUrl: json['publisherAvatarUrl']?.toString(),
      primaryCategory: json['primaryCategory']?.toString() ?? '',
      secondaryTags: parseStringList(json['secondaryTags']),
      customTags: parseStringList(json['customTags']),
      visibility: NoticeVisibilityX.fromApi(json['visibility']?.toString()),
      targetCampuses: parseStringList(json['targetCampuses']),
      targetDepartments: AppConstants.normalizeBranches(
        parseStringList(json['targetDepartments']),
      ),
      targetYears: AppConstants.yearLabels(parseStringList(json['targetYears'])),
      targetProgrammes: AppConstants.normalizeCourses(
        parseStringList(json['targetProgrammes']),
      ),
      allowGuestAccess: json['allowGuestAccess'] == true,
      isDraft: json['isDraft'] == true || status == 'draft',
      isPublished: json['isPublished'] == true || status == 'published',
      isArchived: json['isArchived'] == true || status == 'archived',
      isExpired: json['isExpired'] == true || status == 'expired',
      isDeleted: json['isDeleted'] == true,
      scheduledAt: parseDate(json['scheduledAt']),
      expiresAt: parseDate(json['expiresAt']),
      autoArchive: json['autoArchive'] == true,
      isImportant: json['isImportant'] == true,
      isPinned: json['isPinned'] == true,
      pinDurationHours: json['pinDurationHours'] is int
          ? json['pinDurationHours'] as int
          : int.tryParse(json['pinDurationHours']?.toString() ?? ''),
      pinnedAt: parseDate(json['pinnedAt']),
      coverImageUrl: json['coverImagePath']?.toString() ?? json['coverImageUrl']?.toString(),
      images: parseMediaList(json['images']),
      attachments: parseMediaList(json['attachments'] ?? json['attachmentPaths']),
      templateId: json['templateId']?.toString(),
      internalRefNo: json['internalRefNo']?.toString(),
      customCtaText: json['customCtaText']?.toString(),
      customCtaUrl: json['customCtaUrl']?.toString(),
      viewCount: json['viewCount'] is int ? json['viewCount'] as int : 0,
      likeCount: json['likeCount'] is int ? json['likeCount'] as int : 0,
      bookmarkCount: json['bookmarkCount'] is int ? json['bookmarkCount'] as int : 0,
      isLikedByMe: json['isLikedByMe'] == true,
      isBookmarkedByMe: json['isBookmarkedByMe'] == true,
      isReadByMe: json['isReadByMe'] == true,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  NoticeModel copyWith({
    bool? isLikedByMe,
    int? likeCount,
    bool? isBookmarkedByMe,
    int? bookmarkCount,
    bool? isReadByMe,
    bool? isPinned,
    bool? isPublished,
    bool? isDraft,
    bool? isArchived,
    bool? isDeleted,
  }) {
    return NoticeModel(
      id: id,
      title: title,
      summary: summary,
      body: body,
      publisherId: publisherId,
      publisherName: publisherName,
      publisherAvatarUrl: publisherAvatarUrl,
      primaryCategory: primaryCategory,
      secondaryTags: secondaryTags,
      customTags: customTags,
      visibility: visibility,
      targetCampuses: targetCampuses,
      targetDepartments: targetDepartments,
      targetYears: targetYears,
      targetProgrammes: targetProgrammes,
      allowGuestAccess: allowGuestAccess,
      isDraft: isDraft ?? this.isDraft,
      isPublished: isPublished ?? this.isPublished,
      isArchived: isArchived ?? this.isArchived,
      isExpired: isExpired,
      isDeleted: isDeleted ?? this.isDeleted,
      scheduledAt: scheduledAt,
      expiresAt: expiresAt,
      autoArchive: autoArchive,
      isImportant: isImportant,
      isPinned: isPinned ?? this.isPinned,
      pinDurationHours: pinDurationHours,
      pinnedAt: pinnedAt,
      coverImageUrl: coverImageUrl,
      images: images,
      attachments: attachments,
      templateId: templateId,
      internalRefNo: internalRefNo,
      customCtaText: customCtaText,
      customCtaUrl: customCtaUrl,
      viewCount: viewCount,
      likeCount: likeCount ?? this.likeCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isBookmarkedByMe: isBookmarkedByMe ?? this.isBookmarkedByMe,
      isReadByMe: isReadByMe ?? this.isReadByMe,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Paginated list response wrapper for GET /notices and similar endpoints.
class NoticeListResult {
  final List<NoticeModel> items;
  final int? page;
  final int? limit;
  final int? total;
  final String? nextCursor;
  final bool hasMore;

  const NoticeListResult({
    required this.items,
    this.page,
    this.limit,
    this.total,
    this.nextCursor,
    this.hasMore = false,
  });
  factory NoticeListResult.fromJson(Map<String, dynamic> json) {
    final data =
    json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawItems =
    (data['notices'] ??
        json['items'] ??
        json['notices'] ??
        []) as List;

    final items = rawItems
        .whereType<Map>()
        .map((e) => NoticeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final pagination =
    data['pagination'] is Map
        ? Map<String, dynamic>.from(data['pagination'])
        : (json['pagination'] is Map
        ? Map<String, dynamic>.from(json['pagination'])
        : <String, dynamic>{});

    return NoticeListResult(
      items: items,
      page: pagination['page'],
      limit: pagination['limit'],
      total: pagination['total'],
      nextCursor: pagination['nextCursor']?.toString(),
      hasMore: pagination['hasMore'] == true,
    );
  }
}

/// Filter/query parameters for GET /notices (list) requests.
class NoticeQueryFilters {
  int? page;
  int? limit;
  String? cursor;
  String? sort; // e.g. 'createdAt', 'title'
  String? order; // 'asc' | 'desc'

  String? search;
  String? category;
  String? status;
  List<String> tags;
  String? department;
  String? campus;
  String? programme;
  String? year;

  String? publisher;
  NoticeVisibility? visibility;
  bool? important;
  bool? pinned;
  bool? draft;
  bool? scheduled;
  bool? expired;

  DateTime? createdAfter;
  DateTime? createdBefore;
  bool? createdByMe;
  bool? bookmarked;

  NoticeQueryFilters({
    this.page,
    this.limit = 20,
    this.cursor,
    this.sort = 'createdAt',
    this.order = 'desc',
    this.search,
    this.category,
    this.status,
    List<String>? tags,
    this.department,
    this.campus,
    this.programme,
    this.year,
    this.publisher,
    this.visibility,
    this.important,
    this.pinned,
    this.draft,
    this.scheduled,
    this.expired,
    this.createdAfter,
    this.createdBefore,
    this.createdByMe,
    this.bookmarked,
  }) : tags = tags ?? [];

  Map<String, dynamic> toQueryParams() {
    final map = <String, dynamic>{};
    void add(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is List && value.isEmpty) return;
      map[key] = value is List ? value.join(',') : value;
    }

    add('page', page);
    add('limit', limit);
    add('cursor', cursor);
    add('sort', sort);
    add('order', order);
    add('search', search);
    add('category', category);
    add('status', status);
    add('tags', tags);
    add('department', department == null ? null : AppConstants.normalizeBranch(department));
    add('campus', campus);
    add('programme', programme == null ? null : AppConstants.normalizeCourse(programme));
    add('year', AppConstants.normalizeYear(year)?.toString());
    add('publisher', publisher);
    add('visibility', visibility?.apiValue);
    add('important', important);
    add('pinned', pinned);
    add('draft', draft);
    add('scheduled', scheduled);
    add('expired', expired);
    add('createdAfter', createdAfter?.toIso8601String());
    add('createdBefore', createdBefore?.toIso8601String());
    add('createdByMe', createdByMe);
    add('bookmarked', bookmarked);

    return map;
  }

  NoticeQueryFilters copyWith({
    int? page,
    int? limit,
    String? cursor,
    String? sort,
    String? order,
    String? search,
    String? category,
    String? status,
    List<String>? tags,
    String? department,
    String? campus,
    String? programme,
    String? year,
    String? publisher,
    NoticeVisibility? visibility,
    bool? important,
    bool? pinned,
    bool? draft,
    bool? scheduled,
    bool? expired,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool? createdByMe,
    bool? bookmarked,
  }) {
    return NoticeQueryFilters(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      cursor: cursor ?? this.cursor,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      search: search ?? this.search,
      category: category ?? this.category,
      status: status ?? this.status,
      tags: tags ?? List<String>.from(this.tags),
      department: department ?? this.department,
      campus: campus ?? this.campus,
      programme: programme ?? this.programme,
      year: year ?? this.year,
      publisher: publisher ?? this.publisher,
      visibility: visibility ?? this.visibility,
      important: important ?? this.important,
      pinned: pinned ?? this.pinned,
      draft: draft ?? this.draft,
      scheduled: scheduled ?? this.scheduled,
      expired: expired ?? this.expired,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      createdByMe: createdByMe ?? this.createdByMe,
      bookmarked: bookmarked ?? this.bookmarked,
    );
  }

  bool get hasActiveFilters =>
      (search != null && search!.isNotEmpty) ||
      (category != null && category!.isNotEmpty) ||
      (status != null && status!.isNotEmpty) ||
      tags.isNotEmpty ||
      (department != null && department!.isNotEmpty) ||
      (campus != null && campus!.isNotEmpty) ||
      (programme != null && programme!.isNotEmpty) ||
      (year != null && year!.isNotEmpty) ||
      visibility != null ||
      important == true ||
      pinned == true ||
      draft == true ||
      scheduled == true ||
      expired == true ||
      createdAfter != null ||
      createdBefore != null ||
      createdByMe == true ||
      bookmarked == true;

  NoticeQueryFilters clearFilters() => NoticeQueryFilters(sort: sort, order: order, limit: limit);
}
