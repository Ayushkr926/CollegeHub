import 'dart:convert';
import 'package:flutter/material.dart';

/// User role within the platform.
enum Role {
  student,
  admin,
  clubHead,
  unknown;

  String get title {
    switch (this) {
      case Role.student:
        return 'Student';
      case Role.clubHead:
        return 'Club Organizer';
      case Role.admin:
        return 'Admin';
      case Role.unknown:
        return 'Member';
    }
  }

  String get description {
    switch (this) {
      case Role.student:
        return 'Discover events, join clubs and stay updated with campus life.';
      case Role.clubHead:
        return 'Create events, manage members and grow your club community.';
      case Role.admin:
        return 'Manage the platform, oversee clubs and moderate content.';
      case Role.unknown:
        return 'Welcome to CampusHub.';
    }
  }

  IconData get icon {
    switch (this) {
      case Role.student:
        return Icons.school_outlined;
      case Role.clubHead:
        return Icons.groups_outlined;
      case Role.admin:
        return Icons.admin_panel_settings_outlined;
      case Role.unknown:
        return Icons.person_outline;
    }
  }

  static Role fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'student':
        return Role.student;
      case 'admin':
        return Role.admin;
      case 'organiser':
      case 'organizer':
      case 'clubhead':
      case 'club_head':
        return Role.clubHead;
      default:
        return Role.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case Role.student:
        return 'student';
      case Role.admin:
        return 'admin';
      case Role.clubHead:
        return 'organiser';
      case Role.unknown:
        return 'unknown';
    }
  }
}

/// Academic course/degree.
enum Course {
  btech,
  mtech,
  bca,
  mca,
  other;

  static Course fromString(String? value) {
    switch (value) {
      case 'B.Tech':
        return Course.btech;
      case 'M.Tech':
        return Course.mtech;
      case 'BCA':
        return Course.bca;
      case 'MCA':
        return Course.mca;
      default:
        return Course.other;
    }
  }

  String toJson() {
    switch (this) {
      case Course.btech:
        return 'B.Tech';
      case Course.mtech:
        return 'M.Tech';
      case Course.bca:
        return 'BCA';
      case Course.mca:
        return 'MCA';
      case Course.other:
        return 'Other';
    }
  }
}

class _Parse {
  static String string(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  static int integer(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static bool boolean(dynamic v, {bool fallback = false}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    return v.toString().toLowerCase() == 'true';
  }

  static DateTime? dateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static List<String> stringList(dynamic v) {
    if (v == null) return [];
    if (v is List) {
      return v.map((e) {
        if (e is Map && e.containsKey('_id')) return e['_id'].toString();
        return e.toString();
      }).toList();
    }
    return [];
  }
}

/// Unified User / Student model matching the backend database schema.
class Student {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String rollNumber;
  final String? username;
  final String branch;
  final String course;
  final int year;
  final String profilePicture;
  final String bio;
  final String? website;

  // Organiser fields
  final String? clubName;
  final String? category;
  final String? clubDescription;
  final String? facultyName;
  final String? facultyEmail;
  final int? events;
  final int? members;
  final int? followers;

  final Role role;
  final List<String> joinedClubs;
  final List<String> createdClubs;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;

  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.rollNumber = '',
    this.username,
    this.branch = '',
    this.course = '',
    this.year = 0,
    required this.profilePicture,
    required this.bio,
    this.website,
    this.clubName,
    this.category,
    this.clubDescription,
    this.facultyName,
    this.facultyEmail,
    required this.role,
    required this.joinedClubs,
    this.createdClubs = const [],
    this.createdAt,
    this.updatedAt,
    this.events = 0,
    this.members = 0,
    this.followers = 0,
    required this.version,
  });

  factory Student.empty() => const Student(
    id: '',
    name: '',
    email: '',
    phoneNumber: '',
    rollNumber: '',
    username: null,
    branch: '',
    course: '',
    year: 0,
    profilePicture: '',
    bio: '',
    website: null,
    clubName: null,
    category: null,
    clubDescription: null,
    facultyName: null,
    facultyEmail: null,
    events: 0,
    members: 0,
    followers: 0,
    role: Role.unknown,
    joinedClubs: [],
    createdClubs: [],
    createdAt: null,
    updatedAt: null,
    version: 0,
  );

