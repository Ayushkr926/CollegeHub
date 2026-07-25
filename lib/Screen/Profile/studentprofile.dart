

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import '../../BottomNav/animated_bottom_bar.dart';



class AppColors {
  static const bg = Colors.black;
  static const card = Color(0xFF161616);
  static const cardBorder = Color(0xFF2A2A2A);
  static const divider = Color(0xFF262626);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF9C9C9C);
  static const textMuted = Color(0xFF6E6E6E);
  static const gold = Color(0xFFE8B84B);
  static const silver = Color(0xFFC0C4CC);
  static const bronze = Color(0xFFCD8B57);
  static const neutralRank = Color(0xFF6F87FF);
}

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

const List<ParticipationEntry> _participationData = [
  ParticipationEntry(
    eventName: 'Flutter Hackathon 2024',
    date: 'Sept 12, 2024',
    position: '1st Place',
    tier: RankTier.gold,
  ),
  ParticipationEntry(
    eventName: 'UI/UX Design Sprint',
    date: 'Aug 5, 2024',
    position: '2nd Place',
    tier: RankTier.silver,
  ),
  ParticipationEntry(
    eventName: 'CodeFest Annual',
    date: 'Mar 20, 2024',
    position: '3rd Place',
    tier: RankTier.bronze,
  ),
  ParticipationEntry(
    eventName: 'Web Dev Bootcamp Challenge',
    date: 'Jan 15, 2024',
    position: 'Participant',
    tier: RankTier.participant,
  ),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const _ProfileHeader(),
                    const SizedBox(height: 20),
                    _CustomTabBar(controller: _tabController),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 20),
                    // Fixed-height area so both tabs render without a
                    // scrollable-inside-scrollable conflict.
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          AcademicInfoTab(),
                          ParticipationTab(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: const AnimatedBottomBar(),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ---------- Top bar ----------
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF1E1E1E),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/onboarding.jpg",
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'CAMPUSHUB',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          const Icon(Icons.settings, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}

// ---------- Profile header ----------
class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader({super.key});

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  final GlobalKey<FlipCardState> _flipKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait a little after the screen appears
      await Future.delayed(const Duration(milliseconds: 400));

      // First Flip
      _flipKey.currentState?.toggleCard();

      await Future.delayed(const Duration(milliseconds: 800));

      // Second Flip (back to front)
      _flipKey.currentState?.toggleCard();
    });
  }
  Widget _avatar(ImageProvider image) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0F0F0F),
          ),
          child: ClipOval(
            child: Image(
              image: image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            /// Avatar
            FlipCard(
              key: _flipKey,
              speed: 500,
              direction: FlipDirection.HORIZONTAL,
              fill: Fill.fillBack,
              front: _avatar(
                const NetworkImage(
                  "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80",
                ),
              ),
              back: _avatar(
                const AssetImage("assets/images/Memo.jpg"),
              ),
            ),

            /// Verified Badge
            Positioned(
              bottom: 14,
              right: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF121212),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),

            /// Role Badge
            Positioned(
              bottom: -12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.35),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  "GDSC",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        const Text(
          "Alex Sterling",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "@alexsterling",
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 18),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            "Aspiring Software Engineer & UI Enthusiast.\nPassionate about building community-driven technology and creating meaningful experiences for students.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.5,
              height: 1.6,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.language_rounded,
              size: 17,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            const Text(
              "sterling.dev",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(.08),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.code_rounded,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                "LEAD DEVELOPER • GDSC",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------- Follow / Message buttons ----------
class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Message',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Custom tab bar ----------
class _CustomTabBar extends StatelessWidget {
  final TabController controller;
  const _CustomTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicatorColor: Colors.white,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.textMuted,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      tabs: const [
        Tab(
          icon: Icon(Icons.school_outlined, size: 20),
          text: 'ACADEMIC INFO',
          iconMargin: EdgeInsets.only(bottom: 6),
        ),
        Tab(
          icon: Icon(Icons.emoji_events_outlined, size: 20),
          text: 'PARTICIPATION',
          iconMargin: EdgeInsets.only(bottom: 6),
        ),
      ],
    );
  }
}

// ---------- Academic Info tab ----------
class AcademicInfoTab extends StatelessWidget {
  const AcademicInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: const [
            _InfoRow(label: 'FULL NAME', value: 'Alex Sterling'),
            _InfoDivider(),
            _InfoRow(label: 'ROLL NUMBER', value: '2100910100042'),
            _InfoDivider(),
            _InfoRow(
              label: 'BRANCH',
              value: 'Computer Science & Engineering',
            ),
            _InfoDivider(),
            _InfoRow(
              label: 'YEAR OF STUDY',
              value: '3rd Year, Class of 2025',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.divider);
}

// ---------- Participation tab ----------
class ParticipationTab extends StatelessWidget {
  const ParticipationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _participationData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _AchievementCard(entry: _participationData[index]);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final ParticipationEntry entry;
  const _AchievementCard({required this.entry});

  Color get _tierColor {
    switch (entry.tier) {
      case RankTier.gold:
        return AppColors.gold;
      case RankTier.silver:
        return AppColors.silver;
      case RankTier.bronze:
        return AppColors.bronze;
      case RankTier.participant:
        return AppColors.neutralRank;
    }
  }

  IconData get _tierIcon {
    switch (entry.tier) {
      case RankTier.gold:
      case RankTier.silver:
      case RankTier.bronze:
        return Icons.emoji_events;
      case RankTier.participant:
        return Icons.verified_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _tierColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medal badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.4), width: 1.4),
            ),
            child: Icon(_tierIcon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          // Event name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.eventName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 12.5, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      entry.date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Position pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              entry.position,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Bottom navigation ----------
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.home_outlined, color: Colors.white70, size: 24),
            const Icon(Icons.search, color: Colors.white70, size: 24),
            const Icon(Icons.add_circle_outline,
                color: Colors.white70, size: 24),
            const Icon(Icons.calendar_today_outlined,
                color: Colors.white70, size: 22),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline,
                  color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}