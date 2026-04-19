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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColor.premiumAccent.withOpacity(0.15) 
              : AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected 
                ? AppColor.premiumAccent.withOpacity(0.5) 
                : Colors.white.withOpacity(0.05),
            width: 1.2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColor.premiumAccent.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColor.white : AppColor.premiumTextSecondary,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
