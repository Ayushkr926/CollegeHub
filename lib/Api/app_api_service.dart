import 'dart:convert';
import 'dart:io';

import 'package:college/storage/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'api_clients.dart';
import 'api_constants.dart';

class AppApiService {
  AppApiService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<Map<String, dynamic>> _readResponse(Response response) async {
    if (response.data == null) {
      return {'success': true};
    }

    if (response.data is Map) {
      final payload = Map<String, dynamic>.from(response.data as Map);
      if (payload.containsKey('data')) {
        final data = payload['data'];
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        return {'data': data};
      }
      return payload;
    }

    return {'data': response.data};
  }

  Future<Options> _authOptions({Map<String, dynamic>? extraHeaders}) async {
    final token = LocalStorageService.instance.getString(StorageKeys.authToken);
    return Options(
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        ...?extraHeaders,
      },
    );
  }

  Future<FormData> _multipartFromFields(
    Map<String, dynamic> fields, {
    File? coverImage,
    List<File> images = const [],
    List<File> attachments = const [],
  }) async {
    final formData = FormData();

    fields.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        for (final item in value) {
          if (item is File) {
            continue;
          }
          formData.fields.add(MapEntry(key, jsonEncode(item)));
        }
      } else if (value is bool) {
        formData.fields.add(MapEntry(key, value ? 'true' : 'false'));
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    if (coverImage != null) {
      formData.files.add(
        MapEntry('coverImage', await MultipartFile.fromFile(
          coverImage.path,
          filename: coverImage.path.split(Platform.pathSeparator).last,
        )),
      );
    }

    for (final file in images) {
      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        )),
      );
    }

    for (final file in attachments) {
      formData.files.add(
        MapEntry('attachments', await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        )),
      );
    }

    return formData;
  }

  Future<Response> _get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: await _authOptions(),
    );
  }

  Future<Response> _post(
    String path, {
    Map<String, dynamic>? data,
    FormData? formData,
    bool requireAuth = true,
  }) async {
    return _dio.post(
      path,
      data: formData ?? data,
      options: requireAuth ? await _authOptions() : await _authOptions(extraHeaders: {'Accept': 'application/json'}),
    );
  }

  Future<Response> _put(
    String path, {
    Map<String, dynamic>? data,
    FormData? formData,
    bool requireAuth = true,
  }) async {
    return _dio.put(
      path,
      data: formData ?? data,
      options: requireAuth ? await _authOptions() : await _authOptions(extraHeaders: {'Accept': 'application/json'}),
    );
  }

  Future<Response> _patch(
    String path, {
    Map<String, dynamic>? data,
    FormData? formData,
    bool requireAuth = true,
  }) async {
    return _dio.patch(
      path,
      data: formData ?? data,
      options: requireAuth ? await _authOptions() : await _authOptions(extraHeaders: {'Accept': 'application/json'}),
    );
  }

  Future<Response> _delete(String path, {Map<String, dynamic>? data, bool requireAuth = true}) async {
    return _dio.delete(
      path,
      data: data,
      options: requireAuth ? await _authOptions() : await _authOptions(extraHeaders: {'Accept': 'application/json'}),
    );
  }

  // Authentication & profiles
  Future<Map<String, dynamic>> registerStudent(Map<String, dynamic> body) async {
    final res = await _post(ApiConstants.authStudentRegister, data: body, requireAuth: false);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> registerOrganiser(Map<String, dynamic> body) async {
    final res = await _post(ApiConstants.authOrganiserRegister, data: body, requireAuth: false);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final res = await _post(ApiConstants.authLogin, data: body, requireAuth: false);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> listOrganisers({
    String? search,
    String? category,
    bool? isVerified,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    final res = await _get(
      ApiConstants.authOrganisers,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (isVerified != null) 'isVerified': isVerified,
        'page': page,
        'limit': limit,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
        if (sortOrder != null && sortOrder.isNotEmpty) 'sortOrder': sortOrder,
      },
    );
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getAuthProfile() async {
    final res = await _get(ApiConstants.authProfile);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> updateAuthProfile(Map<String, dynamic> body, {File? profilePicture}) async {
    if (profilePicture != null) {
      final formData = FormData.fromMap({
        ...body,
        'profilePicture': await MultipartFile.fromFile(
          profilePicture.path,
          filename: profilePicture.path.split(Platform.pathSeparator).last,
        ),
      });
      final res = await _dio.put(
        ApiConstants.authProfile,
        data: formData,
        options: await _authOptions(),
      );
      return _readResponse(res);
    }

    final res = await _put(ApiConstants.authProfile, data: body);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getStudentProfile() async {
    final res = await _get(ApiConstants.authStudentProfile);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> updateStudentProfile(Map<String, dynamic> body, {File? profilePicture}) async {
    return updateAuthProfile(body, profilePicture: profilePicture);
  }

  Future<Map<String, dynamic>> getOrganiserProfile() async {
    final res = await _get(ApiConstants.authOrganiserProfile);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> updateOrganiserProfile(Map<String, dynamic> body, {File? profilePicture}) async {
    return updateAuthProfile(body, profilePicture: profilePicture);
  }

  // Clubs
  Future<Map<String, dynamic>> listClubs() async {
    final res = await _get(ApiConstants.clubs);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> createClub({required String name, required String description}) async {
    final res = await _post(ApiConstants.clubs, data: {'name': name, 'description': description});
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getClub(String id) async {
    final res = await _get('${ApiConstants.clubs}/$id');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> joinClub(String id) async {
    final res = await _post('${ApiConstants.clubs}/$id/join-request');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> listClubJoinRequests({String? status}) async {
    final res = await _get(
      '${ApiConstants.clubs}/join-requests',
      queryParameters: {if (status != null && status.isNotEmpty) 'status': status},
    );
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> reviewClubJoinRequest(
    String requestId, {
    required String status,
  }) async {
    final res = await _dio.patch(
      '${ApiConstants.clubs}/join-requests/$requestId',
      data: {'status': status},
      options: await _authOptions(),
    );
    return _readResponse(res);
  }

  // Events
  Future<Map<String, dynamic>> listEvents({
    String? search,
    String? status,
    String? category,
    String? mode,
    String? organizingClubRef,
    String? eventType,
    String? eligibilityType,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _get(
      ApiConstants.events,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (category != null && category.isNotEmpty) 'category': category,
        if (mode != null && mode.isNotEmpty) 'mode': mode,
        if (organizingClubRef != null && organizingClubRef.isNotEmpty) 'organizingClubRef': organizingClubRef,
        if (eventType != null && eventType.isNotEmpty) 'eventType': eventType,
        if (eligibilityType != null && eligibilityType.isNotEmpty) 'eligibilityType': eligibilityType,
        'page': page,
        'limit': limit,
      },
    );
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> body) async {
    final res = await _post(ApiConstants.events, data: body);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getEvent(String id) async {
    final res = await _get('${ApiConstants.events}/$id');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> attendEvent(String id, {String? userId}) async {
    final res = await _post(
      '${ApiConstants.events}/$id/attend',
      data: userId == null ? null : {'userId': userId},
    );
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> registerForEvent(
      String id, {
        String? teamName,
        List<String>? members,
      }) async {
    final stopwatch = Stopwatch()..start();

    debugPrint('');
    debugPrint('╔════════════════════════════════════════════════════════════');
    debugPrint('║ [RegisterEvent] 🚀 START');
    debugPrint('╠════════════════════════════════════════════════════════════');

    try {
      // ============================================================
      // 1. INPUT DEBUG
      // ============================================================

      debugPrint('[RegisterEvent] 📥 INPUT');
      debugPrint('[RegisterEvent] Event ID: "$id"');
      debugPrint('[RegisterEvent] Event ID length: ${id.length}');
      debugPrint('[RegisterEvent] Event ID empty: ${id.isEmpty}');
      debugPrint('[RegisterEvent] Team Name: "$teamName"');
      debugPrint('[RegisterEvent] Team Name provided: ${teamName != null}');
      debugPrint('[RegisterEvent] Members: $members');
      debugPrint('[RegisterEvent] Members provided: ${members != null}');
      debugPrint('[RegisterEvent] Members count: ${members?.length ?? 0}');

      // ============================================================
      // 2. EVENT ID VALIDATION
      // ============================================================

      if (id.trim().isEmpty) {
        debugPrint('[RegisterEvent] ❌ Event ID is empty');
        throw ArgumentError('Event ID cannot be empty');
      }

      debugPrint('[RegisterEvent] ✅ Event ID validation passed');

      // ============================================================
      // 3. BUILD URL
      // ============================================================

      final url = '${ApiConstants.events}/$id/register';

      debugPrint('[RegisterEvent] 🌐 URL INFORMATION');
      debugPrint('[RegisterEvent] Base URL: ${ApiConstants.events}');
      debugPrint('[RegisterEvent] Event ID: $id');
      debugPrint('[RegisterEvent] Final URL: $url');

      // ============================================================
      // 4. BUILD REQUEST BODY
      // ============================================================

      final requestData = {
        if (teamName != null && teamName.isNotEmpty)
          'teamName': teamName,

        if (members != null && members.isNotEmpty)
          'members': members,
      };

      debugPrint('[RegisterEvent] 📦 REQUEST BODY');
      debugPrint('[RegisterEvent] Request Data: $requestData');
      debugPrint('[RegisterEvent] Request Data Type: ${requestData.runtimeType}');
      debugPrint(
        '[RegisterEvent] Request Keys: ${requestData.keys.toList()}',
      );

      if (requestData.containsKey('teamName')) {
        debugPrint(
          '[RegisterEvent] teamName value: ${requestData['teamName']}',
        );
      }

      if (requestData.containsKey('members')) {
        debugPrint(
          '[RegisterEvent] members value: ${requestData['members']}',
        );
      }

      // ============================================================
      // 5. TOKEN CHECK
      // ============================================================

      debugPrint('[RegisterEvent] 🔐 AUTHENTICATION CHECK');

      final token = LocalStorageService.instance.getString(
        StorageKeys.authToken,
      );

      debugPrint('[RegisterEvent] Token exists: ${token != null}');
      debugPrint('[RegisterEvent] Token empty: ${token?.isEmpty ?? true}');
      debugPrint('[RegisterEvent] Token length: ${token?.length ?? 0}');

      if (token == null || token.isEmpty) {
        debugPrint('[RegisterEvent] ❌ Authentication token missing');

        throw StateError(
          'Login is required before registering for an event.',
        );
      }

      debugPrint('[RegisterEvent] ✅ Authentication token available');

      // Don't print the actual token for security.
      debugPrint(
        '[RegisterEvent] Token preview: '
            '${token.substring(0, token.length > 10 ? 10 : token.length)}...',
      );

      // ============================================================
      // 6. REQUEST INFORMATION
      // ============================================================

      debugPrint('[RegisterEvent] 📤 REQUEST CONFIGURATION');
      debugPrint('[RegisterEvent] HTTP Method: POST');
      debugPrint('[RegisterEvent] URL: $url');
      debugPrint('[RegisterEvent] requireAuth: true');
      debugPrint('[RegisterEvent] Authorization: Bearer token attached');
      debugPrint('[RegisterEvent] Content-Type: application/json');

      // ============================================================
      // 7. SEND REQUEST
      // ============================================================

      debugPrint('');
      debugPrint('[RegisterEvent] 🚀 SENDING API REQUEST...');
      debugPrint('[RegisterEvent] Stopwatch: ${stopwatch.elapsedMilliseconds}ms');

      final res = await _post(
        url,
        data: requestData,
        requireAuth: true,
      );

      // ============================================================
      // 8. RAW RESPONSE
      // ============================================================

      debugPrint('');
      debugPrint('[RegisterEvent] ✅ API REQUEST COMPLETED');
      debugPrint(
        '[RegisterEvent] Response time: '
            '${stopwatch.elapsedMilliseconds}ms',
      );

      debugPrint('[RegisterEvent] 📥 RESPONSE INFORMATION');
      debugPrint('[RegisterEvent] Status Code: ${res.statusCode}');
      debugPrint('[RegisterEvent] Status Message: ${res.statusMessage}');
      debugPrint('[RegisterEvent] Response Type: ${res.data.runtimeType}');
      debugPrint('[RegisterEvent] Response Data: ${res.data}');
      debugPrint('[RegisterEvent] Response Headers: ${res.headers}');

      // ============================================================
      // 9. RESPONSE DATA ANALYSIS
      // ============================================================

      if (res.data is Map) {
        final responseData = Map<String, dynamic>.from(res.data);

        debugPrint('[RegisterEvent] 🔍 RESPONSE ANALYSIS');
        debugPrint(
          '[RegisterEvent] success: ${responseData['success']}',
        );
        debugPrint(
          '[RegisterEvent] message: ${responseData['message']}',
        );
        debugPrint(
          '[RegisterEvent] data exists: ${responseData.containsKey('data')}',
        );
        debugPrint(
          '[RegisterEvent] data: ${responseData['data']}',
        );

        if (responseData.containsKey('error')) {
          debugPrint(
            '[RegisterEvent] ⚠️ error: ${responseData['error']}',
          );
        }
      } else {
        debugPrint(
          '[RegisterEvent] ⚠️ Response is not a Map',
        );
      }

      // ============================================================
      // 10. PARSE RESPONSE
      // ============================================================

      debugPrint('[RegisterEvent] 🔄 Parsing response...');

      final result = _readResponse(res);

      debugPrint('[RegisterEvent] ✅ Response parsed successfully');
      debugPrint('[RegisterEvent] Parsed result: $result');
      debugPrint('[RegisterEvent] Parsed result type: ${result.runtimeType}');

      // ============================================================
      // 11. SUCCESS
      // ============================================================

      stopwatch.stop();

      debugPrint('');
      debugPrint('[RegisterEvent] 🎉 REGISTRATION SUCCESSFUL');
      debugPrint(
        '[RegisterEvent] Total execution time: '
            '${stopwatch.elapsedMilliseconds}ms',
      );

      return result;
    } on DioException catch (error, stackTrace) {
      stopwatch.stop();

      // ============================================================
      // DIO ERROR
      // ============================================================

      debugPrint('');
      debugPrint('╔════════════════════════════════════════════════════════════');
      debugPrint('║ [RegisterEvent] ❌ DIO EXCEPTION');
      debugPrint('╠════════════════════════════════════════════════════════════');

      debugPrint('[RegisterEvent] Dio Type: ${error.type}');
      debugPrint('[RegisterEvent] Message: ${error.message}');
      debugPrint('[RegisterEvent] Error: $error');

      // Request
      debugPrint('');
      debugPrint('[RegisterEvent] 📤 FAILED REQUEST');
      debugPrint(
        '[RegisterEvent] Method: ${error.requestOptions.method}',
      );
      debugPrint(
        '[RegisterEvent] URL: ${error.requestOptions.uri}',
      );
      debugPrint(
        '[RegisterEvent] Headers: ${error.requestOptions.headers}',
      );
      debugPrint(
        '[RegisterEvent] Request Data: ${error.requestOptions.data}',
      );

      // Response
      debugPrint('');
      debugPrint('[RegisterEvent] 📥 SERVER RESPONSE');

      debugPrint(
        '[RegisterEvent] Status Code: '
            '${error.response?.statusCode}',
      );

      debugPrint(
        '[RegisterEvent] Status Message: '
            '${error.response?.statusMessage}',
      );

      debugPrint(
        '[RegisterEvent] Response Data: '
            '${error.response?.data}',
      );

      debugPrint(
        '[RegisterEvent] Response Headers: '
            '${error.response?.headers}',
      );

      // Try to extract backend message
      final responseData = error.response?.data;

      if (responseData is Map) {
        debugPrint('');
        debugPrint('[RegisterEvent] 🔍 SERVER ERROR DETAILS');

        debugPrint(
          '[RegisterEvent] success: ${responseData['success']}',
        );

        debugPrint(
          '[RegisterEvent] message: ${responseData['message']}',
        );

        debugPrint(
          '[RegisterEvent] error: ${responseData['error']}',
        );

        debugPrint(
          '[RegisterEvent] data: ${responseData['data']}',
        );
      }

      debugPrint('');
      debugPrint(
        '[RegisterEvent] ⏱️ Failed after: '
            '${stopwatch.elapsedMilliseconds}ms',
      );

      debugPrint('');
      debugPrint('[RegisterEvent] STACK TRACE');
      debugPrint('$stackTrace');

      debugPrint(
        '╚════════════════════════════════════════════════════════════',
      );

      rethrow;
    } on StateError catch (error, stackTrace) {
      stopwatch.stop();

      debugPrint('');
      debugPrint('[RegisterEvent] ❌ STATE ERROR');
      debugPrint('[RegisterEvent] Error: $error');
      debugPrint('[RegisterEvent] StackTrace: $stackTrace');

      rethrow;
    } on ArgumentError catch (error, stackTrace) {
      stopwatch.stop();

      debugPrint('');
      debugPrint('[RegisterEvent] ❌ ARGUMENT ERROR');
      debugPrint('[RegisterEvent] Error: $error');
      debugPrint('[RegisterEvent] StackTrace: $stackTrace');

      rethrow;
    } catch (error, stackTrace) {
      stopwatch.stop();

      // ============================================================
      // UNKNOWN ERROR
      // ============================================================

      debugPrint('');
      debugPrint('╔════════════════════════════════════════════════════════════');
      debugPrint('║ [RegisterEvent] ❌ UNKNOWN EXCEPTION');
      debugPrint('╠════════════════════════════════════════════════════════════');

      debugPrint('[RegisterEvent] Error Type: ${error.runtimeType}');
      debugPrint('[RegisterEvent] Error: $error');

      debugPrint('');
      debugPrint('[RegisterEvent] StackTrace:');
      debugPrint('$stackTrace');

      debugPrint(
        '[RegisterEvent] Failed after: '
            '${stopwatch.elapsedMilliseconds}ms',
      );

      debugPrint(
        '╚════════════════════════════════════════════════════════════',
      );

      rethrow;
    } finally {
      if (stopwatch.isRunning) {
        stopwatch.stop();
      }

      debugPrint('');
      debugPrint('[RegisterEvent] 🏁 registerForEvent() FINISHED');
      debugPrint(
        '[RegisterEvent] Total time: '
            '${stopwatch.elapsedMilliseconds}ms',
      );
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('');
    }
  }

  Future<Map<String, dynamic>> getMyEventRegistrations() async {
    final res = await _get(ApiConstants.myEventRegistrations);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> updateEventStatus(
    String id, {
    required String status,
  }) async {
    final res = await _dio.patch(
      '${ApiConstants.events}/$id/status',
      data: {'status': status},
      options: await _authOptions(),
    );
    return _readResponse(res);
  }

  // Notices
  Future<Map<String, dynamic>> createNotice(
    Map<String, dynamic> body, {
    File? coverImage,
    List<File> images = const [],
    List<File> attachments = const [],
  }) async {
    final formData = await _multipartFromFields(
      body,
      coverImage: coverImage,
      images: images,
      attachments: attachments,
    );
    final res = await _dio.post(
      ApiConstants.notices,
      data: formData,
      options: await _authOptions(),
    );
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> updateNotice(
    String id,
    Map<String, dynamic> body, {
    File? coverImage,
    List<File> images = const [],
    List<File> attachments = const [],
  }) async {
    final formData = await _multipartFromFields(
      body,
      coverImage: coverImage,
      images: images,
      attachments: attachments,
    );
    final res = await _dio.put(
      '${ApiConstants.notices}/$id',
      data: formData,
      options: await _authOptions(),
    );
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> deleteNotice(String id) async {
    final res = await _delete('${ApiConstants.notices}/$id');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> restoreNotice(String id) async {
    final res = await _patch('${ApiConstants.notices}/$id/restore');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> archiveNotice(String id) async {
    final res = await _patch('${ApiConstants.notices}/$id/archive');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> publishNotice(String id) async {
    final res = await _patch('${ApiConstants.notices}/$id/publish');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> pinNotice(String id, {int? pinDurationHours}) async {
    final res = await _patch(
      '${ApiConstants.notices}/$id/pin',
      data: pinDurationHours == null ? null : {'pinDurationHours': pinDurationHours},
    );
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> unpinNotice(String id) async {
    final res = await _patch('${ApiConstants.notices}/$id/unpin');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getNotice(String id) async {
    final res = await _get('${ApiConstants.notices}/$id');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> listNotices({
    String? search,
    String? category,
    String? status,
    List<String> tags = const [],
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
    bool? createdByMe,
    bool? bookmarked,
    String? sort,
    String? order,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _get(
      ApiConstants.notices,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (status != null && status.isNotEmpty) 'status': status,
        if (tags.isNotEmpty) 'tags': tags.join(','),
        if (department != null && department.isNotEmpty) 'department': department,
        if (campus != null && campus.isNotEmpty) 'campus': campus,
        if (programme != null && programme.isNotEmpty) 'programme': programme,
        if (year != null && year.isNotEmpty) 'year': year,
        if (publisher != null && publisher.isNotEmpty) 'publisher': publisher,
        if (visibility != null && visibility.isNotEmpty) 'visibility': visibility,
        if (important != null) 'important': important,
        if (pinned != null) 'pinned': pinned,
        if (draft != null) 'draft': draft,
        if (scheduled != null) 'scheduled': scheduled,
        if (expired != null) 'expired': expired,
        if (createdByMe != null) 'createdByMe': createdByMe,
        if (bookmarked != null) 'bookmarked': bookmarked,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
        if (order != null && order.isNotEmpty) 'order': order,
        'page': page,
        'limit': limit,
      },
    );
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getTrendingNotices({int limit = 8}) async {
    final res = await _get('${ApiConstants.notices}/trending', queryParameters: {'limit': limit});
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getRecentNotices({int limit = 8}) async {
    final res = await _get('${ApiConstants.notices}/recent', queryParameters: {'limit': limit});
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getFeaturedNotices({int limit = 8}) async {
    final res = await _get('${ApiConstants.notices}/featured', queryParameters: {'limit': limit});
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getSearchSuggestions({String? search}) async {
    final res = await _get(
      '${ApiConstants.notices}/search/suggestions',
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getSimilarNotices(String id, {int limit = 6}) async {
    final res = await _get('${ApiConstants.notices}/$id/similar', queryParameters: {'limit': limit});
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> bookmarkNotice(String id) async {
    final res = await _post('${ApiConstants.notices}/$id/bookmark');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> removeBookmark(String id) async {
    final res = await _delete('${ApiConstants.notices}/$id/bookmark');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> likeNotice(String id) async {
    final res = await _post('${ApiConstants.notices}/$id/like');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> unlikeNotice(String id) async {
    final res = await _delete('${ApiConstants.notices}/$id/like');
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> markNoticeRead(String id) async {
    final res = await _post('${ApiConstants.notices}/$id/read');
    return _readResponse(res);
  }

  // Analytics
  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    final res = await _get(ApiConstants.analyticsDashboard);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getCategoryAnalytics() async {
    final res = await _get(ApiConstants.analyticsCategory);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getPublisherAnalytics() async {
    final res = await _get(ApiConstants.analyticsPublisher);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getMonthlyAnalytics() async {
    final res = await _get(ApiConstants.analyticsMonthly);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getViewsAnalytics() async {
    final res = await _get(ApiConstants.analyticsViews);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getReadRateAnalytics() async {
    final res = await _get(ApiConstants.analyticsReadRate);
    return _readResponse(res);
  }

  Future<Map<String, dynamic>> getEngagementAnalytics() async {
    final res = await _get(ApiConstants.analyticsEngagement);
    return _readResponse(res);
  }
}
