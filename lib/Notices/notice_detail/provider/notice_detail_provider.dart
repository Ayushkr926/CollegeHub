import 'package:flutter/foundation.dart';

import '../../providers/notice_provider.dart';
import '../../homescreen/notice_models.dart';



enum NoticeDetailState { loading, success, error, notFound, permissionDenied, offline }

class NoticeDetailProvider extends ChangeNotifier {
  NoticeDetailProvider({NoticeProvider? noticeProvider}) : _noticeProvider = noticeProvider ?? NoticeProvider();

  final NoticeProvider _noticeProvider;

  NoticeDetailState _state = NoticeDetailState.loading;
  Notice? _notice;
  List<Notice> _relatedNotices = [];
  String? _errorMessage;
  bool _isOffline = false;

  // Download progress: attachmentId → progress (0.0 – 1.0)
  final Map<String, double> _downloadProgress = {};

  NoticeDetailState get state => _state;
  Notice? get notice => _notice;
  List<Notice> get relatedNotices => _relatedNotices;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  Map<String, double> get downloadProgress => _downloadProgress;

  Future<void> load(String noticeId, {Notice? cached}) async {
    // Optimistic: show cached data immediately if available
    if (cached != null) {
      _notice = cached;
      _state = NoticeDetailState.success;
      notifyListeners();
    } else {
      _state = NoticeDetailState.loading;
      notifyListeners();
    }

    try {
      await _noticeProvider.loadNotice(noticeId);
      final payload = _noticeProvider.activeNotice;
      if (payload != null) {
        _notice = Notice.fromJson(payload);
      } else {
        _notice = _mockNotice(noticeId);
      }
      _relatedNotices = _mockRelated();

      // Auto mark as read after short delay (business rule)
      Future.delayed(const Duration(seconds: 2), () {
        if (_notice != null && !_notice!.isRead) {
          markAsRead();
        }
      });

      _state = NoticeDetailState.success;
      _isOffline = false;
    } catch (e) {
      if (cached != null) {
        _isOffline = true;
        _state = NoticeDetailState.success;
      } else {
        _state = NoticeDetailState.error;
        _errorMessage = 'Failed to load notice';
      }
    }
    notifyListeners();
  }

  void markAsRead() {
    if (_notice == null || _notice!.isRead) return;
    _notice = _notice!.copyWith(isRead: true);
    notifyListeners();
    _noticeProvider.markAsRead(_notice!.id);
  }

  void markAsUnread() {
    if (_notice == null) return;
    _notice = _notice!.copyWith(isRead: false);
    notifyListeners();
  }

  void toggleBookmark() {
    if (_notice == null) return;
    _notice = _notice!.copyWith(isBookmarked: !_notice!.isBookmarked);
    notifyListeners();
    _noticeProvider.toggleBookmark(_notice!.id);
  }

  void toggleLike() {
    if (_notice == null) return;
    _notice = _notice!.copyWith(isLiked: !_notice!.isLiked);
    notifyListeners();
    _noticeProvider.toggleLike(_notice!.id);
  }

  Future<void> togglePin() async {
    if (_notice == null) return;
    final success = await _noticeProvider.togglePin(_notice!.id);
    if (success) {
      _notice = _notice!.copyWith(isPinned: !_notice!.isPinned);
      notifyListeners();
    }
  }

  Future<void> publishNotice() async {
    if (_notice == null) return;
    await _noticeProvider.publishNotice(_notice!.id);
  }

  Future<void> downloadAttachment(Attachment attachment) async {
    if (_downloadProgress.containsKey(attachment.id)) return;

    _downloadProgress[attachment.id] = 0.0;
    notifyListeners();

    // Simulate download progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      _downloadProgress[attachment.id] = i / 10;
      notifyListeners();
    }

    _downloadProgress.remove(attachment.id);
    notifyListeners();
    // TODO: actual download + open file
  }

  Future<void> refresh() async {
    if (_notice == null) return;
    await load(_notice!.id, cached: _notice);
  }

  // ── Mock data ──────────────────────────────────────────
  Notice _mockNotice(String id) {
    return Notice(
      id: id,
      title: 'Google On-Campus Drive – Registration Open till 28 July',
      body: '''Dear Students,

We are pleased to announce that **Google** will be conducting an on-campus recruitment drive for the 2026 batch.

### Eligibility
- Branches: CSE, IT, ECE
- CGPA ≥ 7.5
- No active backlogs

### Important Dates
- Registration Deadline: **28 July 2026**
- Online Test: 5 August 2026
- Interviews: 12–14 August 2026

Please register through the placement portal and upload your latest resume.

All the best!
Placement Cell''',
      publisher: const Publisher(
        id: '2',
        name: 'Placement Cell',
        isVerified: true,
      ),
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      importance: NoticeImportance.important,
      isPinned: true,
      isRead: false,
      isBookmarked: false,
      attachmentCount: 2,
      expiresAt: DateTime(2026, 7, 28),
      viewCount: 1247,
      attachments: const [
        Attachment(
          id: 'a1',
          name: 'Google_Drive_Guidelines.pdf',
          url: 'https://example.com/file1.pdf',
          mimeType: 'application/pdf',
          sizeInBytes: 1240000,
        ),
        Attachment(
          id: 'a2',
          name: 'Resume_Template.docx',
          url: 'https://example.com/file2.docx',
          mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          sizeInBytes: 85000,
        ),
      ],
    );
  }

  List<Notice> _mockRelated() {
    return List.generate(4, (i) {
      return Notice(
        id: 'rel_$i',
        title: 'Related Notice ${i + 1} from Placement Cell',
        body: 'Short preview of related notice...',
        publisher: const Publisher(id: '2', name: 'Placement Cell', isVerified: true),
        publishedAt: DateTime.now().subtract(Duration(days: i + 1)),
      );
    });
  }
}