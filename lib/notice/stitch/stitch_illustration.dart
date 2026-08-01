import 'package:college/notice/stitch/stitch_token.dart';
import 'package:flutter/material.dart';

/// Renders one of the Stitch character illustrations, with a graceful
/// vector fallback so the screen never ships a broken-image icon if an
/// asset is missing at build time (e.g. before assets are wired into
/// pubspec.yaml).
class StitchIllustration extends StatelessWidget {
  final String assetPath;
  final double size;
  final _StitchFallback fallback;

  const StitchIllustration({
    super.key,
    required this.assetPath,
    required this.size,
    this.fallback = _StitchFallback.face,
  });

  const StitchIllustration.happy({super.key, this.size = 120})
      : assetPath = StitchAssets.happy,
        fallback = _StitchFallback.happy;

  const StitchIllustration.peek({super.key, this.size = 120})
      : assetPath = StitchAssets.peek,
        fallback = _StitchFallback.peek;

  const StitchIllustration.sorry({super.key, this.size = 120})
      : assetPath = StitchAssets.sorry,
        fallback = _StitchFallback.sorry;

  const StitchIllustration.upsideDown({super.key, this.size = 64})
      : assetPath = StitchAssets.upsideDown,
        fallback = _StitchFallback.face;

  const StitchIllustration.redCard({super.key, this.size = 96})
      : assetPath = StitchAssets.redCard,
        fallback = _StitchFallback.redCard;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _VectorFallback(
          size: size,
          kind: fallback,
        ),
      ),
    );
  }
}

enum _StitchFallback { happy, peek, sorry, redCard, face }

/// A small hand-drawn-style vector Stitch face so the UI still feels
/// on-theme even before the real character assets are bundled.
class _VectorFallback extends StatelessWidget {
  final double size;
  final _StitchFallback kind;

  const _VectorFallback({required this.size, required this.kind});

  @override
  Widget build(BuildContext context) {
    final accent = switch (kind) {
      _StitchFallback.sorry => StitchColors.textMuted,
      _StitchFallback.redCard => StitchColors.danger,
      _ => StitchColors.furCore,
    };

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StitchFacePainter(mood: kind, accent: accent),
      ),
    );
  }
}

class _StitchFacePainter extends CustomPainter {
  final _StitchFallback mood;
  final Color accent;
  _StitchFacePainter({required this.mood, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final center = Offset(w / 2, h * 0.55);
    final headRadius = w * 0.32;

    final furPaint = Paint()..color = StitchColors.furCore;
    final earPaint = Paint()..color = StitchColors.earPink;
    final inkPaint = Paint()..color = StitchColors.noseInk;

    // Ears
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - headRadius * 0.9, center.dy - headRadius * 0.7), width: w * 0.22, height: h * 0.42),
      furPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + headRadius * 0.9, center.dy - headRadius * 0.7), width: w * 0.22, height: h * 0.42),
      furPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - headRadius * 0.9, center.dy - headRadius * 0.7), width: w * 0.1, height: h * 0.24),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + headRadius * 0.9, center.dy - headRadius * 0.7), width: w * 0.1, height: h * 0.24),
      earPaint,
    );

    // Head
    canvas.drawCircle(center, headRadius, furPaint);

    // Eyes
    final eyeOffset = headRadius * 0.42;
    final eyeY = center.dy - headRadius * 0.08;
    final eyeRadius = headRadius * (mood == _StitchFallback.sorry ? 0.16 : 0.22);
    canvas.drawCircle(Offset(center.dx - eyeOffset, eyeY), eyeRadius, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(center.dx + eyeOffset, eyeY), eyeRadius, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(center.dx - eyeOffset, eyeY + eyeRadius * 0.15), eyeRadius * 0.55, inkPaint);
    canvas.drawCircle(Offset(center.dx + eyeOffset, eyeY + eyeRadius * 0.15), eyeRadius * 0.55, inkPaint);

    // Nose
    canvas.drawCircle(Offset(center.dx, center.dy + headRadius * 0.28), headRadius * 0.24, inkPaint);

    // Mood accent (small badge) for redCard/sorry states
    if (mood == _StitchFallback.redCard) {
      final cardRect = Rect.fromCenter(
        center: Offset(center.dx + headRadius * 1.05, center.dy - headRadius * 0.55),
        width: headRadius * 0.7,
        height: headRadius * 0.95,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(4)), Paint()..color = StitchColors.danger);
    }
  }

  @override
  bool shouldRepaint(covariant _StitchFacePainter oldDelegate) => oldDelegate.mood != mood;
}