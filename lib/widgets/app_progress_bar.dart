import 'package:flutter/material.dart';

import '../resources/color.dart';

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
    double progress = (currentPage / totalPages).clamp(0.0, 1.0);

    return Container(
      height: 15, // Ensure this height is enforced
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.moreLighterDd, // Background color inside decoration
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Foreground progress
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * progress,
              height: 15,
              decoration: BoxDecoration(
                color: AppColor.kPrimary, // Foreground color inside decoration
                borderRadius: BorderRadius.circular(8),
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
