import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notice_form_data.dart';
import '../repositories/notice_repository.dart';
import '../services/notice_api_service.dart';

enum LoadStatus { idle, loading, loadingMore, success, empty, error }

/// Central state holder for the notice feature. Wraps [NoticeRepository]
/// and exposes ChangeNotifier state for: the paginated list, filters,
/// trending/recent/featured sections, search suggestions, notice detail,
/// the create/edit form, and per-notice interaction state (like/bookmark/read).
///
/// Register with:
///   ChangeNotifierProvider(create: (_) => NoticeProvider(repository: repo))
class NoticeProvider extends ChangeNotifier {
  final NoticeRepository repository;

  NoticeProvider({required this.repository});

  // ------------------------------------------------------------------
  // LIST STATE
  // ------------------------------------------------------------------

  LoadStatus listStatus = LoadStatus.idle;
  String? listError;
  List<NoticeModel> notices = [];
  NoticeQueryFilters filters = NoticeQueryFilters();
  int _currentPage = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;
  bool get isListLoading => listStatus == LoadStatus.loading;
  bool get isListLoadingMore => listStatus == LoadStatus.loadingMore;

  /// Fetch the first page of notices with current filters. Resets the list.
  Future<void> loadNotices({bool silent = false,required bool force}) async {
    if (!silent) {
      listStatus = LoadStatus.loading;
      listError = null;
      notifyListeners();
    }
    _currentPage = 1;
    try {
      final result = await repository.listNotices(filters.copyWith(page: 1),force);
      notices = result.items;
      _hasMore = result.hasMore || (result.items.isNotEmpty && result.total != null && result.items.length < (result.total ?? 0));
      listStatus = notices.isEmpty ? LoadStatus.empty : LoadStatus.success;
      listError = null;
    } on NoticeApiException catch (e) {
      listStatus = LoadStatus.error;
      listError = e.message;
    } catch (e) {
      listStatus = LoadStatus.error;
      listError = 'Something went wrong while loading notices.';
    }
    notifyListeners();
  }

  /// Fetch the next page and append. Call from a scroll-end listener.
  Future<void> loadMoreNotices() async {
    if (listStatus == LoadStatus.loadingMore || !_hasMore) return;
    listStatus = LoadStatus.loadingMore;
    notifyListeners();
    try {
      final nextPage = _currentPage + 1;
      final result = await repository.listNotices(filters.copyWith(page: nextPage),true);
      notices = [...notices, ...result.items];
      _currentPage = nextPage;
      _hasMore = result.hasMore || result.items.isNotEmpty;
      if (result.items.isEmpty) _hasMore = false;
      listStatus = LoadStatus.success;
    } on NoticeApiException catch (e) {
      listStatus = LoadStatus.success; // keep existing items visible
      listError = e.message;
    } catch (e) {
      listStatus = LoadStatus.success;
      listError = 'Could not load more notices.';
    }
    notifyListeners();
  }

  /// Pull-to-refresh: reloads page 1 without flashing the full loading state.
  Future<void> refreshNotices() => loadNotices(silent: false,force: true);

  /// Apply new filters (category/tags/search/etc.) and reload from page 1.
  Future<void> applyFilters(NoticeQueryFilters newFilters) async {
    filters = newFilters;
    await loadNotices(force: true);
  }

  Future<void> updateSearchQuery(String query) async {
    filters = filters.copyWith(search: query);
    await loadNotices(force: true);
  }

  Future<void> clearFilters() async {
    filters = filters.clearFilters();
    await loadNotices(force: true);
  }

  /// Removes a notice from the in-memory list (e.g. after delete) without
  /// a full refetch.
  void removeFromListLocally(String id) {
    notices = notices.where((n) => n.id != id).toList();
    if (notices.isEmpty) listStatus = LoadStatus.empty;
    notifyListeners();
  }

