enum ClubTag { none, popular, trending }

class Club {
  final String id;
  final String name;
  final String description;
  final String category;
  final int members;
  final ClubTag tag;
  final String emoji;
  bool isJoined;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.members,
    this.tag = ClubTag.none,
    this.emoji = '🎯',
    this.isJoined = false,
  });

  String get tagLabel {
    switch (tag) {
      case ClubTag.popular:
        return 'Popular';
      case ClubTag.trending:
        return 'Trending';
      case ClubTag.none:
        return '';
    }
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
