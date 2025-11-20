import '../core.dart';

class AppDottedBorderContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color color;
  final BorderRadius borderRadius;

  AppDottedBorderContainer({
    required this.child,
    this.width,
    this.height,
    required this.color,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: CustomPaint(
        painter: DottedBorderPainter(color: color, borderRadius: borderRadius),
        child: child,
      ),
    );
  }
}
