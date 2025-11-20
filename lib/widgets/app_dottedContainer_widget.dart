import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class AppDottedContainer extends StatelessWidget {
  final double? width;
  final double borderRadius;
  final List<double> dashPattern;
  final Color borderColor;
  final Color backgroundColor;
  final Widget? child;

  const AppDottedContainer({
    Key? key,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.dashPattern = const [6, 4],
    this.borderColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(borderRadius),
      dashPattern: dashPattern,
      strokeWidth: 2,
      color: borderColor,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: backgroundColor,
        ),
        padding: EdgeInsets.all(16), // Add padding to ensure content is not cut off
        child: child, // Content determines height
      ),
    );
  }
}
