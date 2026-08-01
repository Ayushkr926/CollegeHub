enum ClubTag { none, popular, trending }

class Club {
  final String id;
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

  Club({
    required this.id,
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
      name: json["name"]?.toString() ?? "",
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