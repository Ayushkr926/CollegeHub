enum ClubTag { none, popular, trending }

class Club {
  final String id;
  final String ownerUserId;
  final String name;
  final String email;
  final String website;
  final String username;
  final String phoneNumber;
  final String branch;
  final String course;

  final String clubName;
  final String category;
  final String facultyName;
  final String facultyEmail;

  final bool isOfficialClub;
  final bool isVerified;
  final double rating;

  final String logoPath;
  final String profilePicture;
  final String clubDescription;
  final String? bio;

  final String role;

  final int members;
  final int events;
  final int followers;

  final List<dynamic> joinedClubs;
  final List<dynamic> createdClubs;
  final List<dynamic> membersData;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final ClubTag tag;
  final String emoji;

  bool isJoined;
  String? joinRequestStatus;

  Club({
    required this.id,
    this.ownerUserId = '',
    required this.name,
    required this.email,
    required this.website,
    required this.username,
    required this.phoneNumber,
    required this.branch,
    required this.course,
    required this.clubName,
    required this.category,
    required this.facultyName,
    required this.facultyEmail,
    required this.isOfficialClub,
    this.isVerified = false,
    this.rating = 4.8,
    required this.logoPath,
    required this.profilePicture,
    required this.clubDescription,
     this.bio='',
    required this.role,
    required this.members,
    required this.events,
    required this.followers,
    required this.joinedClubs,
    required this.createdClubs,
    required this.membersData,
    required this.createdAt,
    required this.updatedAt,
    this.tag = ClubTag.none,
    this.emoji = "🎯",
    this.isJoined = false,
    this.joinRequestStatus,
  });

  factory Club.fromOrganiserJson(Map<String, dynamic> json) {
    final createdClubs = json["createdClubs"] as List? ?? [];

    int memberCount;

    if (json["members"] is int) {
      memberCount = json["members"];
    } else {
      memberCount = createdClubs.fold<int>(
        0,
            (sum, club) {
          if (club is Map && club["members"] is List) {
            return sum + (club["members"] as List).length;
          }
          return sum;
        },
      );
    }

    int eventCount;

    if (json["events"] is int) {
      eventCount = json["events"];
    } else if (json["events"] is List) {
      eventCount = (json["events"] as List).length;
    } else {
      eventCount = createdClubs.length;
    }

    return Club(
      id: json["_id"]?.toString() ?? "",
      name: (json["clubName"] ?? json["name"])?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      website: json["website"]?.toString() ?? "",
      username: json["username"]?.toString() ?? "",
      phoneNumber: json["phoneNumber"]?.toString() ?? "",
      branch: json["branch"]?.toString() ?? "",
      course: json["course"]?.toString() ?? "",

      clubName: json["clubName"]?.toString() ?? "",
      category: json["category"]?.toString() ?? "General",

      facultyName: json["facultyName"]?.toString() ?? "",
      facultyEmail: json["facultyEmail"]?.toString() ?? "",

      isOfficialClub: json["isOfficialClub"] ?? false,
      isVerified: json["isVerified"] ?? json["verified"] ?? false,
      rating: _readDouble(json["rating"]) ?? 4.8,

      logoPath: json["logoPath"]?.toString() ?? "",
      profilePicture: json["profilePicture"]?.toString() ?? "",

      clubDescription: json["clubDescription"]?.toString() ?? "",
      bio: json["bio"]?.toString() ?? "",

      role: json["role"]?.toString() ?? "organiser",

      members: memberCount,
      events: eventCount,
      followers: json["followers"] ?? 0,

      joinedClubs: json["joinedClubs"] as List? ?? [],
      createdClubs: createdClubs,
      membersData: json["membersdata"] as List? ?? [],

      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,

      tag: memberCount > 10 ? ClubTag.popular : ClubTag.none,
    );
  }

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory Club.fromClubJson(Map<String, dynamic> json) {
    final organiser = json['organiser'];
    final createdBy = json['createdBy'];
    final organiserSource = organiser ?? createdBy;
    final organiserMap = organiserSource is Map<String, dynamic>
      ? organiserSource
      : organiserSource is Map
        ? Map<String, dynamic>.from(organiserSource)
        : <String, dynamic>{};

    final idValue = json['_id'] ?? json['id'] ?? json['clubId'] ?? '';
    final clubName = (json['clubName'] ?? json['name'] ?? organiserMap['clubName'] ?? organiserMap['name'] ?? '').toString();
    final description = (json['description'] ?? json['clubDescription'] ?? json['bio'] ?? organiserMap['clubDescription'] ?? organiserMap['description'] ?? '').toString();
    final profilePicture = (json['profilePicture'] ?? json['logo'] ?? json['image'] ?? organiserMap['profilePicture'] ?? organiserMap['logoPath'] ?? '').toString();
    final category = (json['category'] ?? organiserMap['category'] ?? 'General').toString();
    final members = _readInt(
      json['memberCount'] ?? json['membersCount'] ?? json['members'],
      fallback: (json['members'] is List ? (json['members'] as List).length : 0),
    );
    final events = _readInt(
      json['eventCount'] ?? json['eventsCount'] ?? json['events'],
      fallback: (json['events'] is List ? (json['events'] as List).length : 0),
    );
    final followers = _readInt(json['followers'] ?? json['followersCount'], fallback: 0);

    return Club(
      id: idValue.toString(),
      ownerUserId: _referenceId(json['createdBy'] ?? organiserMap['_id']),
      name: clubName,
      email: (json['email'] ?? organiserMap['email'] ?? '').toString(),
      website: (json['website'] ?? organiserMap['website'] ?? '').toString(),
      username: (json['username'] ?? organiserMap['username'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? organiserMap['phoneNumber'] ?? '').toString(),
      branch: (json['branch'] ?? organiserMap['branch'] ?? '').toString(),
      course: (json['course'] ?? organiserMap['course'] ?? '').toString(),
      clubName: clubName,
      category: category,
      facultyName: (json['facultyName'] ?? organiserMap['facultyName'] ?? '').toString(),
      facultyEmail: (json['facultyEmail'] ?? organiserMap['facultyEmail'] ?? '').toString(),
      isOfficialClub: json['isOfficialClub'] ?? organiserMap['isOfficialClub'] ?? false,
      isVerified: json['isVerified'] ?? json['verified'] ?? organiserMap['isVerified'] ?? false,
      rating: _readDouble(json['rating']) ?? 4.8,
      logoPath: (json['logoPath'] ?? json['logo'] ?? organiserMap['logoPath'] ?? '').toString(),
      profilePicture: profilePicture,
      clubDescription: description,
      bio: description,
      role: (json['role'] ?? organiserMap['role'] ?? 'student').toString(),
      members: members,
      events: events,
      followers: followers,
      joinedClubs: json['joinedClubs'] is List ? List.from(json['joinedClubs']) : const [],
      createdClubs: json['createdClubs'] is List ? List.from(json['createdClubs']) : const [],
      membersData: json['membersData'] is List ? List.from(json['membersData']) : const [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      tag: members > 10 ? ClubTag.popular : ClubTag.none,
      emoji: '🎯',
      isJoined: json['isJoined'] ?? json['joined'] ?? false,
      joinRequestStatus: json['joinRequestStatus']?.toString(),
    );
  }

  static String _referenceId(dynamic value) {
    if (value is Map) return (value['_id'] ?? value['id'] ?? '').toString();
    return value?.toString() ?? '';
  }
}

class FeaturedClub {
  final String name;
  final String description;
  final String imageUrl;

  const FeaturedClub({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}