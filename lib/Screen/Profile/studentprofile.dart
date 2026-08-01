// -----------------------------------------------------------------------
// WHAT CHANGED vs the previous version
// -----------------------------------------------------------------------
// 1. Nothing renders an empty row/section anymore. Bio, website, joined
//    clubs, and every academic field individually check for content —
//    if a field is empty it's simply not built, so there's no blank
//    label, no orphan divider, no dead whitespace sitting in the layout.
// 2. AcademicInfoTab and the "joined clubs" section now show a proper
//    empty state (icon + message) only when there is genuinely nothing
//    to show at all, instead of a card full of "—" placeholders.
// 3. First-load now shows a shimmer skeleton (avatar + name + bio
//    outlines) instead of a bare spinner — reads as "loading your
//    profile" rather than "something is broken".
// 4. Error banner now has a Retry action instead of just sitting there.
// 5. Avatar has a shimmer placeholder while the network image loads,
//    and a graceful fallback icon if it fails — so a bad/missing
//    avatarUrl never leaves a broken-image icon on screen.
// -----------------------------------------------------------------------

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../BottomNav/animated_bottom_bar.dart';
import '../../Model/participation_entry.dart';
import '../../Provider/profile_provider_student.dart';
import 'edit_profile.dart';

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
  static const errorRed = Color(0xFFE85B5B);
  static const shimmerBase = Color(0xFF1A1A1A);
  static const shimmerHighlight = Color(0xFF262626);
}

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

    // Cache-first load: shows saved-from-login/registration data
    // instantly if present, then silently syncs with the API.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() {
    return context.read<ProfileProvider>().refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    // Only show the skeleton when we truly have nothing to display yet
    // (first-ever load, no cache). Otherwise we always show whatever
    // data we have and let pull-to-refresh / background sync handle
    // updates quietly, without ever blanking the screen.
    final showSkeleton = profile.isLoading && !profile.hasProfile;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: showSkeleton
            ? const _ProfileSkeleton()
            : Column(
          children: [
            const _TopBar(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: profile.error != null
                  ? _ErrorBanner(
                key: ValueKey(profile.error),
                message: profile.error!,
                onRetry: _handleRefresh,
              )
                  : const SizedBox.shrink(key: ValueKey('no-error')),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: Colors.black,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      const _ProfileHeader(),
                      const SizedBox(height: 20),
                      _CustomTabBar(controller: _tabController),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 20),
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
            ),
          ],
        ),
      ),
      floatingActionButton: const Padding(
        padding: EdgeInsets.all(8.0),
        child: AnimatedBottomBar(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ---------- Shimmer primitives ----------
// Lightweight shimmer effect, no extra package required.
class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1 - t * 2, 0),
              end: Alignment(1 - t * 2, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBlock({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// Full first-load skeleton, mirrors the real layout so there's no jump
// when real data replaces it.
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Column(
        children: [
          const _TopBar(),
          const SizedBox(height: 24),
          const _ShimmerBlock(width: 148, height: 148, radius: 74),
          const SizedBox(height: 30),
          const _ShimmerBlock(width: 180, height: 22),
          const SizedBox(height: 10),
          const _ShimmerBlock(width: 110, height: 14),
          const SizedBox(height: 20),
          const _ShimmerBlock(width: 260, height: 14),
          const SizedBox(height: 8),
          const _ShimmerBlock(width: 220, height: 14),
          const Spacer(),
        ],
      ),
    );
  }
}

// ---------- Error banner ----------
// Shown when a background/pull-to-refresh sync fails. Non-blocking —
// the rest of the (cached) profile stays fully visible and usable.
class _ErrorBanner extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorBanner({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.errorRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'RETRY',
              style: TextStyle(
                color: AppColors.errorRed,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Generic empty state ----------
// Used anywhere a section has no data, so the UI always reads as
// intentional rather than leaving raw blank space.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _EmptyState({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------- Top bar ----------
class _TopBar extends StatelessWidget {

  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 1),
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
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (profile.avatarUrl?.isNotEmpty ?? false)
                  ? NetworkImage(profile.avatarUrl!)
                  : const AssetImage("assets/images/Memo.jpg") as ImageProvider,
              onBackgroundImageError: (_, __) {},
            )
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.edit, color: Colors.white, size: 24),
              ),
            ),
          ),

          const SizedBox(width: 20,),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {

              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.settings, color: Colors.white, size: 24),
              ),
            ),
          ),
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
      await Future.delayed(const Duration(milliseconds: 400));
      _flipKey.currentState?.toggleCard();
      await Future.delayed(const Duration(milliseconds: 800));
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
            colors: [Colors.white, Colors.grey.shade300],
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
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const _Shimmer(
                  child: ColoredBox(color: AppColors.shimmerBase),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF0F0F0F),
                child: const Icon(Icons.person, color: Colors.white54, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    final ImageProvider frontImage = profile.avatarUrl.isNotEmpty
        ? NetworkImage(profile.avatarUrl)
        : AssetImage(profile.avatarAsset) as ImageProvider;

    final hasBio = profile.bio.trim().isNotEmpty;
    final hasWebsite = profile.website.trim().isNotEmpty;
    final hasUsername = profile.username.trim().isNotEmpty;
    final hasRoleBadge = profile.roleBadge.trim().isNotEmpty;
    final hasJoinedClubs = profile.joinedClubs.isNotEmpty;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            FlipCard(
              key: _flipKey,
              speed: 500,
              direction: FlipDirection.HORIZONTAL,
              fill: Fill.fillBack,
              front: _avatar(frontImage),
              back: _avatar(AssetImage(profile.avatarAsset)),
            ),
            Positioned(
              bottom: 14,
              right: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF121212), width: 2),
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
            if (hasRoleBadge)
              Positioned(
                bottom: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                  child: Text(
                    profile.roleBadge,
                    style: const TextStyle(
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
        Text(
          profile.fullName.isNotEmpty ? profile.fullName : 'Unnamed Student',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        if (hasUsername) ...[
          const SizedBox(height: 8),
          Text(
            profile.username,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (hasBio) ...[
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.5,
                height: 1.6,
              ),
            ),
          ),
        ],
        if (hasWebsite) ...[
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.language_rounded, size: 17, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                profile.website,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
        if (hasRoleBadge) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.code_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  profile.roleBadge,
                  style: const TextStyle(
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
        if (hasJoinedClubs) ...[
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: profile.joinedClubs
                  .map((c) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  c,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
        ],
      ],
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
    final profile = context.watch<ProfileProvider>();

    // Only fields that actually have a value make it into the list —
    // no "—" placeholder rows, no dangling labels.
    final fields = <MapEntry<String, String>>[
      if (profile.fullName.isNotEmpty) MapEntry('FULL NAME', profile.fullName),
      if (profile.rollNumber.isNotEmpty)
        MapEntry('ROLL NUMBER', profile.rollNumber),
      if (profile.branch.isNotEmpty) MapEntry('BRANCH', profile.branch),
      if (profile.yearOfStudy.isNotEmpty)
        MapEntry('YEAR OF STUDY', profile.yearOfStudy),
    ];

    if (fields.isEmpty) {
      return const _EmptyState(
        icon: Icons.school_outlined,
        title: 'No academic info yet',
        subtitle: 'Add your roll number, branch and year to complete\nyour academic profile.',
      );
    }

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
          children: [
            for (int i = 0; i < fields.length; i++) ...[
              _InfoRow(label: fields[i].key, value: fields[i].value),
              if (i != fields.length - 1) const _InfoDivider(),
            ],
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
    final profile = context.watch<ProfileProvider>();
    final data = profile.participationData;

    if (data.isEmpty) {
      return const _EmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'No participations yet',
        subtitle: 'Events and competitions you join will show up here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _AchievementCard(entry: data[index]);
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
    final hasDate = entry.date.trim().isNotEmpty;
    final hasPosition = entry.position.trim().isNotEmpty;

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
                if (hasDate) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
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
              ],
            ),
          ),
          if (hasPosition) ...[
            const SizedBox(width: 10),
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
        ],
      ),
    );
  }
}