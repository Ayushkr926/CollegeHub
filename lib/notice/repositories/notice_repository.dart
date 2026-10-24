import '../models/notice_form_data.dart';
import '../services/notice_api_service.dart';

/// Sits between [NoticeApiService] and [NoticeProvider].
///
/// This layer exists so that provider/UI code never talks to Dio directly.
/// It's also the natural place to add local caching, offline fallbacks, or
/// analytics later without touching the API service or the UI.
class NoticeRepository {
  final NoticeApiService apiService;

  NoticeRepository({required this.apiService});

  // ---- Create / Update / Delete / Restore -------------------------------

  Future<NoticeModel> createNotice(NoticeFormData form) {
    return apiService.createNotice(form);
  }

  Future<NoticeModel> updateNotice(String id, NoticeFormData form) {
    return apiService.updateNotice(id, form);
  }

  Future<void> deleteNotice(String id) {
    return apiService.deleteNotice(id);
  }

  Future<NoticeModel> restoreNotice(String id) {
    return apiService.restoreNotice(id);
  }

  Future<NoticeModel> archiveNotice(String id) {
    return apiService.archiveNotice(id);
  }

  Future<NoticeModel> publishNotice(String id) {
    return apiService.publishNotice(id);
  }

  Future<NoticeModel> pinNotice(String id, {int? pinDurationHours}) {
    return apiService.pinNotice(id, pinDurationHours: pinDurationHours);
  }

  Future<NoticeModel> unpinNotice(String id) {
    return apiService.unpinNotice(id);
  }

  // ---- Reads --------------------------------------------------------------

  Future<NoticeModel> getNoticeDetail(String id) {
    return apiService.getNoticeDetail(id);
  }

  Future<NoticeListResult> listNotices(NoticeQueryFilters filters,bool force) {
    return apiService.listNotices(filters,forceRefresh: force);
  }

  Future<List<NoticeModel>> getTrendingNotices({int limit = 10}) {
    return apiService.getTrendingNotices(limit: limit);
  }

  Future<List<NoticeModel>> getRecentNotices({int limit = 10}) {
    return apiService.getRecentNotices(limit: limit);
  }

  Future<List<NoticeModel>> getFeaturedNotices({int limit = 10}) {
    return apiService.getFeaturedNotices(limit: limit);
  }

  Future<Map<String, List<String>>> getSearchSuggestions(String query) {
    return apiService.getSearchSuggestions(query);
  }

  Future<List<NoticeModel>> getSimilarNotices(String id, {int limit = 6}) {
    return apiService.getSimilarNotices(id, limit: limit);
  }

  // ---- Interactions ---------------------------------------------------

  Future<void> bookmarkNotice(String id) => apiService.bookmarkNotice(id);

  Future<void> removeBookmark(String id) => apiService.removeBookmark(id);

  Future<void> likeNotice(String id) => apiService.likeNotice(id);

  Future<void> unlikeNotice(String id) => apiService.unlikeNotice(id);

  Future<void> markAsRead(String id) => apiService.markAsRead(id);

  /// Convenience combinator: toggles like state based on current model.
  /// Callers should optimistically update UI, then call this, and roll back
  /// on failure (see NoticeProvider.toggleLike for the pattern).
  Future<void> toggleLike(String id, {required bool currentlyLiked}) {
    return currentlyLiked ? unlikeNotice(id) : likeNotice(id);
  }

  /// Convenience combinator: toggles bookmark state based on current model.
  Future<void> toggleBookmark(String id, {required bool currentlyBookmarked}) {
    return currentlyBookmarked ? removeBookmark(id) : bookmarkNotice(id);
  }
}
