import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:creatoo/core.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final int businessId;
  final String businessName;
  final double amount;

  const PaymentProcessingScreen({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.amount,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          Positioned(top: -100.h, right: -60.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(width: 350.w, height: 350.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.premiumAccent.withValues(alpha: 0.1))),
          )),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment_rounded, color: AppColor.premiumAccent, size: 64.sp),
                SizedBox(height: 24.h),
                Text("Processing Payment",
                  style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                SizedBox(height: 8.h),
                Text("Please wait...",
                  style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
