import '../utils/app_constants.dart';

enum RequestStatus { pending, accepted, declined }

class Request {
  final String id;
  final String name;
  final String branch;
  final int year;
  final String clubId;
  final String clubName;
  final String image;
  final String timeago;
  RequestStatus status;

  Request({
    required this.id,
    required this.name,
    required String branch,
    required this.year,
    this.clubId = '',
    this.clubName = '',
    this.image = 'assets/images/onboarding.jpg',
    this.timeago = '1h ago',
    this.status = RequestStatus.pending,
  }) : branch = AppConstants.normalizeBranch(branch);

  factory Request.fromJson(Map<String, dynamic> json) {
    final student = json['student'] is Map
        ? Map<String, dynamic>.from(json['student'] as Map)
        : <String, dynamic>{};
    final club = json['club'] is Map
        ? Map<String, dynamic>.from(json['club'] as Map)
        : <String, dynamic>{};
    final statusValue = json['status']?.toString();
    return Request(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (student['name'] ?? 'Student').toString(),
      branch: (student['branch'] ?? '').toString(),
      year: AppConstants.normalizeYear(student['year']) ?? 0,
      clubId: (club['_id'] ?? '').toString(),
      clubName: (club['name'] ?? '').toString(),
      image: (student['profilePicture'] ?? 'assets/images/onboarding.jpg').toString(),
      timeago: json['createdAt']?.toString() ?? '',
      status: switch (statusValue) {
        'approved' => RequestStatus.accepted,
        'rejected' => RequestStatus.declined,
        _ => RequestStatus.pending,
      },
    );
  }
}