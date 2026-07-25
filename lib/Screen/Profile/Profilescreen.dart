import 'package:college/BottomNav/animated_bottom_bar.dart';
import 'package:flutter/material.dart';

import '../../utils/topnotchclipper.dart';



class ClubProfileScreen extends StatelessWidget {
  const ClubProfileScreen({super.key});

  static const bg = Color(0xFF0E0E0E);
  static const card = Color(0xFF1A1A1A);
  static const subtitle = Color(0xFFA0A0A0);
  static const accentRed = Color(0xFFE94B4B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar(context)),
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverToBoxAdapter(child: Divider(),),
            SliverToBoxAdapter(child: _buildStats()),
            SliverToBoxAdapter(child: Divider(),),
            SliverToBoxAdapter(child: _buildBio()),
            SliverToBoxAdapter(child: _buildActionButtons(context)),
            // SliverToBoxAdapter(child: _buildHighlights()),
            // SliverToBoxAdapter(child: _buildTabIcons()),
            // SliverToBoxAdapter(child: _buildImageGrid()),
            SliverToBoxAdapter(child: _buildUpcomingEvents()),
            SliverToBoxAdapter(child: _buildClubCore()),
            const SliverToBoxAdapter(child: SizedBox(height: 124)),
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
              'CampusElite',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.white, size: 20),
            onPressed: () {},
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
  Widget _buildProfileHeader() {
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
          child: const CircleAvatar(
            backgroundColor: Color(0xFF2A2A2A),
            child: Icon(Icons.school, color: Colors.white70, size: 36),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Google Developer Students Club',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '@GDSC_NIET',
              style: TextStyle(color: subtitle, fontSize: 13),
            ),
            SizedBox(width: 6),
            Icon(Icons.verified, color: Color(0xFF4FA8FF), size: 16),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Innovate • Build • Learn',
          style: TextStyle(
            color: subtitle,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  //join club showfield


  void showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            /// Sheet
            ClipPath(
              clipper: TopNotchClipper(),
              child:Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  /// Sheet
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
                            /// Avatar + success badge
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
                                      child: const CircleAvatar(
                                        backgroundColor: Color(0xFF2A2A2A),
                                        child: Icon(
                                          Icons.school,
                                          color: Colors.white70,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                    // Animated success badge
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: 1),
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.elasticOut,
                                        builder: (context, value, child) => Transform.scale(
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
                                const Text(
                                  'Google Developer Students Club',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      '@GDSC_NIET',
                                      style: TextStyle(color: subtitle, fontSize: 13),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.verified, color: Color(0xFF4FA8FF), size: 16),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Innovate • Build • Learn',
                                  style: TextStyle(
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
                                onPressed: () {
                                  Navigator.pop(context);
                                },
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

                  /// Floating Close Button
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),

            /// Floating Close Button
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- Stats row ----------
  Widget _buildStats() {
    Widget stat(String value, String label) => Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              value,
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
          stat('48', 'EVENTS'),
          stat('1.2K', 'MEMBERS'),
          stat('8.5K', 'FOLLOWERS'),
        ],
      ),
    );
  }

  // ---------- Bio ----------
  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Official Technical Club of NIET. Organizing Hackathons, '
                'Workshops, Coding Contests, and Networking Events for '
                'aspiring developers.',
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4,fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          _iconLine(Icons.location_on_outlined, 'NIET, Greater Noida'),
          const SizedBox(height: 4),
          _iconLine(Icons.language, 'gdsc.niet.io'),
          const SizedBox(height: 4),
          _iconLine(Icons.email_outlined, 'gdsc@niet.edu.in'),
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
        Text(text, style: const TextStyle(color: subtitle, fontSize: 13,fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ---------- Buttons ----------
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Follow',
                  style: TextStyle(fontWeight: FontWeight.w600)),
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
              onPressed: () {
                showSuccessSheet(context);
              },
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

  // ---------- Highlights (story circles) ----------
  Widget _buildHighlights() {
    final items = [
      ('Hackathons', Icons.emoji_events_outlined),
      ('Workshops', Icons.build_outlined),
      ('Fest', Icons.celebration_outlined),
      ('Achievements', Icons.military_tech_outlined),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                  color: const Color(0xFF1E1E1E),
                ),
                child: Icon(item.$2, color: Colors.white70, size: 24),
              ),
              const SizedBox(height: 6),
              Text(item.$1,
                  style: const TextStyle(color: subtitle, fontSize: 11)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ---------- Tab icon row ----------
  Widget _buildTabIcons() {
    final icons = [
      Icons.grid_view_rounded,
      Icons.calendar_today_outlined,
      Icons.play_circle_outline,
      Icons.bookmark_border,
      Icons.emoji_events_outlined,
    ];
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A)),
          bottom: BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: icons.asMap().entries.map((e) {
          final selected = e.key == 0;
          return Icon(
            e.value,
            color: selected ? Colors.white : subtitle,
            size: 22,
          );
        }).toList(),
      ),
    );
  }

  // ---------- Image grid ----------
  Widget _buildImageGrid() {
    final colors = [
      const Color(0xFF3A3A3A),
      const Color(0xFF264653),
      const Color(0xFF1F1F1F),
      const Color(0xFF2C2C2C),
      const Color(0xFF14213D),
      const Color(0xFF1B1B1B),
    ];
    final icons = [
      Icons.people_outline,
      Icons.memory,
      Icons.movie_creation_outlined,
      Icons.groups_outlined,
      Icons.laptop_mac,
      Icons.mic_none,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          return Container(
            color: colors[index],
            child: Icon(icons[index], color: Colors.white38, size: 26),
          );
        },
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Flutter Hackathon',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '9:00 AM • Auditorium',
                        style: TextStyle(color: subtitle, fontSize: 12),
                      ),
                      const SizedBox(height: 3),
                      const Text(
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
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
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF2E2E2E),
                        child: const Icon(Icons.person,
                            color: Colors.white54, size: 20),
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