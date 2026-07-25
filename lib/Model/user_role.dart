// -----------------------------------------------------------------------
// student_model.dart
// -----------------------------------------------------------------------
// Advanced, null-safe Dart models for the "Student Registration" API
// response, matching this shape:
//
// {
//   "success": true,
//   "message": "Student registered successfully",
//   "data": {
//     "student": { ...Student fields... },
//     "token": "jwt..."
//   },
//   "error": null
// }
//
// Includes:
//  - RegisterResponse   -> top-level API envelope (success, message, data, error)
//  - AuthData           -> { student, token }
//  - Student            -> full student model
//  - Role / Course enums with safe fallback parsing
//  - fromJson / toJson on every model
//  - copyWith on every model
//  - value equality (==, hashCode) + readable toString()
//  - Defensive parsing: missing/null/wrong-typed fields never crash,
//    they fall back to sensible defaults.
// -----------------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------

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
        // TODO: Handle this case.
        throw UnimplementedError();
      case Role.unknown:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String get description {
    switch (this) {
      case Role.student:
        return 'Discover events, join clubs and stay updated with campus life.';
      case Role.clubHead:
        return 'Create events, manage members and grow your club community.';
      case Role.admin:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Role.unknown:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  IconData get icon {
    switch (this) {
      case Role.student:
        return Icons.school_outlined;
      case Role.clubHead:
        return Icons.groups_outlined;
      case Role.admin:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Role.unknown:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static Role fromString(String? value) {
    switch (value) {
      case 'student':
        return Role.student;
      case 'admin':
        return Role.admin;
      case 'clubHead':
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
        return 'clubHead';
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

// ---------------------------------------------------------------------
// Helper: safe parsing utilities
// ---------------------------------------------------------------------

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
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}

// ---------------------------------------------------------------------
// Student
// ---------------------------------------------------------------------

class Student {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String rollNumber;
  final String branch;
  final Course course;
  final int year;
  final String profilePicture;
  final String bio;
  final Role role;
  final List<String> joinedClubs;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;

  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.rollNumber,
    required this.branch,
    required this.course,
    required this.year,
    required this.profilePicture,
    required this.bio,
    required this.role,
    required this.joinedClubs,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  /// An empty/placeholder student, useful as a default/initial state.
  factory Student.empty() => Student(
    id: '',
    name: '',
    email: '',
    phoneNumber: '',
    rollNumber: '',
    branch: '',
    course: Course.other,
    year: 0,
    profilePicture: '',
    bio: '',
    role: Role.unknown,
    joinedClubs: const [],
    createdAt: null,
    updatedAt: null,
    version: 0,
  );

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: _Parse.string(json['_id'] ?? json['id']),
      name: _Parse.string(json['name']),
      email: _Parse.string(json['email']),
      phoneNumber: _Parse.string(json['phoneNumber']),
      rollNumber: _Parse.string(json['rollNumber']),
      branch: _Parse.string(json['branch']),
      course: Course.fromString(json['course'] as String?),
      year: _Parse.integer(json['year']),
      profilePicture: _Parse.string(json['profilePicture']),
      bio: _Parse.string(json['bio']),
      role: Role.fromString(json['role'] as String?),
      joinedClubs: _Parse.stringList(json['joinedClubs']),
      createdAt: _Parse.dateTime(json['createdAt']),
      updatedAt: _Parse.dateTime(json['updatedAt']),
      version: _Parse.integer(json['__v']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'rollNumber': rollNumber,
      'branch': branch,
      'course': course.toJson(),
      'year': year,
      'profilePicture': profilePicture,
      'bio': bio,
      'role': role.toJson(),
      'joinedClubs': joinedClubs,
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
    String? branch,
    Course? course,
    int? year,
    String? profilePicture,
    String? bio,
    Role? role,
    List<String>? joinedClubs,
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
      branch: branch ?? this.branch,
      course: course ?? this.course,
      year: year ?? this.year,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      joinedClubs: joinedClubs ?? this.joinedClubs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  /// Convenience getter, e.g. for avatar placeholders.
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
      'Student(id: $id, name: $name, email: $email, rollNumber: $rollNumber, '
          'branch: $branch, course: ${course.toJson()}, year: $year, role: ${role.toJson()})';
}

// ---------------------------------------------------------------------
// AuthData ({ student, token })
// ---------------------------------------------------------------------

class AuthData {
  final Student student;
  final String token;

  const AuthData({required this.student, required this.token});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      student: Student.fromJson(
        (json['student'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      token: _Parse.string(json['token']),
    );
  }

  Map<String, dynamic> toJson() => {
    'student': student.toJson(),
    'token': token,
  };

  AuthData copyWith({Student? student, String? token}) {
    return AuthData(
      student: student ?? this.student,
      token: token ?? this.token,
    );
  }

  /// Decodes the JWT payload (middle segment) without verifying the
  /// signature — useful for reading `exp`/`iat` client-side.
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

  /// Returns the token's expiry as a DateTime, if decodable.
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
    return other is AuthData && other.token == token && other.student == student;
  }

  @override
  int get hashCode => Object.hash(student, token);

  @override
  String toString() => 'AuthData(student: $student, token: ${token.isEmpty ? '' : '***'})';
}

// ---------------------------------------------------------------------
// RegisterResponse (top-level API envelope)
// ---------------------------------------------------------------------

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

  /// Parses directly from a raw JSON string (as returned by http.Response.body).
  factory RegisterResponse.fromRawJson(String source) =>
      RegisterResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
    'error': error,
  };

  String toRawJson() => jsonEncode(toJson());

  /// True when the response succeeded AND contains a student + token.
  bool get isValid => success && data != null && data!.token.isNotEmpty;

  RegisterResponse copyWith({
    bool? success,
    String? message,
    AuthData? data,
    String? error,
  }) {
    return RegisterResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  String toString() =>
      'RegisterResponse(success: $success, message: $message, data: $data, error: $error)';
}