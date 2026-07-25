import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The "Let's Start" pill button.
///
/// This widget is intentionally "dumb": it only reports raw gesture events
/// upward (via callbacks) and renders its own press feedback (scale +
/// shadow). All of the drag-progress math and sheet morphing lives in
/// `OnboardingScreen`, which keeps this widget simple, testable, and
/// reusable on its own.
class DraggableStartButton extends StatefulWidget {
  /// 0..1 drag/expansion progress — drives the label fade-out as the sheet
  /// takes over.
  final double progress;

  final VoidCallback onDragStart;

  /// Raw vertical delta in px for this frame (positive = finger moved down).
  final ValueChanged<double> onDragUpdate;

  /// Called on release with the finger's vertical velocity in px/s
  /// (negative = flicking upward), so the hand-off spring can feel natural.
  final ValueChanged<double> onDragEnd;

  const DraggableStartButton({
    super.key,
    required this.progress,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<DraggableStartButton> createState() => _DraggableStartButtonState();
}

class _DraggableStartButtonState extends State<DraggableStartButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _controller;
  late final Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(
      begin: 0,
      end: -12,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The label fades out a little faster than the sheet expands so the
    // text never looks cramped as the black shape grows around it.
    final labelOpacity = (1 - widget.progress * 2.2).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (_) {
        HapticFeedback.mediumImpact();
        setState(() => _pressed = true);
        widget.onDragStart();
      },
      onVerticalDragUpdate: (details) {
        widget.onDragUpdate(details.delta.dy);
      },
      onVerticalDragEnd: (details) {
        setState(() => _pressed = false);
        widget.onDragEnd(details.primaryVelocity ?? 0);
      },
      onVerticalDragCancel: () {
        setState(() => _pressed = false);
        widget.onDragEnd(0);
      },
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: widget.progress > 0.05 ? 0 : 1,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _arrowAnimation,
                builder: (_, __) {
                  return Transform.translate(
                    offset: Offset(0, _arrowAnimation.value),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 34,
                      color: Colors.black,
                    ),
                  );
                },
              ),

              const SizedBox(height: 2),
            ],
          ),
        ),

        AnimatedScale(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          scale: _pressed ? 1.06 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            width: 148,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.black38),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_pressed ? 0.45 : 0.22),
                  blurRadius: _pressed ? 24 : 12,
                  spreadRadius: _pressed ? 2 : 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Opacity(
              opacity: labelOpacity,
              child: const Text(
                "Let's Start",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
