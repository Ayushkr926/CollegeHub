import 'package:flutter/foundation.dart';

import '../../providers/notice_provider.dart';
import '../notice_models.dart';


enum FeedFilter {
  all,
  unread,
  important,
  placements,
  examinations,
  myDepartments,
  clubs,
  today,
  thisWeek,
}

class HomeFeedProvider extends ChangeNotifier {
  HomeFeedProvider({NoticeProvider? noticeProvider}) : _noticeProvider = noticeProvider ?? NoticeProvider();

  final NoticeProvider _noticeProvider;

  // ── State ──────────────────────────────────────────────
  List<Notice> _allNotices = [];
  List<Notice> _pinnedNotices = [];
  List<Notice> _feedNotices = [];

  FeedFilter _activeFilter = FeedFilter.all;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  bool _isOffline = false;
  String? _error;

  int _page = 1;
  static const int _pageSize = 15;

  // Mock followed departments (in real app → from user profile)
  final Set<String> _followedDepartments = {'CSE', 'Placement Cell', 'Exam Cell'};

  // ── Getters ────────────────────────────────────────────
  List<Notice> get pinnedNotices => _pinnedNotices;
  List<Notice> get feedNotices => _feedNotices;
  FeedFilter get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasMore => _hasMore;
  bool get isOffline => _isOffline;
  String? get error => _error;
  bool get isEmpty => !_isLoading && _feedNotices.isEmpty && _pinnedNotices.isEmpty;

