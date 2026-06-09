import 'dart:ui';
import 'package:creatoo/widgets/custom_back_button.dart';

import '../../../core.dart';

class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100.h,
            right: -50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 350.w,
                height: 350.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.15),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50.h,
            left: -80.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
              ),
            ),
          ),

          // Main Content
          Center(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glassmorphic Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(40.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Animated Icon or Image
                              Container(
                                padding: EdgeInsets.all(24.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.premiumAccent.withOpacity(0.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.premiumAccent.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  AppIcon.comingSoon,
                                  height: 150.h,
                                  width: 150.w,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 40.h),
                              
                              // Text Section
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
                                ).createShader(bounds),
                                child: Text(
                                  "Exciting things\nare coming soon!",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                "We're working hard to bring you\nthis feature. Stay tuned!",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.premiumTextSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Custom Back Button at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 16.w,
            child: CustomBackButton(
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: AppButton(
          onTap: () async {
            Navigator.pop(context);
          },
          text: "Back to Home",
          icon: Icons.home_rounded,
        ),
      ),
    );
  }
}
