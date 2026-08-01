import 'package:college/BottomNav/animated_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/profile_provider_student.dart';
import '../../utils/topnotchclipper.dart';
import 'completeprofile.dart';
import 'edit_club_profile_screen.dart';
class ClubProfileScreen extends StatefulWidget {
  const ClubProfileScreen({super.key});

  @override
  State<ClubProfileScreen> createState() => _ClubProfileScreenState();
}

class _ClubProfileScreenState extends State<ClubProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;


  static const bg = Color(0xFF0E0E0E);
  static const card = Color(0xFF1A1A1A);
  static const subtitle = Color(0xFFA0A0A0);
  static const accentRed = Color(0xFFE94B4B);

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
    return context.read<ProfileProvider>().refreshProfile(isoragiser: true);
  }
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopBar(context)),
              // Fixed: pass ProfileProvider, not Provider
              SliverToBoxAdapter(child: _buildProfileHeader(profile)),
              SliverToBoxAdapter(child: CompactProfileCompletion(),),
              const SliverToBoxAdapter(child: Divider(color: Color(0xFF2A2A2A))),
              SliverToBoxAdapter(child: _buildStats(profile)),
              const SliverToBoxAdapter(child: Divider(color: Color(0xFF2A2A2A))),
              SliverToBoxAdapter(child: _buildBio(profile)),
              SliverToBoxAdapter(child: _buildActionButtons(context, profile)),
              SliverToBoxAdapter(child: _buildUpcomingEvents()),
              SliverToBoxAdapter(child: _buildClubCore()),
              const SliverToBoxAdapter(child: SizedBox(height: 124)),
            ],
          ),
        ),
      ),
      floatingActionButton: const Padding(
        padding: EdgeInsets.all(8.0),
        child: AnimatedBottomBar(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


  // ---------- Top bar ----------
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
          const Expanded(
            child: Text(
              'CampusHub',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditClubProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ---------- Avatar / name ----------
  Widget _buildProfileHeader(ProfileProvider profile) {
    final displayName = profile.clubName.isNotEmpty
        ? profile.clubName
        : (profile.fullName.isNotEmpty ? profile.fullName : 'Club');
    final handle = profile.username.isNotEmpty ? profile.username : '@club';
    final tagline = profile.bio.isNotEmpty ? profile.bio : 'Innovate • Build • Learn';

    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
          ),
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF2A2A2A),
            backgroundImage: profile.avatarUrl.isNotEmpty
                ? NetworkImage(profile.avatarUrl)
                : null,
            child: profile.avatarUrl.isEmpty
                ? const Icon(Icons.school, color: Colors.white70, size: 36)
                : null,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              handle,
              style: const TextStyle(color: subtitle, fontSize: 13),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.verified, color: Color(0xFF4FA8FF), size: 16),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: subtitle,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ---------- Join-club success sheet ----------
  void showSuccessSheet(BuildContext context, ProfileProvider profile) {
    final displayName = profile.clubName.isNotEmpty
        ? profile.clubName
        : (profile.fullName.isNotEmpty ? profile.fullName : 'Club');
    final handle = profile.username.isNotEmpty ? profile.username : '@club';
    final tagline = profile.bio.isNotEmpty ? profile.bio : 'Innovate • Build • Learn';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            ClipPath(
              clipper: TopNotchClipper(),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.94, end: 1.0),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.fromLTRB(24, 45, 24, 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 30,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 92,
                                      height: 92,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black12,
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: CircleAvatar(
                                        backgroundColor: const Color(0xFF2A2A2A),
                                        backgroundImage:
                                        profile.avatarUrl.isNotEmpty
                                            ? NetworkImage(profile.avatarUrl)
                                            : null,
                                        child: profile.avatarUrl.isEmpty
                                            ? const Icon(
                                          Icons.school,
                                          color: Colors.white70,
                                          size: 36,
                                        )
                                            : null,
                                      ),
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: 1),
                                        duration:
                                        const Duration(milliseconds: 400),
                                        curve: Curves.elasticOut,
                                        builder: (context, value, child) =>
                                            Transform.scale(
                                              scale: value,
                                              child: child,
                                            ),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF34C759),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  displayName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      handle,
                                      style: const TextStyle(
                                        color: subtitle,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.verified,
                                      color: Color(0xFF4FA8FF),
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tagline,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: subtitle,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Request Sent!',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Your request to join this club has been sent.\nYou\'ll be notified once it\'s approved.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: subtitle,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Got it',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(30),
                        child: Ink(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Duplicate close button removed — one is enough
          ],
        );
      },
    );
  }

  // ---------- Stats row ----------
  Widget _buildStats(ProfileProvider profile) {
    Widget stat(int value, String label) => Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "${value}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: subtitle, fontSize: 12),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          stat(profile.events, 'EVENTS'),
          stat(profile.members , 'MEMBERS'),
          stat(profile.followers , 'FOLLOWERS'),
        ],
      ),
    );
  }

  // ---------- Bio ----------
  Widget _buildBio(ProfileProvider profile) {
    final description = profile.clubDescription.isNotEmpty
        ? profile.clubDescription
        : (profile.bio.isNotEmpty
        ? profile.bio
        : 'Official Technical Club. Organizing Hackathons, Workshops, Coding Contests, and Networking Events.');

    final website = profile.website.isNotEmpty ? profile.website : '—';
    final email = profile.email.isNotEmpty ? profile.email : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _iconLine(Icons.location_on_outlined, 'NIET'),
          const SizedBox(height: 4),
          _iconLine(Icons.language, website),
          const SizedBox(height: 4),
          _iconLine(Icons.email_outlined, email),
        ],
      ),
    );
  }

  Widget _iconLine(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: subtitle),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: subtitle,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ---------- Buttons ----------
  Widget _buildActionButtons(BuildContext context, ProfileProvider profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Optional: profile.toggleFollow();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                profile.isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Message'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => showSuccessSheet(context, profile),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Join Club'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Upcoming events ----------
  Widget _buildUpcomingEvents() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text('View All', style: TextStyle(color: subtitle, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '12',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'SEPT',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: subtitle, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flutter Hackathon',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '9:00 AM • Auditorium',
                        style: TextStyle(color: subtitle, fontSize: 12),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '120 Seats Left',
                        style: TextStyle(
                          color: accentRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Club core ----------
  Widget _buildClubCore() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Club Core',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text('See All', style: TextStyle(color: subtitle, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: Stack(
              children: [
                for (int i = 0; i < 3; i++)
                  Positioned(
                    left: i * 30.0,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: bg,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF2E2E2E),
                        child: Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 3 * 30.0,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: bg,
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF3A3A3A),
                      child: Text(
                        '+12',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'President, VP, and 12 core team members',
            style: TextStyle(color: subtitle, fontSize: 12),
          ),
        ],
      ),
    );
  }
}