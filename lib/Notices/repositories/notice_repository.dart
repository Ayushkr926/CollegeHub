import 'dart:io';

import '../create_notice/model/notice_create_model.dart';
import '../services/notice_api_service.dart';

class NoticeRepository {
  final NoticeApiService apiService;

  NoticeRepository({NoticeApiService? apiService})
      : apiService = apiService ?? NoticeApiService();

  Future<Map<String, dynamic>> createNotice({
    required NoticeFormData form,
    List<File> coverFiles = const [],
    List<File> galleryFiles = const [],
    List<File> attachmentFiles = const [],
  }) {
    return apiService.createNotice(
      form: form,
      coverFiles: coverFiles,
      galleryFiles: galleryFiles,
      attachmentFiles: attachmentFiles,
    );
  }

  Future<Map<String, dynamic>> updateNotice({
    required String id,
    required NoticeFormData form,
    List<File> coverFiles = const [],
    List<File> galleryFiles = const [],
    List<File> attachmentFiles = const [],
  }) {
    return apiService.updateNotice(
      id: id,
      form: form,
      coverFiles: coverFiles,
      galleryFiles: galleryFiles,
      attachmentFiles: attachmentFiles,
    );
  }

  Future<Map<String, dynamic>> deleteNotice(String id) => apiService.deleteNotice(id);
  Future<Map<String, dynamic>> restoreNotice(String id) => apiService.restoreNotice(id);
  Future<Map<String, dynamic>> archiveNotice(String id) => apiService.archiveNotice(id);
  Future<Map<String, dynamic>> publishNotice(String id) => apiService.publishNotice(id);
  Future<Map<String, dynamic>> pinNotice(String id) => apiService.pinNotice(id);
  Future<Map<String, dynamic>> unpinNotice(String id) => apiService.unpinNotice(id);
  Future<Map<String, dynamic>> getNotice(String id) => apiService.getNotice(id);

  Future<List<Map<String, dynamic>>> fetchNotices({
    String? search,
    String? category,
    String? department,
    String? campus,
    String? programme,
    String? year,
    String? publisher,
    String? visibility,
    bool? important,
    bool? pinned,
    bool? draft,
    bool? scheduled,
    bool? expired,
    bool? bookmarked,
    String? sort,
    String? order,
    int page = 1,
    int limit = 15,
  }) => apiService.fetchNotices(
        search: search,
        category: category,
        department: department,
        campus: campus,
        programme: programme,
        year: year,
        publisher: publisher,
        visibility: visibility,
        important: important,
        pinned: pinned,
        draft: draft,
        scheduled: scheduled,
        expired: expired,
        bookmarked: bookmarked,
        sort: sort,
        order: order,
        page: page,
        limit: limit,
      );

  Future<List<Map<String, dynamic>>> getTrendingNotices() => apiService.getTrendingNotices();
  Future<List<Map<String, dynamic>>> getFeaturedNotices() => apiService.getFeaturedNotices();
  Future<List<String>> getSearchSuggestions({String? query}) => apiService.getSearchSuggestions(query: query);
  Future<List<Map<String, dynamic>>> getSimilarNotices(String id) => apiService.getSimilarNotices(id);
  Future<Map<String, dynamic>> bookmarkNotice(String id) => apiService.bookmarkNotice(id);
  Future<Map<String, dynamic>> removeBookmark(String id) => apiService.removeBookmark(id);
  Future<Map<String, dynamic>> likeNotice(String id) => apiService.likeNotice(id);
  Future<Map<String, dynamic>> unlikeNotice(String id) => apiService.unlikeNotice(id);
  Future<Map<String, dynamic>> markAsRead(String id) => apiService.markAsRead(id);
}
