import 'dart:io';
import 'package:college/Api/api_constants.dart';
import 'package:college/storage/local_storage.dart';
import 'package:dio/dio.dart';
import '../models/notice_form_data.dart';

/// Thrown for any failed notice API call.
class NoticeApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic raw;

  NoticeApiException(this.message, {this.statusCode, this.raw});

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isNetworkError => statusCode == null;
}

typedef TokenProvider = String? Function();

/// Advanced Notice API client with:
/// - Full debug logging
/// - Automatic Bearer token on every request
/// - In-memory cache with TTL
class NoticeApiService {
  final Dio _dio;
  final TokenProvider? tokenProvider;

  static const String _basePath = '/notices';

  // ─────────────────────────────────────────────────────────────
  // CACHE
  // ─────────────────────────────────────────────────────────────
  final Map<String, _CacheEntry> _cache = {};

  /// Default TTL for list / detail responses
  static const Duration _defaultTtl = Duration(minutes: 3);

  /// Shorter TTL for trending / recent / featured (more dynamic)
  static const Duration _shortTtl = Duration(minutes: 1);

  NoticeApiService({
    Dio? dio,
    String baseUrl = 'http://192.168.1.3:5000/api/v1',
    this.tokenProvider,
  }) : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      )) {
    _log('INIT', 'baseUrl=$baseUrl');

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // ── Always attach Bearer token ──────────────────────
          final token = _resolveToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            _log('AUTH', 'Bearer token attached (len=${token.length})');
          } else {
            _log('AUTH', '⚠ No auth token available');
          }

          _log('REQ →', '${options.method} ${options.uri}');
          if (options.queryParameters.isNotEmpty) {
            _log('REQ', 'query = ${options.queryParameters}');
          }
          if (options.headers.isNotEmpty) {
            _log('REQ', 'headers = ${options.headers}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          _log('RES ←', '${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (e, handler) {
          _log('ERR ✕', '${e.type} ${e.requestOptions.method} ${e.requestOptions.uri}');
          _log('ERR', 'status=${e.response?.statusCode}  message=${e.message}');
          if (e.response?.data != null) {
            _log('ERR', 'body=${e.response?.data}');
          }
          handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;

  // ─────────────────────────────────────────────────────────────
  // TOKEN HELPER
  // ─────────────────────────────────────────────────────────────

  String? _resolveToken() {
    // Prefer explicit provider, fallback to LocalStorage
    final fromProvider = tokenProvider?.call();
    if (fromProvider != null && fromProvider.isNotEmpty) return fromProvider;

    return LocalStorageService.instance.getString(StorageKeys.authToken);
  }

  // ─────────────────────────────────────────────────────────────
  // CACHE HELPERS
  // ─────────────────────────────────────────────────────────────

  T? _getFromCache<T>(String key) {
    final entry = _cache[key];
    if (entry == null) {
      _log('CACHE', 'MISS → $key');
      return null;
    }
    if (entry.isExpired) {
      _log('CACHE', 'EXPIRED → $key');
      _cache.remove(key);
      return null;
    }
    _log('CACHE', 'HIT  → $key (age=${entry.age.inSeconds}s)');
    return entry.data as T?;
  }

  void _putInCache(String key, dynamic data, {Duration? ttl}) {
    _cache[key] = _CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl ?? _defaultTtl),
    );
    _log('CACHE', 'STORE → $key (ttl=${(ttl ?? _defaultTtl).inSeconds}s)');
  }

  void invalidateCache({String? prefix}) {
    if (prefix == null) {
      _log('CACHE', 'CLEAR ALL (${_cache.length} entries)');
      _cache.clear();
    } else {
      final keys = _cache.keys.where((k) => k.startsWith(prefix)).toList();
      for (final k in keys) {
        _cache.remove(k);
      }
      _log('CACHE', 'CLEAR prefix="$prefix" (${keys.length} entries)');
    }
  }

  void invalidateNotice(String id) {
    invalidateCache(prefix: 'detail:$id');
    invalidateCache(prefix: 'list:');
    invalidateCache(prefix: 'trending');
    invalidateCache(prefix: 'recent');
    invalidateCache(prefix: 'featured');
    invalidateCache(prefix: 'similar:$id');
  }

  // ─────────────────────────────────────────────────────────────
  // LOGGING
  // ─────────────────────────────────────────────────────────────

  void _log(String tag, String message) {
    // ignore: avoid_print
    print('[NoticeApi][$tag] $message');
  }

  // ─────────────────────────────────────────────────────────────
  // ERROR HELPER
  // ─────────────────────────────────────────────────────────────

  Never _throwFrom(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String message;

    _log('THROW', 'type=${e.type} status=$status');
    _log('THROW', 'response.data=$data');

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      message = 'The request timed out. Please check your connection and try again.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Could not connect to the server. Please check your internet connection.';
    } else if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    } else if (data is Map && data['error'] != null) {
      message = data['error'].toString();
    } else if (status == 401) {
      message = 'You need to sign in to do that.';
    } else if (status == 403) {
      message = 'You don\'t have permission to perform this action.';
    } else if (status == 404) {
      message = 'Notice not found.';
    } else if (status != null && status >= 500) {
      message = 'Something went wrong on our end. Please try again shortly.';
    } else {
      message = 'Something went wrong. Please try again.';
    }

    _log('THROW', '→ NoticeApiException: $message');
    throw NoticeApiException(message, statusCode: status, raw: data);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        _log('PARSE', 'unwrapped "data" key');
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    }
    _log('PARSE', 'data is not Map, got ${data.runtimeType}');
    return <String, dynamic>{};
  }

  // ─────────────────────────────────────────────────────────────
  // MULTIPART BUILDER
  // ─────────────────────────────────────────────────────────────

  Future<FormData> _buildMultipart(
      NoticeFormData form, {
        required bool includeAllFields,
      }) async {
    final map = <String, dynamic>{};
    final jsonFields = form.toJson();
    _log('MULTI', 'fields=${jsonFields.keys.toList()}');

    jsonFields.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          map['$key[$i]'] = value[i].toString();
        }
      } else {
        map[key] = value.toString();
      }
    });

    if (form.coverImageFile != null) {
      final path = form.coverImageFile!.path;
      _log('MULTI', 'coverImage → $path');
      map['coverImage'] = await MultipartFile.fromFile(
        path,
        filename: path.split(Platform.pathSeparator).last,
      );
    }

    if (form.imageFiles.isNotEmpty) {
      _log('MULTI', 'images → ${form.imageFiles.length}');
      map['images'] = await Future.wait(form.imageFiles.map(
            (f) => MultipartFile.fromFile(
          f.path,
          filename: f.path.split(Platform.pathSeparator).last,
        ),
      ));
    }

    if (form.attachmentFiles.isNotEmpty) {
      _log('MULTI', 'attachments → ${form.attachmentFiles.length}');
      map['attachments'] = await Future.wait(form.attachmentFiles.map(
            (f) => MultipartFile.fromFile(
          f.path,
          filename: f.path.split(Platform.pathSeparator).last,
        ),
      ));
    }

    _log('MULTI', 'FormData keys=${map.keys.toList()}');
    return FormData.fromMap(map);
  }

  // ─────────────────────────────────────────────────────────────
  // CREATE / UPDATE / DELETE / RESTORE / ARCHIVE / PUBLISH / PIN
  // ─────────────────────────────────────────────────────────────

  Future<NoticeModel> createNotice(NoticeFormData form) async {
    _log('CREATE', '========== CREATE NOTICE ==========');
    try {
      final formData = await _buildMultipart(form, includeAllFields: true);

      _log('CREATE', 'Form Fields:');
      for (final field in formData.fields) {
        _log('CREATE', '  ${field.key}: ${field.value}');
      }
      _log('CREATE', 'Form Files:');
      for (final file in formData.files) {
        _log('CREATE', '  ${file.key}: ${file.value.filename}');
      }

      final res = await _dio.post(
        '${ApiConstants.baseUrl}$_basePath',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      _log('CREATE', 'Status=${res.statusCode}');
      _log('CREATE', 'Body=${res.data}');

      // Invalidate list caches after create
      invalidateCache(prefix: 'list:');
      invalidateCache(prefix: 'trending');
      invalidateCache(prefix: 'recent');
      invalidateCache(prefix: 'featured');

      return NoticeModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<NoticeModel> updateNotice(String id, NoticeFormData form) async {
    _log('UPDATE', 'id=$id');
    try {
      final token = await LocalStorageService.instance.getString(StorageKeys.authToken);
      final formData = await _buildMultipart(form, includeAllFields: true);
      final res = await _dio.put(
        '${ApiConstants.baseUrl}$_basePath/$id',
        data: formData,
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },contentType: 'multipart/form-data'),
      );
      _log('UPDATE', 'OK status=${res.statusCode}');

      invalidateNotice(id);
      return NoticeModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<void> deleteNotice(String id) async {
    _log('DELETE', 'id=$id');
    try {
      await _dio.delete('${ApiConstants.baseUrl}$_basePath/$id');
      _log('DELETE', 'OK');
      invalidateNotice(id);
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<NoticeModel> restoreNotice(String id) async {
    _log('RESTORE', 'id=$id');
    try {
      final res = await _dio.patch('${ApiConstants.baseUrl}$_basePath/$id/restore');
      _log('RESTORE', 'OK status=${res.statusCode}');
      invalidateNotice(id);
      return NoticeModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<NoticeModel> archiveNotice(String id) async {
    _log('ARCHIVE', 'id=$id');
    try {
      final res = await _dio.patch('${ApiConstants.baseUrl}$_basePath/$id/archive');
      _log('ARCHIVE', 'OK status=${res.statusCode}');
      invalidateNotice(id);
      return NoticeModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<NoticeModel> publishNotice(String id) async {
    _log('PUBLISH', 'id=$id');
    try {
      final res = await _dio.patch('${ApiConstants.baseUrl}$_basePath/$id/publish');
      _log('PUBLISH', 'OK status=${res.statusCode}');
      invalidateNotice(id);
      return NoticeModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<NoticeModel> pinNotice(String id, {int? pinDurationHours}) async {
    _log('PIN', 'id=$id hours=$pinDurationHours');
    try {
      final res = await _dio.patch(
        '${ApiConstants.baseUrl}$_basePath/$id/pin',
        data: pinDurationHours != null ? {'pinDurationHours': pinDurationHours} : null,
      );
      _log('PIN', 'OK status=${res.statusCode}');
      invalidateNotice(id);
      return NoticeModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<NoticeModel> unpinNotice(String id) async {
    _log('UNPIN', 'id=$id');
    try {
      final res = await _dio.patch('${ApiConstants.baseUrl}$_basePath/$id/unpin');
      _log('UNPIN', 'OK status=${res.statusCode}');
      invalidateNotice(id);
      return NoticeModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // READS (with cache)
  // ─────────────────────────────────────────────────────────────

  Future<NoticeModel> getNoticeDetail(String id, {bool forceRefresh = false}) async {
    final cacheKey = 'detail:$id';

    if (!forceRefresh) {
      final cached = _getFromCache<NoticeModel>(cacheKey);
      if (cached != null) return cached;
    }

    _log('DETAIL', 'id=$id forceRefresh=$forceRefresh');
    try {
      final res = await _dio.get('${ApiConstants.baseUrl}$_basePath/$id');
      _log('DETAIL', 'OK status=${res.statusCode}');
      final model = NoticeModel.fromJson(_asMap(res.data));
      _putInCache(cacheKey, model);
      return model;
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<NoticeListResult> listNotices(
      NoticeQueryFilters filters, {
        bool forceRefresh = false,
      }) async {
    final cacheKey = 'list:${filters.toQueryParams()}';

    // if (forceRefresh) {
    //   final cached = _getFromCache<NoticeListResult>(cacheKey);
    //   if (cached != null) return cached;
    // }

    final query = filters.toQueryParams();
    _log('LIST', '========== LIST NOTICES ==========');
    _log('LIST', 'query=$query');

    try {
      final res = await _dio.get(
        '${ApiConstants.baseUrl}$_basePath',
        queryParameters: query,
      );

      _log('LIST', 'Status=${res.statusCode}');
      _log('LIST', 'Body type=${res.data.runtimeType}');

      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};

      final result = NoticeListResult.fromJson(data);
      _putInCache(cacheKey, result);
      return result;
    } on DioException catch (e) {
      _log('LIST', 'ERROR → ${e.message}');
      _throwFrom(e);
    }
  }

  Future<List<NoticeModel>> getTrendingNotices({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'trending:$limit';

    if (!forceRefresh) {
      final cached = _getFromCache<List<NoticeModel>>(cacheKey);
      if (cached != null) return cached;
    }

    _log('TRENDING', 'limit=$limit');
    try {
      final res = await _dio.get(
        '${ApiConstants.baseUrl}$_basePath/trending',
        queryParameters: {'limit': limit},
      );
      final list = _parseNoticeList(res.data);
      _log('TRENDING', 'OK count=${list.length}');
      _putInCache(cacheKey, list, ttl: _shortTtl);
      return list;
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<List<NoticeModel>> getRecentNotices({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'recent:$limit';

    if (!forceRefresh) {
      final cached = _getFromCache<List<NoticeModel>>(cacheKey);
      if (cached != null) return cached;
    }

    _log('RECENT', 'limit=$limit');
    try {
      final res = await _dio.get(
        '${ApiConstants.baseUrl}$_basePath/recent',
        queryParameters: {'limit': limit},
      );
      final list = _parseNoticeList(res.data);
      _log('RECENT', 'OK count=${list.length}');
      _putInCache(cacheKey, list, ttl: _shortTtl);
      return list;
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<List<NoticeModel>> getFeaturedNotices({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'featured:$limit';

    if (!forceRefresh) {
      final cached = _getFromCache<List<NoticeModel>>(cacheKey);
      if (cached != null) return cached;
    }

    _log('FEATURED', 'limit=$limit');
    try {
      final res = await _dio.get(
        '${ApiConstants.baseUrl}$_basePath/featured',
        queryParameters: {'limit': limit},
      );
      final list = _parseNoticeList(res.data);
      _log('FEATURED', 'OK count=${list.length}');
      _putInCache(cacheKey, list, ttl: _shortTtl);
      return list;
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _log('SUGGEST', 'empty query → []');
      return [];
    }

    final cacheKey = 'suggest:$trimmed';
    final cached = _getFromCache<List<String>>(cacheKey);
    if (cached != null) return cached;

    _log('SUGGEST', 'q="$trimmed"');
    try {
      final res = await _dio.get(
        '${ApiConstants.baseUrl}$_basePath/search/suggestions',
        queryParameters: {'q': trimmed},
      );

      final suggestions = <String>[];
      if (res.data is Map<String, dynamic>) {
        final response = res.data as Map<String, dynamic>;
        if (response['data'] is Map<String, dynamic>) {
          final data = response['data'] as Map<String, dynamic>;
          void addList(String key) {
            final value = data[key];
            if (value is List) {
              suggestions.addAll(value.map((e) => e.toString()));
            }
          }
          addList('titles');
          addList('categories');
          addList('tags');
          addList('publishers');
        }
      }

      final result = suggestions.toSet().toList()..sort();
      _log('SUGGEST', 'parsed ${result.length} items');
      _putInCache(cacheKey, result, ttl: const Duration(minutes: 5));
      return result;
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<List<NoticeModel>> getSimilarNotices(
      String id, {
        int limit = 6,
        bool forceRefresh = false,
      }) async {
    final cacheKey = 'similar:$id:$limit';

    if (!forceRefresh) {
      final cached = _getFromCache<List<NoticeModel>>(cacheKey);
      if (cached != null) return cached;
    }

    _log('SIMILAR', 'id=$id limit=$limit');
    try {
      final res = await _dio.get(
        '${ApiConstants.baseUrl}$_basePath/$id/similar',
        queryParameters: {'limit': limit},
      );
      final list = _parseNoticeList(res.data);
      _log('SIMILAR', 'OK count=${list.length}');
      _putInCache(cacheKey, list);
      return list;
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  List<NoticeModel> _parseNoticeList(dynamic data) {
    List raw;
    if (data is List) {
      raw = data;
    } else if (data is Map && data['items'] is List) {
      raw = data['items'] as List;
    } else if (data is Map && data['data'] is List) {
      raw = data['data'] as List;
    } else if (data is Map && data['notices'] is List) {
      raw = data['notices'] as List;
    } else {
      _log('PARSE', 'unexpected list shape → ${data.runtimeType}');
      raw = [];
    }

    final list = raw
        .whereType<Map>()
        .map((e) => NoticeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    _log('PARSE', '→ ${list.length} notices');
    return list;
  }

  // ─────────────────────────────────────────────────────────────
  // USER INTERACTIONS
  // ─────────────────────────────────────────────────────────────
  Future<Options> _authOptions() async {
    final token = await LocalStorageService.instance.getString(StorageKeys.authToken); // Change to your method

    print("[NoticeApi] Token: $token");

    return Options(
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
  }
  Future<void> bookmarkNotice(String id) async {
    _log('BOOKMARK', 'id=$id');
    try {
      await _dio.post('${ApiConstants.baseUrl}$_basePath/$id/bookmark',options: await _authOptions(),);
      _log('BOOKMARK', 'OK');
      invalidateCache(prefix: 'detail:$id');
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<void> removeBookmark(String id) async {
    _log('UNBOOKMARK', 'id=$id');
    try {
      await _dio.delete('${ApiConstants.baseUrl}$_basePath/$id/bookmark',options: await _authOptions(),);
      _log('UNBOOKMARK', 'OK');
      invalidateCache(prefix: 'detail:$id');
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<void> likeNotice(String id) async {
    _log('LIKE', 'id=$id');
    try {
      await _dio.post('${ApiConstants.baseUrl}$_basePath/$id/like',options: await _authOptions(),);
      _log('LIKE', 'OK');
      invalidateCache(prefix: 'detail:$id');
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<void> unlikeNotice(String id) async {
    _log('UNLIKE', 'id=$id');
    try {
      await _dio.delete('${ApiConstants.baseUrl}$_basePath/$id/like',options: await _authOptions(),);
      _log('UNLIKE', 'OK');
      invalidateCache(prefix: 'detail:$id');
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<void> markAsRead(String id) async {
    _log('READ', 'id=$id');
    try {
      await _dio.post('${ApiConstants.baseUrl}$_basePath/$id/read',options: await _authOptions(),);
      _log('READ', 'OK');
      invalidateCache(prefix: 'detail:$id');
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// CACHE ENTRY
// ─────────────────────────────────────────────────────────────

class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get age => DateTime.now().difference(expiresAt.subtract(
    const Duration(minutes: 3), // approximate
  ));
}