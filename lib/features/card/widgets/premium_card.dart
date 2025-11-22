import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core.dart';
import 'activate_card.dart';
import 'particle_animation.dart';

class PremiumGlassCard extends StatelessWidget {
  const PremiumGlassCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: AppColor.premiumCardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Particle Animation
            const ParticleAnimation(),

            // Glassmorphism Effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColor.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "CREATOO",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.white,
                        ),
                      ),
                      Icon(
                        Icons.verified,
                        color: AppColor.white,
                        size: 28.sp,
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    "Jatin Jaiswal",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.white.withOpacity(0.9),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "**** **** ****",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Activate Button
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: ElevatedButton(
                onPressed: () => _showActivateCardModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    // side: BorderSide(color: AppColor.black, width: 2),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
                child: Text(
                  'Activate',
                  style: TextStyle(
                    color: AppColor.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivateCardModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColor.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: AppColor.black.withOpacity(0.5),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: const ActivateCardModal(),
            ),
          ),
        );
      },
    );
  }
}
