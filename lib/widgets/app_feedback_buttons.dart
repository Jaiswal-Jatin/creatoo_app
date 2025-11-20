import 'package:flutter/material.dart';

import '../resources/color.dart';

class FeedbackButtons extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final int currentPage;
  final int totalPages;

  const FeedbackButtons({
    Key? key,
    required this.onPrevious,
    required this.onNext,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Backward Button (Disabled if currentPage == 1)
        FloatingActionButton(
          onPressed: currentPage == 1 ? null : onPrevious,
          heroTag: "previous_button",
          backgroundColor: currentPage == 1 ? Colors.grey : AppColor.kPrimary,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),

        // Forward Button (Always enabled on the last page)
        FloatingActionButton(
          onPressed: onNext,
          heroTag: "next_button",
          backgroundColor: AppColor.kPrimary,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
