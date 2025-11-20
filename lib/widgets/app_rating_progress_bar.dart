import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:flutter/material.dart';

import '../resources/color.dart';

class RatingProgressBar extends StatelessWidget {
  final double percentage; // Value from 0 to 100
  final double height;
  final Color fillColor;
  final Color backgroundColor;

  const RatingProgressBar({
    super.key,
    required this.percentage,
    this.height = 20,
    this.fillColor = AppColor.green,
    this.backgroundColor = AppColor.moreLighterDd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double filledWidth = (percentage > 0) ? (percentage / 100) * constraints.maxWidth : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.3), // Base color
                borderRadius: BorderRadius.circular(4),
              ),
              child: filledWidth > 0
                  ? Stack(
                      children: [
                        Container(
                          width: filledWidth,
                          height: height,
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    )
                  : null, // No filled color if percentage is 0
            ),
            const SizedBox(height: 6),

            // Percentage Label
            Align(
              alignment: percentage == 100 ? Alignment.centerRight : Alignment.centerLeft, // ✅ Right align if 100%
              child: Padding(
                padding: EdgeInsets.only(
                  left: percentage > 0 && percentage < 100 ? filledWidth - 30 : 0, // ✅ Keep inside bar when < 100
                  right: percentage == 100 ? 4 : 0, // ✅ Right-aligned when 100%
                ),
                child: AppTextWidget(
                  text: '${percentage.toInt()}%',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  textAlign: TextAlign.right, // ✅ Ensures right alignment for 100%
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
