import 'dart:ui';
import 'package:flutter/services.dart';
import '../../../core.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutBack),
      ),
    );

    _controller.forward();
    
    // Splash screen stays for 5 seconds as requested
    Future.delayed(const Duration(seconds: 5), () {
      _initialization();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initialization() async {
    print("🟠 [SPLASH] Starting initialization...");
    try {
      final SharedPreferencesService _preferencesService = SharedPreferencesService();
      var myToken = await _preferencesService.getToken();
      
      print("🟠 [SPLASH] Token: $myToken");

      // Logged-in user → go home
      if (myToken != null && myToken.isNotEmpty) {
        token = myToken;
        userId = await _preferencesService.getUserId();
        roleId = await _preferencesService.getUserRoleId();

        print("🟢 [SPLASH] User logged in, navigating to Home");
        FlutterNativeSplash.remove();
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.homePage,
            arguments: 0,
          );
        }
        return;
      }

      // Not logged in → always go to onboarding for now as per user request
      else {
        print("🟡 [SPLASH] User not logged in, navigating to Onboarding");
        FlutterNativeSplash.remove();
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.onboardingView,
          );
        }
        return;
      }
    } catch (e) {
      print("🔴 [SPLASH] Error: $e");
      FlutterNativeSplash.remove();
      if (mounted) {
        Navigator.pushReplacementNamed(context, RoutesName.onboardingView);
      }
    }
  }

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
            right: -100.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 400.w,
                height: 400.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.25),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            left: -50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.15),
                ),
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo
                        Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white, // Background color for the logo circle
                            image: DecorationImage(
                              image: AssetImage(Images.appLogo),
                              fit: BoxFit.contain, // Ensures the whole logo is visible
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.premiumAccent.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),
                        // App Name
                        Text(
                          Constants.appName.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Tagline
                        Text(
                          "EMPOWERING CREATIVITY",
                          style: GoogleFonts.montserrat(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 4,
                            color: AppColor.premiumAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              },
            ),
          ),
          
          // Bottom Loader
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.premiumAccent.withOpacity(0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