  factory Student.fromJson(Map<String, dynamic> json) {
    // If json contains nested user object key, unwrap it cleanly
    final Map<String, dynamic> dataMap = (json['user'] ??
        json['student'] ??
        json['organiser'] ??
        json['data'] ??
        json) as Map<String, dynamic>;

    final actualMap = (dataMap.containsKey('_id') || dataMap.containsKey('id'))
        ? dataMap
        : json;

    return Student(
      id: _Parse.string(actualMap['_id'] ?? actualMap['id']),
      name: _Parse.string(actualMap['name'] ?? actualMap['clubName']),
      email: _Parse.string(actualMap['email']),
      phoneNumber: _Parse.string(actualMap['phoneNumber'] ?? actualMap['phone']),
      rollNumber: _Parse.string(actualMap['rollNumber']),
      username: actualMap['username'] as String?,
      branch: _Parse.string(actualMap['branch']),
      course: _Parse.string(actualMap['course']),
      year: _Parse.integer(actualMap['year']),
      profilePicture: _Parse.string(actualMap['profilePicture'] ?? actualMap['logoPath']),
      bio: _Parse.string(actualMap['bio']),
      website: actualMap['website'] as String?,
      clubName: actualMap['clubName'] as String?,
      category: actualMap['category'] as String?,
      clubDescription: actualMap['clubDescription'] as String?,
      facultyName: actualMap['facultyName'] as String?,
      facultyEmail: actualMap['facultyEmail'] as String?,
      events: _Parse.integer(actualMap['events']),
      members:  _Parse.integer(actualMap['members']),
      followers: _Parse.integer(actualMap['followers']),
      role: Role.fromString(actualMap['role'] as String?),
      joinedClubs: _Parse.stringList(actualMap['joinedClubs']),
      createdClubs: _Parse.stringList(actualMap['createdClubs']),
      createdAt: _Parse.dateTime(actualMap['createdAt']),
      updatedAt: _Parse.dateTime(actualMap['updatedAt']),
      version: _Parse.integer(actualMap['__v']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'rollNumber': rollNumber,
      'username': username,
      'branch': branch,
      'course': course,
      'year': year,
      'profilePicture': profilePicture,
      'bio': bio,
      'website': website,
      'clubName': clubName,
      'category': category,
      'clubDescription': clubDescription,
      'facultyName': facultyName,
      'facultyEmail': facultyEmail,
      'role': role.toJson(),
      'joinedClubs': joinedClubs,
      'createdClubs': createdClubs,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }

  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? rollNumber,
    String? username,
    String? branch,
    String? course,
    int? year,
    String? profilePicture,
    String? bio,
    String? website,
    String? clubName,
    String? category,
    String? clubDescription,
    String? facultyName,
    String? facultyEmail,
    Role? role,
    List<String>? joinedClubs,
    List<String>? createdClubs,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rollNumber: rollNumber ?? this.rollNumber,
      username: username ?? this.username,
      branch: branch ?? this.branch,
      course: course ?? this.course,
      year: year ?? this.year,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      clubName: clubName ?? this.clubName,
      category: category ?? this.category,
      clubDescription: clubDescription ?? this.clubDescription,
      facultyName: facultyName ?? this.facultyName,
      facultyEmail: facultyEmail ?? this.facultyEmail,
      role: role ?? this.role,
      joinedClubs: joinedClubs ?? this.joinedClubs,
      createdClubs: createdClubs ?? this.createdClubs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  bool get hasProfilePicture => profilePicture.isNotEmpty;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student && other.id == id && other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, updatedAt);

  @override
  String toString() =>
      'Student(id: $id, name: $name, email: $email, role: ${role.toJson()})';
}

/// ProfileResponse for GET /api/v1/auth/profile or /me
class ProfileResponse {
  final bool success;
  final String message;
  final Student? data;
  final String? error;

  const ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.error,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    Student? userStudent;
    if (json['data'] != null) {
      if (json['data'] is Map) {
        final Map<String, dynamic> dataMap =
        (json['data'] as Map).cast<String, dynamic>();
        userStudent = Student.fromJson(dataMap);
      }
    }

    return ProfileResponse(
      success: _Parse.boolean(json['success']),
      message: _Parse.string(json['message']),
      data: userStudent,
      error: json['error'] as String?,
    );
  }

  factory ProfileResponse.fromRawJson(String source) =>
      ProfileResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
    'error': error,
  };

  bool get isValid => success && data != null && data!.id.isNotEmpty;
}

/// AuthData for Login / Registration responses ({ user, token })
class AuthData {
  final Student user;
  final String token;

  const AuthData({required this.user, required this.token});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'] ?? json['student'] ?? json['organiser'] ?? json;
    return AuthData(
      user: Student.fromJson(
        rawUser is Map ? rawUser.cast<String, dynamic>() : const {},
      ),
      token: _Parse.string(json['token']),
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'token': token,
  };

  Map<String, dynamic>? decodeTokenPayload() {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  DateTime? get expiresAt {
    final payload = decodeTokenPayload();
    final exp = payload?['exp'];
    if (exp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      (exp as int) * 1000,
      isUtc: true,
    );
  }

  bool get isExpired {
    final exp = expiresAt;
    if (exp == null) return false;
    return DateTime.now().toUtc().isAfter(exp);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthData && other.token == token && other.user == user;
  }

  @override
  int get hashCode => Object.hash(user, token);
}

/// RegisterResponse / LoginResponse envelope
class RegisterResponse {
  final bool success;
  final String message;
  final AuthData? data;
  final String? error;

  const RegisterResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.error,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: _Parse.boolean(json['success']),
      message: _Parse.string(json['message']),
      data: json['data'] == null
          ? null
          : AuthData.fromJson((json['data'] as Map).cast<String, dynamic>()),
      error: json['error'] as String?,
    );
  }

  factory RegisterResponse.fromRawJson(String source) =>
      RegisterResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
    'error': error,
  };

  bool get isValid => success && data != null && data!.token.isNotEmpty;
}
