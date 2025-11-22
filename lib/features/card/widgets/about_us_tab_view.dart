import 'package:flutter/material.dart';
import 'package:creatoo/core.dart'; // For AppColor, SizeConfig

class AboutUsTabView extends StatelessWidget {
  final String aboutUsText;

  const AboutUsTabView({super.key, this.aboutUsText = "About Us. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Center(
        child: Text(
          aboutUsText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            height: 1.5,
            color: AppColor.darkGrey,
          ),
        ),
      ),
    );
  }
}
