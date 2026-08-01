import 'package:college/notice/screens/splashscreen_notice.dart';
import 'package:flutter/material.dart';

import '../BottomNav/animated_bottom_bar.dart';

/// ---------------------------------------------------------------------
/// Monochrome design tokens
/// Keeping every color in one place makes the black & white theme easy
/// to tune later without hunting through the widget tree.
/// ---------------------------------------------------------------------
class _Palette {
  static const bg = Colors.black;
  static const surface = Color(0xFF121212);
  static const surfaceElevated = Color(0xFF1A1A1A);
  static const border = Color(0x1FFFFFFF); // white @ 12%
  static const borderStrong = Color(0x33FFFFFF); // white @ 20%
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xB3FFFFFF); // white @ 70%
  static const textTertiary = Color(0x66FFFFFF); // white @ 40%
  static const chipDark = Color(0xE6000000); // black @ 90%
}

class HomeScreen extends StatefulWidget {
  final VoidCallback? onGetStarted;

  const HomeScreen({super.key, this.onGetStarted});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logo = _slice(0.00, 0.45);
  late final Animation<double> _title = _slice(0.15, 0.60);
  late final Animation<double> _subtitle = _slice(0.30, 0.75);
  late final Animation<double> _buttons = _slice(0.50, 1.00);

  Animation<double> _slice(double start, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _fadeSlide(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 24),
          child: child,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
              sliver: SliverToBoxAdapter(child: _header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 28, 10, 0),
              sliver: SliverToBoxAdapter(
                child: _sectionHeader("Popular Events"),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
              sliver: SliverToBoxAdapter(child: eventCard(context)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
              sliver: SliverToBoxAdapter(child: _pageDots()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 28, 10, 0),
              sliver: SliverToBoxAdapter(
                child: _sectionHeader("Ongoing Events"),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 124),
              sliver: SliverToBoxAdapter(child: upcomingEventCard(context)),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: const AnimatedBottomBar(selectedIndex: 0,),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

    );
  }

  /// Section title row shared by both event sections. A subtle
  /// arrow replaces the old plain "See all" text for a more
  /// deliberate, tappable feel.
  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _Palette.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "See all",
                  style: TextStyle(
                    color: _Palette.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 3),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 11, color: _Palette.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Minimal dot indicator, replacing the previous set of fading
  /// gradient bars — cleaner and reads instantly as a carousel cue.
  Widget _pageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = index == 0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: active ? 20 : 6,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  //header side
  Widget _header() {
    return Column(
      children: [
        /// Header Row
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FIND EVENTS IN",
                    style: TextStyle(
                      color: _Palette.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Your College",
                    style: TextStyle(
                      color: _Palette.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            _circleButton(Icons.chat_bubble_outline_rounded),
            const SizedBox(width: 10),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SplashScreen_notice(
                        heroAssetPath: "assets/images/Stitch/hey1.png",
                      ),
                    ),
                  );
                },
                child: _circleButton(Icons.notifications_none_rounded, dot: true)),
          ],
        ),

        const SizedBox(height: 22),

        /// Search Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: _Palette.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _Palette.border),
                ),
                child: const TextField(
                  style: TextStyle(color: _Palette.textPrimary, fontSize: 15),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 17),
                    hintText: "Search events, clubs, venues...",
                    hintStyle: TextStyle(
                      color: _Palette.textTertiary,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: _Palette.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.black,
                size: 22,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, {bool dot = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _Palette.surface,
        shape: BoxShape.circle,
        border: Border.all(color: _Palette.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: _Palette.textPrimary, size: 21),
          if (dot)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  //card widget
  Widget eventCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _Palette.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox(
        height: 360,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// Image
              Image.asset(
                "assets/images/onboarding.jpg",
                fit: BoxFit.cover,
              ),

              /// Scrim for legibility — pure black gradient keeps the
              /// monochrome palette intact instead of a tinted overlay.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black45,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87,
                    ],
                    stops: [0.0, 0.25, 0.55, 1.0],
                  ),
                ),
              ),

              /// Top Left — attendee pill
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _Palette.chipDark,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _Palette.border),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 58,
                        height: 24,
                        child: Stack(
                          children: [
                            Positioned(
                                left: 0,
                                child:
                                _avatar("assets/images/onboarding.jpg")),
                            Positioned(
                                left: 14,
                                child:
                                _avatar("assets/images/onboarding.jpg")),
                            Positioned(
                                left: 28,
                                child:
                                _avatar("assets/images/onboarding.jpg")),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "8 Going",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Bookmark
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _Palette.chipDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: _Palette.border),
                  ),
                  child: const Icon(
                    Icons.bookmark_border_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              /// Bottom info bar
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      // Date
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "16",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1,
                              ),
                            ),
                            Text(
                              "DEC",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Event Details
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Lunch Party",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.white60,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "ICCB, Dhaka, Bangladesh",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(String image) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  //all events
  Widget upcomingEventCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _Palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Row(
            children: [
              const Expanded(
                child: Text(
                  "College Fest 2026",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _Palette.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "FEST",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 15, color: _Palette.textSecondary),
              const SizedBox(width: 8),
              const Text(
                "17 May 2026",
                style: TextStyle(color: _Palette.textSecondary, fontSize: 13),
              ),
              const Spacer(),
              const Icon(Icons.access_time_rounded,
                  size: 15, color: _Palette.textSecondary),
              const SizedBox(width: 6),
              const Text(
                "10:00 AM",
                style: TextStyle(color: _Palette.textSecondary, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: _Palette.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Main Auditorium, NIET Greater Noida",
                  style:
                  TextStyle(color: _Palette.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: _Palette.border, height: 1),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _Palette.surfaceElevated,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: _Palette.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 58,
                      height: 24,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 0,
                              child: _avatar("assets/images/onboarding.jpg")),
                          Positioned(
                              left: 14,
                              child: _avatar("assets/images/onboarding.jpg")),
                          Positioned(
                              left: 28,
                              child: _avatar("assets/images/onboarding.jpg")),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "120 Going",
                      style: TextStyle(
                        color: _Palette.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Registration Open",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}