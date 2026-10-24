import 'package:flutter/material.dart';

import '../Screen/Clubs/discover_clubs_screen.dart';
import '../Model/club.dart';

// ============ ENHANCED CLUB CARD (COMPACT & BEAUTIFUL) ============
class ClubCard extends StatefulWidget {
  final Club club;
  final VoidCallback onView;
  final VoidCallback onJoin;

  const ClubCard({
    super.key,
    required this.club,
    required this.onView,
    required this.onJoin,
  });

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  bool _isHovered = false;

  Color get _tagColor {
    switch (widget.club.tag) {
      case ClubTag.popular:
        return const Color(0xFF3B82F6);
      case ClubTag.trending:
        return const Color(0xFFF97316);
      case ClubTag.none:
        return Colors.transparent;
    }
  }

  String get _tagLabel {
    switch (widget.club.tag) {
      case ClubTag.popular:
        return '⭐ Popular';
      case ClubTag.trending:
        return '🔥 Trending';
      case ClubTag.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.club.profilePicture;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered ? Colors.white24 : AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.2),
              blurRadius: _isHovered ? 16 : 8,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Logo + Name + Tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                AnimatedScale(
                  scale: _isHovered ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white12,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.surface,
                      child: ClipOval(
                        child: (url != null && url.isNotEmpty)
                            ? Image.network(
                          url,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/onboarding.jpg',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Image.asset(
                          'assets/images/onboarding.jpg',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + Tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.club.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (widget.club.tag != ClubTag.none)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _tagColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _tagColor.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _tagLabel,
                            style: TextStyle(
                              color: _tagColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Verification Badge
                if (widget.club.isVerified)
                  Tooltip(
                    message: 'Verified Club',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3B82F6),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.verified,
                        size: 16,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              widget.club.bio!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),

            // Stats Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem(Icons.people_rounded, '${widget.club.members}', 'Members'),
                  _statDivider(),
                  _statItem(Icons.event_rounded, '${widget.club.events}', 'Events'),
                  _statDivider(),
                  _statItem(Icons.star_rounded, '${widget.club.rating}', 'Rating'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onView,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.club.isJoined ||
                        widget.club.joinRequestStatus == 'pending'
                      ? null
                      : widget.onJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.club.isJoined
                          ? Colors.green.shade600
                          : Colors.white,
                      foregroundColor:
                      widget.club.isJoined ? Colors.white : Colors.black,
                      elevation: widget.club.isJoined ? 0 : 2,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            widget.club.isJoined
                              ? Icons.check
                              : widget.club.joinRequestStatus == 'pending'
                                ? Icons.hourglass_top
                                : Icons.add_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                            widget.club.isJoined
                              ? 'Joined'
                              : widget.club.joinRequestStatus == 'pending'
                                ? 'Request Sent'
                                : 'Join Club',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textFaint,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white10,
    );
  }
}

// ============ COMPACT MINIMAL CARD ============
class CompactClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onView;
  final VoidCallback onJoin;

  const CompactClubCard({
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
    final url = club.profilePicture;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: ClipOval(
                  child: (url != null && url.isNotEmpty)
                      ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/onboarding.jpg',
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(
                    'assets/images/onboarding.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Name + Members
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 12, color: AppColors.textFaint),
                        const SizedBox(width: 3),
                        Text(
                          '${club.members} members',
                          style: const TextStyle(
                            color: AppColors.textFaint,
                            fontSize: 11,
                          ),
                        ),
                        if (club.tag != ClubTag.none) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _tagColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              club.tag == ClubTag.popular ? '⭐' : '🔥',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Description
          Text(
            club.bio!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: onJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    club.isJoined ? Colors.green.shade600 : Colors.white,
                    foregroundColor: club.isJoined ? Colors.white : Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    club.isJoined ? 'Joined' : 'Join',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ COLOR SCHEME ============
class AppColors {
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF2D2D2D);
  static const Color textMuted = Color(0xFFB0B0B0);
  static const Color textFaint = Color(0xFF808080);
  static const Color primary = Colors.white;
}

// ============ CLUB MODEL EXTENSION ============
extension ClubExtension on Club {
  bool get isVerified => true; // Add your verification logic
  int get events => 8; // Add events count logic
  double get rating => 4.8; // Add rating logic
}