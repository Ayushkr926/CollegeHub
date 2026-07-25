import 'dart:async';
import 'dart:ui';

import 'package:college/Screen/Auth/welcome_screen.dart';
import 'package:flutter/material.dart';

import '../animation/spring_animation.dart';
import 'morphing_black_sheet.dart';
import 'HomeScreen.dart';
import 'onboarding_content.dart';

/// Top-level onboarding screen.
///
/// This widget owns a single source of truth — [_progress] (0..1) — that
/// every other piece of UI (background image, white card, black sheet,
/// button label) reads from. Driving everything off one controller is what
/// keeps the whole interaction perfectly synchronized, whether it's being
/// pushed by a live finger drag or eased by a spring simulation.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  /// Below this, a release springs back to the resting state. At/above it,
  /// the release commits to a fullscreen expansion. (This single threshold
  /// also satisfies "exceeds 90% → fullscreen": that's simply a point well
  /// past the commit line.)
  static const double _commitThreshold = 0.45;

  bool _revealNextScreen = false;



  final List<Map<String, String>> onboardingPages = [
    {
      "title": "Your Campus. One Place.\nEvery Update.",
      "subtitle":
      "Stay updated with college notices, events, deadlines, and announcements—all in one place.",
    },
    {
      "title": "Discover Campus Events",
      "subtitle":
      "Explore workshops, hackathons, seminars, fests, and club activities happening around your campus.",
    },
    {
      "title": "Never Miss an Opportunity",
      "subtitle":
      "Receive timely notifications for important announcements, registrations, and upcoming deadlines.",
    },
  ];

  final PageController _pageController = PageController();
  int currentPage = 0;


  Timer? _timer;



  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;

      final next = (currentPage + 1) % onboardingPages.length;

      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    _progress = AnimationController(
      vsync: this,
      value: 0.0,
      duration: const Duration(milliseconds: 400), // fallback duration only
    )..addListener(_handleProgressChanged);
  }

  void _handleProgressChanged() {
    // Spring simulations settle *near* their target once they're within
    // tolerance, not always at an exact 1.0 — so a small epsilon is used
    // instead of a strict equality check.
    final atFull = _progress.value >= 0.995;
    if (atFull != _revealNextScreen) {
      setState(() => _revealNextScreen = atFull);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.removeListener(_handleProgressChanged);
    _progress.dispose();
    super.dispose();
  }

  /// How many logical pixels of upward drag equal 100% progress. Tuned so a
  /// natural ~42% of screen height feels like a full, deliberate swipe.
  double _dragRange(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.42;

  void _onDragStart() {

    _progress.stop();
  }

  void _onDragUpdate(double deltaY) {
    // Dragging up => negative dy => progress increases. 1:1 with the
    // finger: no smoothing, no easing applied to live drag input.
    final delta = -deltaY / _dragRange(context);
    _progress.value = (_progress.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(double velocityPxPerSec) {
    final commit = _progress.value >= _commitThreshold;
    final target = commit ? 1.0 : 0.0;
    final description = commit ? AppSprings.expand : AppSprings.snapBack;

    // Convert the raw finger velocity into "progress units per second" so
    // the spring inherits the gesture's momentum instead of starting cold.
    final normalizedVelocity = -velocityPxPerSec / _dragRange(context);

    _progress.animateWith(
      AppSprings.build(
        controller: _progress,
        description: description,
        target: target,
        velocity: normalizedVelocity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.65;
    final cardTop = imageHeight - 40; // white card overlaps the image
    const sheetCollapsedHeight = 48.0;
    final sheetCollapsedTop = size.height - sheetCollapsedHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) {
          final p = _progress.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              _buildBackgroundImage(imageHeight, p),
              _buildWhiteCard(cardTop, p),
              MorphingBlackSheet(
                progress: p,
                collapsedTop: sheetCollapsedTop,
                buttonBottomInset: 18,
                onDragStart: _onDragStart,
                onDragUpdate: _onDragUpdate,
                onDragEnd: _onDragEnd,
              ),
              if (_revealNextScreen) const WelcomeScreen(),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Background portrait image — zooms, blurs, and fades as p increases.
  // ---------------------------------------------------------------------
  Widget _buildBackgroundImage(double imageHeight, double p) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: imageHeight,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Opacity(
          opacity: (1 - p * 1.1).clamp(0.0, 1.0),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: p * 10, sigmaY: p * 10),
            child: Transform.scale(
              scale: 1.0 + (p * 0.08),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/onboarding.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.orange.shade100, Colors.brown.shade200],
                        ),
                      ),
                    ),
                  ),
                  // Smooth fade at the bottom edge into the white card.
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white.withOpacity(0), Colors.white],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // White bottom card — slides down and fades out as p increases.
  // ---------------------------------------------------------------------
  Widget _buildWhiteCard(double cardTop, double p) {
    return Positioned(
      top: cardTop,
      left: 0,
      right: 0,
      bottom: 0,
      child: Transform.translate(
        offset: Offset(0, p * 30),
        child: Opacity(
          opacity: (1 - p * 1.3).clamp(0.0, 1.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(44),
                topRight: Radius.circular(44),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 24,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: onboardingPages.length,
              itemBuilder: (context, index) {
                return OnboardingContent(
                  progress: p,
                  currentPage: currentPage,
                  totalPages: onboardingPages.length,
                  title: onboardingPages[index]["title"]!,
                  subtitle: onboardingPages[index]["subtitle"]!,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
