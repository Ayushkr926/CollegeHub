import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom Pull-To-Refresh widget displaying upside-down Stitch hanging from top edge.
class StitchPullToRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final String primaryAsset;
  final String fallbackAsset;

  const StitchPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.primaryAsset = 'assets/images/Stitch/loader.png',
    this.fallbackAsset = 'assets/images/Stitch/loader.jpg',
  });

  @override
  State<StitchPullToRefresh> createState() => _StitchPullToRefreshState();
}

class _StitchPullToRefreshState extends State<StitchPullToRefresh>
    with TickerProviderStateMixin {
  static const double _refreshThreshold = 100.0;
  static const double _maxDragHeight = 190.0;

  double _dragOffset = 0.0;
  bool _isRefreshing = false;
  bool _isDragging = false;

  late AnimationController _wiggleController;
  late AnimationController _springController;
  late Animation<double> _springAnimation;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _springAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    )..addListener(() {
        setState(() {
          _dragOffset = _springAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    _springController.dispose();
    super.dispose();
  }

  void _animateToOffset(double targetOffset, {VoidCallback? onComplete}) {
    _springAnimation = Tween<double>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutCubic),
    );

    _springController.reset();
    _springController.forward().then((_) {
      if (onComplete != null) onComplete();
    });
  }

  Future<void> _triggerRefresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
    });
    _wiggleController.repeat(reverse: true);
    _animateToOffset(_refreshThreshold);

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _wiggleController.stop();
        _wiggleController.reset();
        _animateToOffset(0.0, onComplete: () {
          if (mounted) {
            setState(() {
              _isRefreshing = false;
            });
          }
        });
      }
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is ScrollStartNotification) {
      if (notification.metrics.extentBefore == 0) {
        _isDragging = true;
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_isDragging && notification.metrics.extentBefore == 0) {
        final delta = notification.scrollDelta ?? 0;
        if (delta < 0 || _dragOffset > 0) {
          setState(() {
            _dragOffset = (_dragOffset - delta * 0.55).clamp(0.0, _maxDragHeight);
          });
        }
      }
    } else if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        setState(() {
          _dragOffset = (_dragOffset - notification.overscroll * 0.55)
              .clamp(0.0, _maxDragHeight);
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_isDragging) {
        _isDragging = false;
        if (_dragOffset >= _refreshThreshold) {
          _triggerRefresh();
        } else if (_dragOffset > 0) {
          _animateToOffset(0.0);
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final pullProgress = (_dragOffset / _refreshThreshold).clamp(0.0, 1.0);
    final isReadyToRelease = _dragOffset >= _refreshThreshold;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          // Main Body shifted down by drag offset during pull
          Transform.translate(
            offset: Offset(0, _dragOffset),
            child: widget.child,
          ),

          // Custom Stitch Overscroll Header at top
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _dragOffset,
              child: ClipRect(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0F172A).withOpacity(0.05),
                        const Color(0xFF1E293B).withOpacity(0.01),
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Top Hanging Wire / Line
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Upside-Down Stitch Image with physics & animation
                      AnimatedBuilder(
                        animation: _wiggleController,
                        builder: (context, child) {
                          final swingAngle = _isRefreshing
                              ? math.sin(_wiggleController.value * math.pi * 2) * 0.8
                              : math.sin(pullProgress * math.pi) * 0.03;
                          final bounceScale = _isRefreshing
                              ? 1.0 + math.sin(_wiggleController.value * math.pi * 2) * 0.04
                              : 0.7 + (pullProgress * 0.35);

                          return Positioned(
                            top: 0,
                            child: Transform.rotate(
                              angle: swingAngle,
                              child: Transform.scale(
                                scale: bounceScale,
                                alignment: Alignment.topCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Upside Down Stitch Image container
                                    Container(
                                      constraints: BoxConstraints(
                                        maxHeight: math.max(20, _dragOffset * 0.75),
                                        maxWidth: 300,
                                      ),
                                      child: Image.asset(
                                        widget.primaryAsset,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            widget.fallbackAsset,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.pets_rounded,
                                              size: 48,
                                              color: Color(0xFF3B82F6),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Refresh status badge pill
                                    if (_dragOffset > 35)
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 150),
                                        opacity: (_dragOffset / 50).clamp(0.0, 1.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.92),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF3B82F6).withOpacity(0.18),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_isRefreshing)
                                                const Padding(
                                                  padding: EdgeInsets.only(right: 6),
                                                  child: SizedBox(
                                                    width: 12,
                                                    height: 12,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        Color(0xFF2563EB),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              else
                                                Icon(
                                                  isReadyToRelease
                                                      ? Icons.keyboard_double_arrow_down_rounded
                                                      : Icons.arrow_downward_rounded,
                                                  size: 14,
                                                  color: const Color(0xFF2563EB),
                                                ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _isRefreshing
                                                    ? 'Refreshing notice feed...'
                                                    : isReadyToRelease
                                                        ? 'Release to refresh!'
                                                        : 'Pull to refresh',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E293B),
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
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
