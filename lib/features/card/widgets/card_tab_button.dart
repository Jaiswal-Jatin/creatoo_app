import 'package:flutter/material.dart';
import '../../../core.dart';

class CardTabButton extends StatelessWidget {
  const CardTabButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ?  AppColor.kPrimary : AppColor.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: AppColor.black.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:isSelected ?  AppColor.white : AppColor.black,
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
