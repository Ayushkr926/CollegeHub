import 'package:flutter/material.dart';

class TopNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    const double notchWidth = 90;
    const double notchDepth = 55;
    const double cornerRadius = 28;

    final double left = (size.width - notchWidth) / 2;
    final double right = left + notchWidth;
    final double center = size.width / 2;

    // Start from left edge
    path.moveTo(0, cornerRadius);

    // Top-left rounded corner
    path.quadraticBezierTo(
      0,
      0,
      cornerRadius,
      0,
    );

    // Straight line to notch
    path.lineTo(left - 18, 0);

    // Left curve into notch
    path.cubicTo(
      left - 8,
      0,
      left + 10,
      notchDepth,
      center,
      notchDepth,
    );

    // Right curve out of notch
    path.cubicTo(
      right - 10,
      notchDepth,
      right + 8,
      0,
      right + 18,
      0,
    );

    // Straight line to top-right corner
    path.lineTo(size.width - cornerRadius, 0);

    // Top-right rounded corner
    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      cornerRadius,
    );

    // Right edge
    path.lineTo(size.width, size.height);

    // Bottom edge
    path.lineTo(0, size.height);

    // Left edge back to start
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}