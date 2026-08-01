// lib/models/participation_entry.dart
enum RankTier { gold, silver, bronze, participant }

class ParticipationEntry {
  final String eventName;
  final String date;
  final String position;
  final RankTier tier;

  const ParticipationEntry({
    required this.eventName,
    required this.date,
    required this.position,
    required this.tier,
  });
}