  // ── Init / Load ────────────────────────────────────────
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _noticeProvider.loadNotices();
      _allNotices = _noticeProvider.notices.map((item) => Notice.fromJson(item)).toList();
      _applyRankingAndFilters();
      _isOffline = false;
    } catch (e) {
      _error = 'Failed to load notices';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _page = 1;
    _hasMore = true;
    notifyListeners();

    try {
      await _noticeProvider.loadNotices();
      _allNotices = _noticeProvider.notices.map((item) => Notice.fromJson(item)).toList();
      _applyRankingAndFilters();
      _error = null;
      _isOffline = false;
    } catch (e) {
      _error = 'Refresh failed';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> searchNotices(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _noticeProvider.loadNotices(search: query);
      _allNotices = _noticeProvider.notices.map((item) => Notice.fromJson(item)).toList();
      _applyRankingAndFilters();
    } catch (e) {
      _error = 'Search failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _page++;
    // In real app → append next page from API
    // For demo we just stop after page 3
    if (_page >= 3) _hasMore = false;

    _isLoading = false;
    notifyListeners();
  }

  // ── Filters ────────────────────────────────────────────
  void setFilter(FeedFilter filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    _page = 1;
    _hasMore = true;
    _applyRankingAndFilters();
    notifyListeners();
  }

  void clearFilter() {
    setFilter(FeedFilter.all);
  }

  // ── Actions ────────────────────────────────────────────
  void toggleBookmark(String noticeId) {
    final index = _allNotices.indexWhere((n) => n.id == noticeId);
    if (index == -1) return;

    final notice = _allNotices[index];
    _allNotices[index] = notice.copyWith(isBookmarked: !notice.isBookmarked);
    _applyRankingAndFilters();
    notifyListeners();
    _noticeProvider.toggleBookmark(noticeId);
  }

  void markAsRead(String noticeId) {
    final index = _allNotices.indexWhere((n) => n.id == noticeId);
    if (index == -1) return;

    if (!_allNotices[index].isRead) {
      _allNotices[index] = _allNotices[index].copyWith(isRead: true);
      _applyRankingAndFilters();
      notifyListeners();
    }
    _noticeProvider.markAsRead(noticeId);
  }

  void markAsUnread(String noticeId) {
    final index = _allNotices.indexWhere((n) => n.id == noticeId);
    if (index == -1) return;

    _allNotices[index] = _allNotices[index].copyWith(isRead: false);
    _applyRankingAndFilters();
    notifyListeners();
  }

  // ── Ranking & Filtering Logic (exact to your spec) ─────
  void _applyRankingAndFilters() {
    // 1. Separate pinned
    _pinnedNotices = _allNotices.where((n) => n.isPinned).toList();

    // 2. Base list (non-pinned)
    List<Notice> list = _allNotices.where((n) => !n.isPinned).toList();

    // 3. Apply filter
    list = _applyFilter(list);

    // 4. Ranking rules
    list.sort((a, b) {
      // Primary: Important + Unread > Important + Read > Normal + Unread > Normal + Read
      int score(Notice n) {
        if (n.isImportant && !n.isRead) return 4;
        if (n.isImportant && n.isRead) return 3;
        if (!n.isImportant && !n.isRead) return 2;
        return 1;
      }

      final scoreDiff = score(b).compareTo(score(a));
      if (scoreDiff != 0) return scoreDiff;

      // Mild boost for followed departments
      final aBoost = _followedDepartments.contains(a.publisher.name) ? 1 : 0;
      final bBoost = _followedDepartments.contains(b.publisher.name) ? 1 : 0;
      if (bBoost != aBoost) return bBoost.compareTo(aBoost);

      // Secondary: newest first
      return b.publishedAt.compareTo(a.publishedAt);
    });

    _feedNotices = list;
  }

  List<Notice> _applyFilter(List<Notice> list) {
    final now = DateTime.now();
    switch (_activeFilter) {
      case FeedFilter.unread:
        return list.where((n) => !n.isRead).toList();
      case FeedFilter.important:
        return list.where((n) => n.isImportant).toList();
      case FeedFilter.placements:
        return list.where((n) => n.publisher.name.toLowerCase().contains('placement')).toList();
      case FeedFilter.examinations:
        return list.where((n) => n.publisher.name.toLowerCase().contains('exam')).toList();
      case FeedFilter.myDepartments:
        return list.where((n) => _followedDepartments.contains(n.publisher.name)).toList();
      case FeedFilter.clubs:
        return list.where((n) => n.publisher.name.toLowerCase().contains('club')).toList();
      case FeedFilter.today:
        return list.where((n) =>
        n.publishedAt.year == now.year &&
            n.publishedAt.month == now.month &&
            n.publishedAt.day == now.day).toList();
      case FeedFilter.thisWeek:
        final weekAgo = now.subtract(const Duration(days: 7));
        return list.where((n) => n.publishedAt.isAfter(weekAgo)).toList();
      case FeedFilter.all:
      default:
        return list;
    }
  }

  // ── Mock Data ──────────────────────────────────────────
  List<Notice> _generateMockNotices() {
    final publishers = [
      const Publisher(id: '1', name: 'CSE', isVerified: true),
      const Publisher(id: '2', name: 'Placement Cell', isVerified: true),
      const Publisher(id: '3', name: 'Exam Cell', isVerified: true),
      const Publisher(id: '4', name: 'Cultural Club'),
      const Publisher(id: '5', name: 'Admin Office', isVerified: true),
    ];

    return List.generate(40, (i) {
      final pub = publishers[i % publishers.length];
      final hoursAgo = i * 3 + (i % 5);
      return Notice(
        id: 'notice_$i',
        title: _titles[i % _titles.length],
        body: _bodies[i % _bodies.length],
        publisher: pub,
        publishedAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
        importance: i % 4 == 0 ? NoticeImportance.important : NoticeImportance.normal,
        isPinned: i < 3,
        isRead: i % 3 != 0,
        isBookmarked: i % 7 == 0,
        attachmentCount: i % 5 == 0 ? (i % 3) + 1 : 0,
      );
    });
  }

  static const _titles = [
    'Mid-Semester Examination Schedule Released',
    'Google On-Campus Drive – Registration Open',
    'Workshop on Flutter & Firebase – Limited Seats',
    'Holiday Notice – Independence Day',
    'Library Timings Extended During Exams',
    'Sports Meet 2026 – Call for Volunteers',
    'Result Declaration of Even Semester',
    'Hackathon 2026 – Prize Pool ₹1 Lakh',
  ];

  static const _bodies = [
    'The mid-semester examinations will commence from 12th August. Detailed timetable is attached. Students are requested to check their seating arrangement.',
    'Google is visiting campus on 5th September. Eligible branches: CSE, IT, ECE. CGPA requirement ≥ 7.5. Register before 28th July.',
    'Hands-on workshop covering Flutter, Provider, Firebase Auth & Firestore. Certificate will be provided. Register via the link.',
    'The college will remain closed on 15th August on account of Independence Day. Regular classes resume on 16th August.',
    'Central library will remain open till 10 PM during the examination period. Students can use the reading halls.',
  ];
}