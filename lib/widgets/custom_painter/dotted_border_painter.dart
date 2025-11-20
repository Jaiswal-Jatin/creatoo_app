import 'dart:ui';

import '../../core.dart';

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final BorderRadius borderRadius;

  DottedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double dashWidth = 5;
    final double dashSpace = 5;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);

    final path = Path()..addRRect(rrect);

    _drawDottedBorder(canvas, path, paint, dashWidth, dashSpace);
  }

  void _drawDottedBorder(Canvas canvas, Path path, Paint paint,
      double dashWidth, double dashSpace) {
    final PathMetric pathMetric = path.computeMetrics().first;
    final double length = pathMetric.length;
    double distance = 0.0;

    while (distance < length) {
      final double start = distance;
      final double end = distance + dashWidth;
      final Path extractPath = pathMetric.extractPath(start, end);
      canvas.drawPath(extractPath, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}