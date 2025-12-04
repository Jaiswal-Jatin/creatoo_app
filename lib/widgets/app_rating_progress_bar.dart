import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:flutter/material.dart';

import '../resources/color.dart';
import '../utils/ui_config/app_size_config.dart';

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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isSmall = h < 700;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        double filledWidth = (percentage > 0) ? (percentage / 100) * constraints.maxWidth : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isSmall ? h * 0.025 : height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(isSmall ? 3 : 4),
              ),
              child: filledWidth > 0
                  ? Stack(
                      children: [
                        Container(
                          width: filledWidth,
                          height: isSmall ? h * 0.025 : height,
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(isSmall ? 3 : 4),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            SizedBox(height: isSmall ? h * 0.01 : 6.h),
            Align(
              alignment: percentage == 100 ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: percentage > 0 && percentage < 100 ? filledWidth - (isSmall ? w * 0.05 : 30) : 0,
                  right: percentage == 100 ? (isSmall ? w * 0.01 : 4) : 0,
                ),
                child: AppTextWidget(
                  text: '${percentage.toInt()}%',
                  fontWeight: FontWeight.w600,
                  fontSize: isSmall ? w * 0.03 : 12.sp,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
