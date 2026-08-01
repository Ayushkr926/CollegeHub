import 'dart:convert';
import 'dart:io';

import 'package:college/Api/api_clients.dart';
import 'package:college/storage/local_storage.dart';
import 'package:dio/dio.dart';

import '../create_notice/model/notice_create_model.dart';

class NoticeApiService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> createNotice({
    required NoticeFormData form,
    List<File> coverFiles = const [],
    List<File> galleryFiles = const [],
    List<File> attachmentFiles = const [],
  }) async {
    final data = await _buildFormData(
      form,
      coverFiles: coverFiles,
      galleryFiles: galleryFiles,
      attachmentFiles: attachmentFiles,
    );
    final response = await _dio.post(
      '/notices',
      data: data,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> updateNotice({
    required String id,
    required NoticeFormData form,
    List<File> coverFiles = const [],
    List<File> galleryFiles = const [],
    List<File> attachmentFiles = const [],
  }) async {
    final data = await _buildFormData(
      form,
      coverFiles: coverFiles,
      galleryFiles: galleryFiles,
      attachmentFiles: attachmentFiles,
    );
    final response = await _dio.put(
      '/notices/$id',
      data: data,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> deleteNotice(String id) async {
    final response = await _dio.delete('/notices/$id');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> restoreNotice(String id) async {
    final response = await _dio.patch('/notices/$id/restore');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> archiveNotice(String id) async {
    final response = await _dio.patch('/notices/$id/archive');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> publishNotice(String id) async {
    final response = await _dio.patch('/notices/$id/publish');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> pinNotice(String id) async {
    final response = await _dio.patch('/notices/$id/pin');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> unpinNotice(String id) async {
    final response = await _dio.patch('/notices/$id/unpin');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> getNotice(String id) async {
    final response = await _dio.get('/notices/$id');
    return _readResponse(response);
  }

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
  }) async {
    final response = await _dio.get(
      '/notices',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (department != null && department.isNotEmpty) 'department': department,
        if (campus != null && campus.isNotEmpty) 'campus': campus,
        if (programme != null && programme.isNotEmpty) 'programme': programme,
        if (year != null && year.isNotEmpty) 'year': year,
        if (publisher != null && publisher.isNotEmpty) 'publisher': publisher,
        if (visibility != null && visibility.isNotEmpty) 'visibility': visibility,
        if (important != null) 'important': important.toString(),
        if (pinned != null) 'pinned': pinned.toString(),
        if (draft != null) 'draft': draft.toString(),
        if (scheduled != null) 'scheduled': scheduled.toString(),
        if (expired != null) 'expired': expired.toString(),
        if (bookmarked != null) 'bookmarked': bookmarked.toString(),
        if (sort != null && sort.isNotEmpty) 'sort': sort,
        if (order != null && order.isNotEmpty) 'order': order,
        'page': page,
        'limit': limit,
      },
    );
    final data = _readResponse(response);
    final payload = data['data'];
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final list = payload['notices'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getTrendingNotices() async {
    final response = await _dio.get('/notices/trending');
    final data = _readResponse(response);
    final payload = data['data'];
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final list = payload['notices'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getFeaturedNotices() async {
    final response = await _dio.get('/notices/featured');
    final data = _readResponse(response);
    final payload = data['data'];
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final list = payload['notices'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Future<List<String>> getSearchSuggestions({String? query}) async {
    final response = await _dio.get(
      '/notices/search/suggestions',
      queryParameters: query != null && query.isNotEmpty ? {'search': query} : null,
    );
    final data = _readResponse(response);
    final payload = data['data'];
    if (payload is List) {
      return payload.map((item) => item.toString()).toList();
    }
    if (payload is Map<String, dynamic>) {
      final suggestions = payload['suggestions'];
      if (suggestions is List) {
        return suggestions.map((item) => item.toString()).toList();
      }
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getSimilarNotices(String id) async {
    final response = await _dio.get('/notices/$id/similar');
    final data = _readResponse(response);
    final payload = data['data'];
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final list = payload['notices'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Future<Map<String, dynamic>> bookmarkNotice(String id) async {
    final response = await _dio.post('/notices/$id/bookmark');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> removeBookmark(String id) async {
    final response = await _dio.delete('/notices/$id/bookmark');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> likeNotice(String id) async {
    final response = await _dio.post('/notices/$id/like');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> unlikeNotice(String id) async {
    final response = await _dio.delete('/notices/$id/like');
    return _readResponse(response);
  }

  Future<Map<String, dynamic>> markAsRead(String id) async {
    final response = await _dio.post('/notices/$id/read');
    return _readResponse(response);
  }

  Future<FormData> _buildFormData(
    NoticeFormData form, {
    List<File> coverFiles = const [],
    List<File> galleryFiles = const [],
    List<File> attachmentFiles = const [],
  }) async {
    _ensureToken();
    final payload = form.toBackendPayload();
    final data = FormData();

    payload.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        data.fields.add(MapEntry(key, jsonEncode(value)));
      } else if (value is bool) {
        data.fields.add(MapEntry(key, value ? 'true' : 'false'));
      } else {
        data.fields.add(MapEntry(key, value.toString()));
      }
    });

    for (final file in coverFiles) {
      data.files.add(
        MapEntry(
          'coverImage',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    for (final file in galleryFiles) {
      data.files.add(
        MapEntry(
          'galleryImages',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    for (final file in attachmentFiles) {
      data.files.add(
        MapEntry(
          'attachments',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    return data;
  }

  Map<String, dynamic> _readResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {'data': data};
  }

  void _ensureToken() {
    final token = LocalStorageService.instance.getString(StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      ApiClient.setToken(token);
    }
  }
}
