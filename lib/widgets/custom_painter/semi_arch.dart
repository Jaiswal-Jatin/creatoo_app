import 'dart:math';

import 'package:flutter/material.dart';

class SemiArchPainter extends CustomPainter {
  final List<Color> gradientColors;

  SemiArchPainter({required this.gradientColors});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final Gradient gradient = SweepGradient(
      startAngle: pi,
      endAngle: 2 * pi,
      colors: gradientColors,
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0;

    final Path path = Path()..arcTo(rect, pi, pi, false);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