  /// Replaces a notice in the in-memory list with an updated copy
  /// (e.g. after publish/archive/pin) without a full refetch.
  void updateInListLocally(NoticeModel updated) {
    notices = notices.map((n) => n.id == updated.id ? updated : n).toList();
    if (currentDetail?.id == updated.id) currentDetail = updated;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // SECTIONS: trending / recent / featured
  // ------------------------------------------------------------------

  LoadStatus trendingStatus = LoadStatus.idle;
  List<NoticeModel> trendingNotices = [];

  LoadStatus recentStatus = LoadStatus.idle;
  List<NoticeModel> recentNotices = [];

  LoadStatus featuredStatus = LoadStatus.idle;
  List<NoticeModel> featuredNotices = [];

  String? sectionsError;

  /// Loads trending, recent, and featured sections in parallel.
  /// Call this from the list screen's initState / on pull-to-refresh.
  Future<void> loadHomeSections() async {
    trendingStatus = LoadStatus.loading;
    recentStatus = LoadStatus.loading;
    featuredStatus = LoadStatus.loading;
    sectionsError = null;
    notifyListeners();

    final results = await Future.wait([
      _safeSectionLoad(() => repository.getTrendingNotices(), (list) {
        trendingNotices = list;
        trendingStatus = list.isEmpty ? LoadStatus.empty : LoadStatus.success;
      }),
      _safeSectionLoad(() => repository.getRecentNotices(), (list) {
        recentNotices = list;
        recentStatus = list.isEmpty ? LoadStatus.empty : LoadStatus.success;
      }),
      _safeSectionLoad(() => repository.getFeaturedNotices(), (list) {
        featuredNotices = list;
        featuredStatus = list.isEmpty ? LoadStatus.empty : LoadStatus.success;
      }),
    ]);

    final firstError = results.firstWhere((e) => e != null, orElse: () => null);
    if (firstError != null) sectionsError = firstError;

    notifyListeners();
  }

  Future<String?> _safeSectionLoad(
    Future<List<NoticeModel>> Function() loader,
    void Function(List<NoticeModel>) onSuccess,
  ) async {
    try {
      final list = await loader();
      onSuccess(list);
      return null;
    } on NoticeApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Could not load notices.';
    }
  }

  // ------------------------------------------------------------------
  // SEARCH SUGGESTIONS
  // ------------------------------------------------------------------

  List<String> searchSuggestions = [];
  bool isFetchingSuggestions = false;
  Timer? _suggestionDebounce;

  /// Debounced autocomplete fetch — safe to call on every keystroke.
  void fetchSuggestionsDebounced(String query, {Duration delay = const Duration(milliseconds: 300)}) {
    _suggestionDebounce?.cancel();
    if (query.trim().isEmpty) {
      searchSuggestions = [];
      notifyListeners();
      return;
    }
    _suggestionDebounce = Timer(delay, () => fetchSuggestions(query));
  }

  Future<void> fetchSuggestions(String query) async {
    isFetchingSuggestions = true;
    notifyListeners();
    try {
      searchSuggestions = await repository.getSearchSuggestions(query);
    } catch (_) {
      searchSuggestions = [];
    }
    isFetchingSuggestions = false;
    notifyListeners();
  }

