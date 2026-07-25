import 'package:flutter/material.dart';

class BottomBarPainter extends CustomPainter {
  final Color color;

  BottomBarPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPath = _createPath(size);

    canvas.drawShadow(
      shadowPath,
      Colors.black.withOpacity(.18),
      20,
      true,
    );

    canvas.drawPath(shadowPath, paint);
  }
  Path _createPath(Size size) {
    const double cornerRadius = 34;

    // Radius of floating button
    const double notchRadius = 38;

    // Space between button and notch
    const double margin = 8;

    final double center = size.width / 2;

    final double notch = notchRadius + margin;

    Path path = Path();

    path.moveTo(cornerRadius, 0);

    // Left straight edge
    path.lineTo(center - notch - 28, 0);

    /// Smooth left curve
    path.cubicTo(
      center - notch - 8,
      0,
      center - notch,
      notch * 0.45,
      center - notch * .72,
      notch * .72,
    );

    /// Perfect half circle cut
    path.arcToPoint(
      Offset(center + notch * .72, notch * .72),
      radius: const Radius.circular(50),
      clockwise: false,
    );

    /// Smooth right curve
    path.cubicTo(
      center + notch,
      notch * .45,
      center + notch + 8,
      0,
      center + notch + 28,
      0,
    );

    // Remaining top
    path.lineTo(size.width - cornerRadius, 0);

    // Top Right
    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      cornerRadius,
    );

    // Right
    path.lineTo(size.width, size.height - cornerRadius);

    // Bottom Right
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // Bottom
    path.lineTo(cornerRadius, size.height);

    // Bottom Left
    path.quadraticBezierTo(
      0,
      size.height,
      0,
      size.height - cornerRadius,
    );

    // Left
    path.lineTo(0, cornerRadius);

    // Top Left
    path.quadraticBezierTo(
      0,
      0,
      cornerRadius,
      0,
    );

    path.close();

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}