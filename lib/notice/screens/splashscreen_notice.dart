import 'dart:async';
import 'package:college/Screen/Auth/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../Notices/HomeScreen/provider/home_provider.dart';
import '../../Notices/homescreen/homescreen.dart';
import 'notice_list_screen.dart';



class SplashScreen_notice extends StatefulWidget {
  const SplashScreen_notice({
    super.key,
    required this.heroAssetPath,
    this.onReady,
    this.appName = 'CollegeHub',
    this.tagline = 'Official. Verified. Always on time.',
    this.backgroundColor = const Color(0xFFC8E1FF),
  });

  /// Path to the provided Stitch artwork asset.
  final String heroAssetPath;



  /// Optional async work to run during the splash window
  /// (token validation, config fetch, feature flags, feed prefetch).
  final Future<void> Function()? onReady;

  final String appName;
  final String tagline;
  final Color backgroundColor;

  @override
  State<SplashScreen_notice> createState() => _SplashScreen_noticeState();
}

class _SplashScreen_noticeState extends State<SplashScreen_notice>
    with TickerProviderStateMixin {
  static const _minDisplay = Duration(milliseconds: 2200); // was 800
  static const _maxDisplay = Duration(milliseconds: 3500); // was 2800
  static const _loaderDelay = Duration(milliseconds: 300);
  static const _entryDuration = Duration(milliseconds: 800);
  static const _exitDuration = Duration(milliseconds: 450);

  late final AnimationController _entryController;
  late final Animation<double> _imageScale;
  late final Animation<double> _imageFloat;
  late final Animation<double> _imageOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  late final AnimationController _exitController;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitOpacity;

  bool _showLoader = false;
  bool _readyToExit = false;
  bool _errorState = false;
  Timer? _loaderTimer;
  Timer? _maxTimer;

  bool get _reducedMotion =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
          .disableAnimations;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: _entryDuration,
    );

    _imageScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _imageFloat = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: _exitDuration,
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _entryController.forward();

    // Loader only appears if the launch is not fast (>300ms).
    _loaderTimer = Timer(_loaderDelay, () {
      if (mounted && !_readyToExit) {
        setState(() => _showLoader = true);
      }
    });

    // Hard cap so a first launch never hangs on the splash forever.
    _maxTimer = Timer(_maxDisplay, () {
      if (mounted && !_readyToExit) {
        setState(() => _errorState = true);
      }
    });

    _runLaunchSequence();
  }

  Future<void> _runLaunchSequence() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Real async work: auth check, config fetch, feature flags, prefetch.
      await widget.onReady?.call();
    } catch (_) {
      if (mounted) setState(() => _errorState = true);
      // Soft retry after 2s, matching the "Error (rare)" state.
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _errorState = false);
    }

    final elapsed = stopwatch.elapsed;
    if (elapsed < _minDisplay) {
      await Future.delayed(_minDisplay - elapsed);
    }

    if (!mounted) return;
    _loaderTimer?.cancel();
    _maxTimer?.cancel();
    await _exitAndNavigate();
  }

  Future<void> _exitAndNavigate() async {
    setState(() => _readyToExit = true);

    if (!_reducedMotion) {
      await _exitController.forward();
    }

    if (!mounted) return;
   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NoticeListScreen(
     canManageNotices: true || false,
   ),));
  }

  @override
  void dispose() {
    _loaderTimer?.cancel();
    _maxTimer?.cancel();
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTabletOrWider = size.shortestSide >= 600;
    final heroWidthFactor = isTabletOrWider ? 0.42 : 0.72;
    final maxHeroWidth = isTabletOrWider ? 420.0 : 340.0;

    return Semantics(
      label: '${widget.appName}, loading',
      liveRegion: true,
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        body: AnimatedBuilder(
          animation: Listenable.merge([_entryController, _exitController]),
          builder: (context, child) {
            return Opacity(
              opacity: _reducedMotion ? 1.0 : _exitOpacity.value,
              child: Transform.scale(
                scale: _reducedMotion ? 1.0 : _exitScale.value,
                child: child,
              ),
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  Color.lerp(widget.backgroundColor, Colors.black87, 0.04)!,
                  widget.backgroundColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 5),

                    // ---- Hero image -------------------------------------
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxHeroWidth),
                      child: FractionallySizedBox(
                        widthFactor: heroWidthFactor,
                        child: AnimatedBuilder(
                          animation: _entryController,
                          builder: (context, child) {
                            final scale =
                            _reducedMotion ? 1.0 : _imageScale.value;
                            final floatOffset =
                            _reducedMotion ? 0.0 : _imageFloat.value;
                            return Opacity(
                              opacity: _reducedMotion
                                  ? 1.0
                                  : _imageOpacity.value,
                              child: Transform.translate(
                                offset: Offset(0, floatOffset),
                                child: Transform.scale(
                                  scale: scale,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffC8E1FF).withOpacity(0.35),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.06),
                                  blurRadius: 60,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Semantics(
                              image: true,
                              label:
                              'Stitch character bursting through paper',
                              child: ExcludeSemantics(
                                child: Image.asset(
                                  widget.heroAssetPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) {
                                    // Fallback placeholder if asset missing.
                                    return AspectRatio(
                                      aspectRatio: 1,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withOpacity(0.05),
                                          borderRadius:
                                          BorderRadius.circular(24),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_outlined,
                                            color: Colors.white24,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ---- App name + tagline ------------------------------
                    SlideTransition(
                      position: _reducedMotion
                          ? const AlwaysStoppedAnimation(Offset.zero)
                          : _textSlide,
                      child: FadeTransition(
                        opacity: _reducedMotion
                            ? const AlwaysStoppedAnimation(1.0)
                            : _textOpacity,
                        child: Column(
                          children: [
                            Text(
                              widget.appName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xff111827),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.tagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xff6B7280).withOpacity(0.72),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // ---- Loader / error state ---------------------------
                    SizedBox(
                      height: 56,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _errorState
                              ? const _RetryMessage(key: ValueKey('error'))
                              : (_showLoader
                              ? const _MinimalLoader(
                              key: ValueKey('loader'))
                              : const SizedBox.shrink(
                              key: ValueKey('empty'))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three soft pulsing dots — calm, non-aggressive loading indicator.
class _MinimalLoader extends StatefulWidget {
  const _MinimalLoader({super.key});

  @override
  State<_MinimalLoader> createState() => _MinimalLoaderState();
}

class _MinimalLoaderState extends State<_MinimalLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    if (reducedMotion) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => _dot(0.4)),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value - (i * 0.2)) % 1.0;
            final opacity = 0.25 + 0.55 * (0.5 - (t - 0.5).abs()) * 2;
            return _dot(opacity.clamp(0.25, 0.8));
          }),
        );
      },
    );
  }

  Widget _dot(double opacity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF6B7280),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Starting…',
      style: TextStyle(
        color: Color(0xff111827).withOpacity(0.6),
        fontSize: 13,
      ),
    );
  }
}