import 'package:flutter/material.dart';

import '../resources/color.dart';
import '../utils/ui_config/app_size_config.dart';

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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isSmall = h < 700;
    
    return InkWell(
      onTap: onPress,
      child: Container(
        height: isSmall ? h * 0.055 : 40.h,
        width: isSmall ? w * 0.45 : 200.w,
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(isSmall ? 8 : borderRadius),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : FittedBox(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: isSmall ? w * 0.035 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: true,
                  ),
                ),
        ),
      ),
    );
  }
}
