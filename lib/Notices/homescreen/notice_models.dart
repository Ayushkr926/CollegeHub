import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

enum NoticeImportance { normal, important }

enum NoticeBadge {
  important,
  pinned,
  unread,
  hasAttachment,
}

class Publisher {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isVerified;

  const Publisher({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isVerified = false,
  });

  Publisher copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isVerified,
  }) {
    return Publisher(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class Notice {
  final String id;
  final String title;
  final String body;

  /// Optional HTML/Markdown content
  final String? bodyHtml;

  final Publisher publisher;

  final DateTime publishedAt;

  /// Optional expiry date
  final DateTime? expiresAt;

  final NoticeImportance importance;

  final bool isPinned;
  final bool isRead;
  final bool isBookmarked;
  final bool isLiked;
  final bool isExpired;
  final bool isNew;

  final int attachmentCount;
  final int viewCount;

  final List<String> targetDepartments;
  final List<Attachment> attachments;

  const Notice({
    required this.id,
    required this.title,
    required this.body,
    this.bodyHtml,
    required this.publisher,
    required this.publishedAt,
    this.expiresAt,
    this.importance = NoticeImportance.normal,
    this.isPinned = false,
    this.isRead = false,
    this.isBookmarked = false,
    this.isLiked = false,
    this.isExpired = false,
    this.isNew = true,
    this.attachmentCount = 0,
    this.viewCount = 0,
    this.targetDepartments = const [],
    this.attachments = const [],
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    final payload = json['notice'] ?? json;
    final publisherData = payload['publisher'] ?? payload['publisherName'];
    final publisherName = publisherData is String
        ? publisherData
        : (payload['publisherName'] ?? 'College');
    return Notice(
      id: payload['id']?.toString() ?? payload['_id']?.toString() ?? '',
      title: payload['title']?.toString() ?? '',
      body: payload['body']?.toString() ?? payload['summary']?.toString() ?? '',
      publisher: Publisher(
        id: payload['publisherId']?.toString() ?? 'publisher',
        name: publisherName.toString(),
      ),
      publishedAt: payload['createdAt'] != null
          ? DateTime.tryParse(payload['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: payload['expiresAt'] != null
          ? DateTime.tryParse(payload['expiresAt'].toString())
          : null,
        targetDepartments: AppConstants.normalizeBranches(
        payload['targetDepartments'] is List
          ? payload['targetDepartments'] as List
          : const <dynamic>[],
        ),
      importance: payload['isImportant'] == true ? NoticeImportance.important : NoticeImportance.normal,
      isPinned: payload['isPinned'] == true,
      isRead: payload['isRead'] == true,
      isBookmarked: payload['isBookmarked'] == true,
      isLiked: payload['isLiked'] == true,
      attachmentCount: payload['attachments'] is List ? (payload['attachments'] as List).length : 0,
    );
  }

  Notice copyWith({
    String? id,
    String? title,
    String? body,
    String? bodyHtml,
    Publisher? publisher,
    DateTime? publishedAt,
    DateTime? expiresAt,
    NoticeImportance? importance,
    bool? isPinned,
    bool? isRead,
    bool? isBookmarked,
    bool? isLiked,
    bool? isExpired,
    bool? isNew,
    int? attachmentCount,
    int? viewCount,
    List<String>? targetDepartments,
    List<Attachment>? attachments,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      bodyHtml: bodyHtml ?? this.bodyHtml,
      publisher: publisher ?? this.publisher,
      publishedAt: publishedAt ?? this.publishedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      importance: importance ?? this.importance,
      isPinned: isPinned ?? this.isPinned,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLiked: isLiked ?? this.isLiked,
      isExpired: isExpired ?? this.isExpired,
      isNew: isNew ?? this.isNew,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      viewCount: viewCount ?? this.viewCount,
      targetDepartments: AppConstants.normalizeBranches(
        targetDepartments ?? this.targetDepartments,
      ),
      attachments: attachments ?? this.attachments,
    );
  }

  bool get isImportant =>
      importance == NoticeImportance.important;

  bool get hasAttachment =>
      attachmentCount > 0 || attachments.isNotEmpty;

  List<NoticeBadge> get badges {
    final badges = <NoticeBadge>[];

    if (isPinned) badges.add(NoticeBadge.pinned);
    if (isImportant) badges.add(NoticeBadge.important);
    if (!isRead) badges.add(NoticeBadge.unread);
    if (hasAttachment) badges.add(NoticeBadge.hasAttachment);

    return badges;
  }
}

class Attachment {
  final String id;
  final String name;
  final String url;
  final String mimeType;
  final int sizeInBytes;
  final String? thumbnailUrl;

  const Attachment({
    required this.id,
    required this.name,
    required this.url,
    required this.mimeType,
    required this.sizeInBytes,
    this.thumbnailUrl,
  });

  String get readableSize {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    }
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  IconData get icon {
    final type = mimeType.toLowerCase();

    if (type.contains('pdf')) {
      return Icons.picture_as_pdf_rounded;
    }

    if (type.contains('image')) {
      return Icons.image_rounded;
    }

    if (type.contains('word') ||
        type.contains('document') ||
        type.contains('doc')) {
      return Icons.description_rounded;
    }

    if (type.contains('excel') ||
        type.contains('sheet') ||
        type.contains('spreadsheet') ||
        type.contains('csv')) {
      return Icons.table_chart_rounded;
    }

    if (type.contains('video')) {
      return Icons.videocam_rounded;
    }

    if (type.contains('audio')) {
      return Icons.audiotrack_rounded;
    }

    if (type.contains('zip') ||
        type.contains('rar') ||
        type.contains('archive')) {
      return Icons.folder_zip_rounded;
    }

    return Icons.insert_drive_file_rounded;
  }
}