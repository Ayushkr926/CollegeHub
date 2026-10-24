// lib/providers/profile_provider.dart
//
// -----------------------------------------------------------------------
// ALIGNED WITH Student model
// -----------------------------------------------------------------------
// • All organiser fields (clubName, category, clubDescription,
//   facultyName, facultyEmail) are now first-class citizens.
// • createdClubs is tracked.
// • saveProfile() / submitProfileEdits() always construct a complete
//   Student instance — nothing is dropped on the floor.
// • roleBadge prefers clubName when the user is an organiser.
// -----------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:college/Api/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../Model/participation_entry.dart';
import '../Model/user_role.dart'; // or wherever Role lives if it's in a separate file
import '../storage/local_storage.dart';
import '../utils/app_constants.dart';

// If Role + Student live in the same file, import that instead:
// import '../Model/student.dart';

class ProfileProvider extends ChangeNotifier {
  // -----------------------------------------------------------------
  // Configure this to point at your real backend.
  // -----------------------------------------------------------------
  static const String _baseUrl = 'https://YOUR_API_HOST/api';
  static const Duration _requestTimeout = Duration(seconds: 15);

  // ---- Profile data (mirrors Student) ----
  String _id = '';
  String _fullName = '';
  String _email = '';
  String _phoneNumber = '';
  String _username = '';
  String _bio = '';
  String _website = '';
  String _avatarUrl = '';
  String _avatarAsset = 'assets/images/Memo.jpg';

  // Academic
  String _rollNumber = '';
  String _branch = '';
  String _course = '';
  String _yearOfStudy = ''; // display string e.g. "3rd Year"

  // Role
  String _role = ''; // Role.toJson() value

  // Organiser-specific
  String _clubName = '';
  String _category = '';
  String _clubDescription = '';
  String _facultyName = '';
  String _facultyEmail = '';
  int _events = 0;
  int _member = 0;
  int _followers = 0;

  // Lists
  List<String> _joinedClubs = [];
  List<String> _createdClubs = [];
  int _version = 0;

  // Participation (kept for UI convenience)
  List<ParticipationEntry> _participationData = [];

  bool _isFollowing = false;

  // ---- Loading / sync state ----
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _fetchInFlight = false;
  String? _error;
  DateTime? _lastSyncedAt;

  // ---- Edit / save state ----
  bool _isSaving = false;
  String? _saveError;

  // ---- Getters ----
  String get id => _id;
  String get fullName => _fullName;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get username => _username;
  String get bio => _bio;
  String get website => _website;
  String get avatarUrl => _avatarUrl;
  String get avatarAsset => _avatarAsset;
  String get rollNumber => _rollNumber;
  String get branch => _branch;
  String get course => _course;
  String get yearOfStudy => _yearOfStudy;
  String get role => _role;

  // Organiser
  String get clubName => _clubName;
  String get category => _category;
  String get clubDescription => _clubDescription;
  String get facultyName => _facultyName;
  String get facultyEmail => _facultyEmail;
  int get events => _events;
  int get members => _member;
  int get followers => _followers;

  List<String> get joinedClubs => List.unmodifiable(_joinedClubs);
  List<String> get createdClubs => List.unmodifiable(_createdClubs);
  int get version => _version;
  List<ParticipationEntry> get participationData =>
      List.unmodifiable(_participationData);
  bool get isFollowing => _isFollowing;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  bool get hasProfile => _fullName.isNotEmpty;

  bool get isSaving => _isSaving;
  String? get saveError => _saveError;

  /// Badge shown under the name.
  /// Prefer clubName for organisers, otherwise the Role title.
  String get roleBadge =>
      _clubName.isNotEmpty ? _clubName : Role.fromString(_role).title;

  /// Plain numeric year (e.g. 3) for dropdowns / pickers.
  int get yearNumber => AppConstants.normalizeYear(_yearOfStudy) ?? 0;

  // -----------------------------------------------------------------------
  // LOAD PROFILE — cache first, then silently refresh from the API
  // -----------------------------------------------------------------------
  Future<void> loadProfile({bool isorganiser = false}) async {
    _error = null;

    final cached = _readCache();
    if (cached != null) {
      _applyStudent(cached);
      notifyListeners();
      unawaited(_syncFromApi(showFullScreenLoading: false, isorganiser: isorganiser));
      return;
    }

    await _syncFromApi(showFullScreenLoading: true, isorganiser: isorganiser);
  }