  void clearSuggestions() {
    searchSuggestions = [];
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // DETAIL
  // ------------------------------------------------------------------

  LoadStatus detailStatus = LoadStatus.idle;
  String? detailError;
  NoticeModel? currentDetail;

  LoadStatus similarStatus = LoadStatus.idle;
  List<NoticeModel> similarNotices = [];

  Future<void> loadNoticeDetail(String id) async {
    detailStatus = LoadStatus.loading;
    detailError = null;
    currentDetail = null;
    notifyListeners();
    try {
      currentDetail = await repository.getNoticeDetail(id);
      detailStatus = LoadStatus.success;
      // Fire-and-forget: mark read + load similar, don't block detail render
      unawaited(_markReadSilently(id));
      unawaited(loadSimilarNotices(id));
    } on NoticeApiException catch (e) {
      detailStatus = LoadStatus.error;
      detailError = e.message;
    } catch (e) {
      detailStatus = LoadStatus.error;
      detailError = 'Could not load this notice.';
    }
    notifyListeners();
  }

  Future<void> _markReadSilently(String id) async {
    try {
      await repository.markAsRead(id);
      if (currentDetail?.id == id && !(currentDetail!.isReadByMe)) {
        currentDetail = currentDetail!.copyWith(isReadByMe: true);
        updateInListLocally(currentDetail!);
      }
    } catch (_) {
      // Non-critical — don't surface an error for a background read receipt.
    }
  }

  Future<void> loadSimilarNotices(String id) async {
    similarStatus = LoadStatus.loading;
    notifyListeners();
    try {
      similarNotices = await repository.getSimilarNotices(id);
      similarStatus = similarNotices.isEmpty ? LoadStatus.empty : LoadStatus.success;
    } catch (_) {
      similarStatus = LoadStatus.error;
      similarNotices = [];
    }
    notifyListeners();
  }

  void clearDetail() {
    currentDetail = null;
    detailStatus = LoadStatus.idle;
    similarNotices = [];
    similarStatus = LoadStatus.idle;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // CREATE / EDIT FORM
  // ------------------------------------------------------------------

  bool isSubmitting = false;
  String? submitError;
  Map<String, String> formErrors = {};

  /// Validates then submits the form. Returns the created/updated notice on
  /// success, or null on failure (with [submitError]/[formErrors] populated).
  Future<NoticeModel?> submitNotice(NoticeFormData form, {String? existingId}) async {
    formErrors = form.validate();
    if (formErrors.isNotEmpty) {
      notifyListeners();
      return null;
    }

    isSubmitting = true;
    submitError = null;
    notifyListeners();

    try {
      final NoticeModel result;
      if (existingId != null) {
        result = await repository.updateNotice(existingId, form);
        updateInListLocally(result);
      } else {
        result = await repository.createNotice(form);
        // Newest notice goes to the top of an already-loaded list.
        if (listStatus == LoadStatus.success || listStatus == LoadStatus.empty) {
          notices = [result, ...notices];
          listStatus = LoadStatus.success;
        }
      }
      currentDetail = result;
      isSubmitting = false;
      notifyListeners();
      return result;
    } on NoticeApiException catch (e) {
      submitError = e.message;
      isSubmitting = false;
      notifyListeners();
      return null;
    } catch (e) {
      submitError = 'Could not save this notice. Please try again.';
      isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  void clearFormErrors() {
    formErrors = {};
    submitError = null;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // ADMIN / FACULTY ACTIONS: delete, restore, archive, publish, pin, unpin
  // ------------------------------------------------------------------

  final Set<String> _mutatingIds = {};

  bool isMutating(String id) => _mutatingIds.contains(id);

  Future<bool> deleteNotice(String id) async {
    _mutatingIds.add(id);
    notifyListeners();
    try {
      await repository.deleteNotice(id);
      removeFromListLocally(id);
      if (currentDetail?.id == id) {
        currentDetail = currentDetail!.copyWith(isDeleted: true);
      }
      return true;
    } on NoticeApiException catch (e) {
      detailError = e.message;
      return false;
    } catch (e) {
      detailError = 'Could not delete this notice.';
      return false;
    } finally {
      _mutatingIds.remove(id);
      notifyListeners();
    }
  }

  Future<bool> restoreNotice(String id) => _runMutation(id, () async {
        final updated = await repository.restoreNotice(id);
        updateInListLocally(updated);
      });

  Future<bool> archiveNotice(String id) => _runMutation(id, () async {
        final updated = await repository.archiveNotice(id);
        updateInListLocally(updated);
      });

  Future<bool> publishNotice(String id) => _runMutation(id, () async {
        final updated = await repository.publishNotice(id);
        updateInListLocally(updated);
      });

  Future<bool> pinNotice(String id, {int? pinDurationHours}) => _runMutation(id, () async {
        final updated = await repository.pinNotice(id, pinDurationHours: pinDurationHours);
        updateInListLocally(updated);
      });

  Future<bool> unpinNotice(String id) => _runMutation(id, () async {
        final updated = await repository.unpinNotice(id);
        updateInListLocally(updated);
      });

  Future<bool> _runMutation(String id, Future<void> Function() action) async {
    _mutatingIds.add(id);
    notifyListeners();
    try {
      await action();
      return true;
    } on NoticeApiException catch (e) {
      detailError = e.message;
      return false;
    } catch (e) {
      detailError = 'Action could not be completed. Please try again.';
      return false;
    } finally {
      _mutatingIds.remove(id);
      notifyListeners();
    }
  }

  // ------------------------------------------------------------------
  // USER INTERACTIONS: like, bookmark (optimistic updates + rollback)
  // ------------------------------------------------------------------

  /// Optimistically toggles like state, then confirms with the server.
  /// Rolls back on failure so the UI never shows a stale "liked" state.
  Future<void> toggleLike(NoticeModel notice) async {
    final wasLiked = notice.isLikedByMe;
    final optimistic = notice.copyWith(
      isLikedByMe: !wasLiked,
      likeCount: wasLiked ? (notice.likeCount - 1).clamp(0, 1 << 31) : notice.likeCount + 1,
    );
    _applyToBoth(optimistic);

    try {
      await repository.toggleLike(notice.id, currentlyLiked: wasLiked);
    } catch (_) {
      // Roll back
      _applyToBoth(notice);
    }
  }

  /// Optimistically toggles bookmark state, then confirms with the server.
  Future<void> toggleBookmark(NoticeModel notice) async {
    final wasBookmarked = notice.isBookmarkedByMe;
    final optimistic = notice.copyWith(
      isBookmarkedByMe: !wasBookmarked,
      bookmarkCount: wasBookmarked ? (notice.bookmarkCount - 1).clamp(0, 1 << 31) : notice.bookmarkCount + 1,
    );
    _applyToBoth(optimistic);

    try {
      await repository.toggleBookmark(notice.id, currentlyBookmarked: wasBookmarked);
    } catch (_) {
      _applyToBoth(notice);
    }
  }

  void _applyToBoth(NoticeModel model) {
    notices = notices.map((n) => n.id == model.id ? model : n).toList();
    trendingNotices = trendingNotices.map((n) => n.id == model.id ? model : n).toList();
    recentNotices = recentNotices.map((n) => n.id == model.id ? model : n).toList();
    featuredNotices = featuredNotices.map((n) => n.id == model.id ? model : n).toList();
    similarNotices = similarNotices.map((n) => n.id == model.id ? model : n).toList();
    if (currentDetail?.id == model.id) currentDetail = model;
    notifyListeners();
  }

  @override
  void dispose() {
    _suggestionDebounce?.cancel();
    super.dispose();
  }
}
