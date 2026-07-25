import 'package:flutter/material.dart';

/// Paints the morphing black sheet as a single smooth path.
///
/// Two things make this feel "liquid" instead of like a rectangle sliding
/// up:
/// 1. Rounded top-left/top-right corners that soften to 0 as
///    [cornerRadius] shrinks — this is what makes the sheet feel like it's
///    flattening into a fullscreen surface as the drag completes.
/// 2. A raised belly in the middle of the top edge (driven by
///    [liquidBulge]), which peaks mid-drag and settles flat again at both
///    ends of the gesture — giving the shape a springy, alive quality
///    while it's being dragged.
class CurvedSheetPainter extends CustomPainter {
  final double topY;
  final double cornerRadius;
  final double liquidBulge;
  final Color color;

  CurvedSheetPainter({
    required this.topY,
    required this.cornerRadius,
    required this.liquidBulge,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawPath(_buildPath(size), paint);
  }

  Path _buildPath(Size size) {
    final width = size.width;
    final height = size.height;
    final radius = cornerRadius.clamp(0.0, width/2);
    final centerX = width / 2;
    // Roughly matches the collapsed button's half-width so the bulge reads
    // as "the button pulling the sheet upward" rather than a random wobble.
    final bulgeHalfWidth = width * 0.32;

    final path = Path()
      ..moveTo(0, height)
      ..lineTo(0, topY + radius);

    if (radius > 0) {
      path.quadraticBezierTo(0, topY, radius, topY);
    } else {
      // path.lineTo(0, topY);
    }

    path.lineTo(centerX - bulgeHalfWidth, topY);

    // Liquid belly: cubic bezier bulging upward at the center.


    path.lineTo(width - radius, topY);

    if (radius > 0) {
      path.quadraticBezierTo(width, topY, width, topY + radius);
    } else {
      path.lineTo(width, topY);
    }

    path
      ..lineTo(width, height)
      ..close();

    return path;
  }

  @override
  bool shouldRepaint(covariant CurvedSheetPainter oldDelegate) {
    return oldDelegate.topY != topY ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.liquidBulge != liquidBulge ||
        oldDelegate.color != color;
  }
}
