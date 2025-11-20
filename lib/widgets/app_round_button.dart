import 'package:flutter/material.dart';

import '../resources/color.dart';

class AppRoundButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  final double borderRadius; // Added parameter for border radius

  const AppRoundButton({
    Key? key,
    required this.title,
    this.loading = false,
    required this.onPress,
    this.borderRadius = 10, // Default border radius
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: 40,
        width: 200,
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(borderRadius), // Apply custom border radius
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  title,
                  style: const TextStyle(color: AppColor.white),
                ),
        ),
      ),
    );
  }
}
