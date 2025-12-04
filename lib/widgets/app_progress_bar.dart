import 'package:flutter/material.dart';

import '../resources/color.dart';
import '../utils/ui_config/app_size_config.dart';

class ProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const ProgressBar({
    Key? key,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isSmall = h < 700;
    
    double progress = (currentPage / totalPages).clamp(0.0, 1.0);

    return Container(
      height: isSmall ? h * 0.02 : 15.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.moreLighterDd,
        borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: w * progress,
              height: isSmall ? h * 0.02 : 15.h,
              decoration: BoxDecoration(
                color: AppColor.kPrimary,
                borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example Usage
// ProgressBar(currentPage: 1, totalPages: 6),
