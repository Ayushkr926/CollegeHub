import 'package:flutter/material.dart';

import '../Model/club.dart';
import '../Screen/Clubs/discover_clubs_screen.dart';

class ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onView;
  final VoidCallback onJoin;

  const ClubCard({
    super.key,
    required this.club,
    required this.onView,
    required this.onJoin,
  });

  Color get _tagColor {
    switch (club.tag) {
      case ClubTag.popular:
        return const Color(0xFF3B82F6);
      case ClubTag.trending:
        return const Color(0xFFF97316);
      case ClubTag.none:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image(
                      image: AssetImage("assets/images/onboarding.jpg"),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15,),
              Text(
                club.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (club.tag != ClubTag.none)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _tagColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    club.tagLabel,
                    style: TextStyle(
                      color: _tagColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          const SizedBox(height: 6),
          Text(
            club.description,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.groups_rounded,
                  size: 16, color: AppColors.textFaint),
              const SizedBox(width: 6),
              Text(
                '${club.members} Members',
                style: const TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: onView,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('View',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      club.isJoined ? AppColors.surfaceElevated : Colors.white,
                  foregroundColor:
                      club.isJoined ? Colors.white : Colors.black,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: club.isJoined
                        ? const BorderSide(color: AppColors.border)
                        : BorderSide.none,
                  ),
                ),
                child: Text(
                  club.isJoined ? 'Joined' : 'Join',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