  Future<void> refreshProfile({bool isoragiser = false}) async {
    await _syncFromApi(showFullScreenLoading: false, isPullToRefresh: true, isorganiser: isoragiser);
  }

  // -----------------------------------------------------------------------
  // Internal helpers
  // -----------------------------------------------------------------------
  Student? _readCache() {
    try {
      return LocalStorageService.instance.getModel<Student>(
        StorageKeys.userProfile,
            (json) => Student.fromJson(json),
      );
    } catch (e) {
      debugPrint('ProfileProvider: cache read failed: $e');
      return null;
    }
  }

  Future<void> _syncFromApi({
    required bool showFullScreenLoading,
    bool isPullToRefresh = false,
    bool isorganiser = false
  }) async {
    if (_fetchInFlight) {
      debugPrint("⚠️ Fetch already in progress");
      return;
    }

    _fetchInFlight = true;

    if (showFullScreenLoading) _isLoading = true;
    if (isPullToRefresh) _isRefreshing = true;

    _error = null;
    notifyListeners();

    try {
      debugPrint("========== PROFILE API START ==========");

      final token =
      LocalStorageService.instance.getString(StorageKeys.authToken);

      debugPrint("Token: $token");

      if (token == null || token.isEmpty) {
        debugPrint("❌ Token is missing");
        throw const _AuthMissingException();
      }
      // Use the shared profile endpoint for both student and organiser responses.
      final uri = Uri.parse(ApiConstants.authProfile);

      debugPrint("URL: $uri");
      debugPrint("Headers:");
      debugPrint("Authorization: Bearer $token");
      debugPrint("Content-Type: application/json");

      final response = await http
          .get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      )
          .timeout(_requestTimeout);

      debugPrint("========== RESPONSE ==========");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body:");
      debugPrint(response.body);

      if (response.statusCode == 200) {
        debugPrint("✅ Profile fetched successfully");

        final decoded = jsonDecode(response.body);
        debugPrint("Decoded JSON:");
        debugPrint(decoded.toString());

        final studentJson = _extractStudentJson(decoded);

        debugPrint("Extracted Student JSON:");
        debugPrint(studentJson.toString());

        final student = Student.fromJson(studentJson);

        debugPrint("Student Name: ${student.name}");
        debugPrint("Student Email: ${student.email}");
        debugPrint("Student Role: ${student.role}");

        _applyStudent(student);

        _lastSyncedAt = DateTime.now();
        _error = null;

        await LocalStorageService.instance.setModel<Student>(
          StorageKeys.userProfile,
          student,
              (s) => s.toJson(),
        );

        debugPrint("✅ Profile saved locally");
      } else if (response.statusCode == 401) {
        debugPrint("❌ Unauthorized (401)");
        _error = "Session expired. Please log in again.";
      } else {
        debugPrint("❌ Server Error: ${response.statusCode}");
        debugPrint(response.body);

        _error =
        "Couldn't refresh profile (server said ${response.statusCode}).";
      }
    } on _AuthMissingException {
      debugPrint("❌ Auth token missing");
      _error = hasProfile ? null : "Please log in to view your profile.";
    } on TimeoutException catch (e) {
      debugPrint("⏰ TimeoutException");
      debugPrint(e.toString());

      _error = hasProfile
          ? "Couldn't refresh — request timed out. Showing saved data."
          : "Request timed out. Check your connection and try again.";
    } on SocketException catch (e) {
      debugPrint("🌐 SocketException");
      debugPrint(e.toString());

      _error = hasProfile
          ? "You're offline — showing saved data."
          : "No internet connection.";
    } catch (e, stackTrace) {
      debugPrint("❌ Exception:");
      debugPrint(e.toString());

      debugPrint("StackTrace:");
      debugPrint(stackTrace.toString());

      _error = hasProfile
          ? "Couldn't refresh profile. Showing saved data."
          : "Failed to load profile: $e";
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      _fetchInFlight = false;

      debugPrint("Loading: $_isLoading");
      debugPrint("Refreshing: $_isRefreshing");
      debugPrint("Error: $_error");
      debugPrint("========== PROFILE API END ==========");

      notifyListeners();
    }
  }

  Map<String, dynamic> _extractStudentJson(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected profile response shape');
    }

    final candidates = [
      decoded['data'],
      decoded['user'],
      decoded['student'],
      decoded['organiser'],
    ];

    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        if (candidate.containsKey('_id') || candidate.containsKey('id')) {
          return candidate;
        }
      }
    }

    if (decoded.containsKey('_id') || decoded.containsKey('id')) {
      return decoded;
    }

    throw const FormatException('Student data not found');
  }

  void _applyStudent(Student s) {
    _id = s.id;
    _fullName = s.name;
    _email = s.email;
    _phoneNumber = s.phoneNumber;
    _username = s.username != null && s.username!.isNotEmpty
        ? (s.username!.startsWith('@') ? s.username! : '@${s.username}')
        : '';
    _bio = s.bio;
    _website = s.website ?? '';
    _role = s.role.toJson();
    _avatarUrl = s.profilePicture;
    _rollNumber = s.rollNumber;
    _branch = s.branch;
    _course = s.course;
    _yearOfStudy = s.year > 0 ? '${s.year}${_ordinal(s.year)} Year' : '';

    // Organiser fields
    _clubName = s.clubName ?? '';
    _category = s.category ?? '';
    _clubDescription = s.clubDescription ?? '';
    _facultyName = s.facultyName ?? '';
    _facultyEmail = s.facultyEmail ?? '';

    _joinedClubs = List.from(s.joinedClubs);
    _createdClubs = List.from(s.createdClubs);
    _version = s.version;
    _events = s.events!;
    _member = s.members!;
    _followers = s.followers!;
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // -----------------------------------------------------------------------
  // Build a complete Student from current provider state
  // -----------------------------------------------------------------------
  Student _toStudent({DateTime? updatedAt}) {
    return Student(
      id: _id,
      name: _fullName,
      email: _email,
      phoneNumber: _phoneNumber,
      rollNumber: _rollNumber,
      username: _username.isEmpty ? null : _username.replaceFirst('@', ''),
      branch: AppConstants.normalizeBranch(_branch),
      course: AppConstants.normalizeCourse(_course),
      year: yearNumber,
      profilePicture: _avatarUrl,
      bio: _bio,
      website: _website.isEmpty ? null : _website,
      clubName: _clubName.isEmpty ? null : _clubName,
      category: _category.isEmpty ? null : _category,
      clubDescription: _clubDescription.isEmpty ? null : _clubDescription,
      facultyName: _facultyName.isEmpty ? null : _facultyName,
      facultyEmail: _facultyEmail.isEmpty ? null : _facultyEmail,
      role: Role.fromString(_role),
      joinedClubs: _joinedClubs,
      createdClubs: _createdClubs,
      createdAt: null, // we don't track original createdAt in the provider
      updatedAt: updatedAt ?? DateTime.now(),
      version: _version,
    );
  }

  // -----------------------------------------------------------------------
  // SAVE PROFILE TO LOCAL STORAGE
  // -----------------------------------------------------------------------
  Future<bool> saveProfile() async {
    try {
      final student = _toStudent();

      final saved = await LocalStorageService.instance.setModel<Student>(
        StorageKeys.userProfile,
        student,
            (s) => s.toJson(),
      );

      if (saved) {
        _error = null;
        notifyListeners();
      }
      return saved;
    } catch (e) {
      _error = 'Failed to save profile: $e';
      notifyListeners();
      return false;
    }
  }

  // -----------------------------------------------------------------------
  // EDIT PROFILE
  // -----------------------------------------------------------------------
  /// Call from the Edit Profile screen's Save button.
  ///
  /// - Applies provided fields (null = leave untouched).
  /// - Persists locally first.
  /// - Then best-effort sync to API.
  Future<bool> submitProfileEdits({
    required String fullName,
    String? username,
    String? bio,
    String? website,
    String? phoneNumber,
    String? rollNumber,
    String? branch,
    String? course,
    int? yearOfStudy,
    // Organiser fields
    String? clubName,
    String? category,
    String? clubDescription,
    String? facultyName,
    String? facultyEmail,
    File? profileImage,
    bool isorganiser = false
  }) async {
    _isSaving = true;
    _saveError = null;
    notifyListeners();

    // ---- Update in-memory state ----
    _fullName = fullName.trim();

    if (username != null) {
      final trimmed = username.trim();
      _username = trimmed.isEmpty
          ? ''
          : (trimmed.startsWith('@') ? trimmed : '@$trimmed');
    }

    if (bio != null) _bio = bio.trim();
    if (website != null) _website = website.trim();
    if (phoneNumber != null) _phoneNumber = phoneNumber.trim();
    if (rollNumber != null) _rollNumber = rollNumber.trim();
    if (branch != null) _branch = AppConstants.normalizeBranch(branch);
    if (course != null) _course = AppConstants.normalizeCourse(course);

    if (yearOfStudy != null) {
      _yearOfStudy =
      yearOfStudy > 0 ? '$yearOfStudy${_ordinal(yearOfStudy)} Year' : '';
    }

    if (clubName != null) _clubName = clubName.trim();
    if (category != null) _category = category.trim();
    if (clubDescription != null) _clubDescription = clubDescription.trim();
    if (facultyName != null) _facultyName = facultyName.trim();
    if (facultyEmail != null) _facultyEmail = facultyEmail.trim();

    final savedLocally = await saveProfile();

    // ---- Push to API ----
    try {
      final token =
      LocalStorageService.instance.getString(StorageKeys.authToken);

      if (token == null || token.isEmpty) {
        throw const _AuthMissingException();
      }

      // Shared profile update endpoint works for both student and organiser accounts.
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiConstants.authProfile),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Core fields
      request.fields['name'] = _fullName;
      request.fields['username'] = _username.replaceFirst('@', '');
      request.fields['bio'] = _bio;
      request.fields['website'] = _website;
      request.fields['phoneNumber'] = _phoneNumber;
      request.fields['rollNumber'] = _rollNumber;
      request.fields['branch'] = _branch;
      request.fields['course'] = _course;
      request.fields['year'] = yearNumber.toString();

      // Organiser fields (send empty string when cleared)
      request.fields['clubName'] = _clubName;
      request.fields['category'] = _category;
      request.fields['clubDescription'] = _clubDescription;
      request.fields['facultyName'] = _facultyName;
      request.fields['facultyEmail'] = _facultyEmail;

      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            profileImage.path,
          ),
        );
      }

      debugPrint('========== MULTIPART REQUEST ==========');
      debugPrint(request.fields.toString());
      debugPrint('Image: ${profileImage?.path}');

      final streamedResponse =
      await request.send().timeout(_requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        // Optionally re-apply any server-side mutations (e.g. new avatar URL)
        try {
          final decoded = jsonDecode(response.body);
          final studentJson = _extractStudentJson(decoded);
          final student = Student.fromJson(studentJson);
          _applyStudent(student);
          await LocalStorageService.instance.setModel<Student>(
            StorageKeys.userProfile,
            student,
                (s) => s.toJson(),
          );
        } catch (_) {
          // Non-fatal – local state is already good
        }

        _saveError = null;
        _lastSyncedAt = DateTime.now();
      } else if (response.statusCode == 401) {
        _saveError =
        'Session expired — changes saved on this device only.';
      } else {
        _saveError =
        'Server rejected the update (${response.statusCode}).';
      }
    } on _AuthMissingException {
      _saveError = 'Not logged in — changes saved on this device only.';
    } on TimeoutException {
      _saveError = 'Saved locally — sync timed out.';
    } on SocketException {
      _saveError = "Saved locally — you're offline.";
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      _saveError = 'Sync failed: $e';
    } finally {
      _isSaving = false;
      notifyListeners();
    }

    return savedLocally;
  }

  // -----------------------------------------------------------------------
  // Other actions
  // -----------------------------------------------------------------------
  void toggleFollow() {
    _isFollowing = !_isFollowing;
    notifyListeners();
  }

  void updateBio(String newBio) {
    _bio = newBio;
    notifyListeners();
  }

  void updateWebsite(String value) {
    _website = value;
    notifyListeners();
  }

  void updateUsername(String value) {
    _username = value.startsWith('@') ? value : '@$value';
    notifyListeners();
  }

  void addParticipation(ParticipationEntry entry) {
    _participationData = [..._participationData, entry];
    notifyListeners();
  }

  void setParticipationData(List<ParticipationEntry> data) {
    _participationData = List.from(data);
    notifyListeners();
  }

  void clearProfile() {
    _id = '';
    _fullName = '';
    _email = '';
    _phoneNumber = '';
    _username = '';
    _bio = '';
    _website = '';
    _avatarUrl = '';
    _rollNumber = '';
    _branch = '';
    _course = '';
    _yearOfStudy = '';
    _role = '';
    _clubName = '';
    _category = '';
    _clubDescription = '';
    _facultyName = '';
    _facultyEmail = '';
    _joinedClubs = [];
    _createdClubs = [];
    _version = 0;
    _participationData = [];
    _error = null;
    _lastSyncedAt = null;
    notifyListeners();
  }
}

class _AuthMissingException implements Exception {
  const _AuthMissingException();
}