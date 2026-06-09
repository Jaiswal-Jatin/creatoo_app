import 'dart:ui';
import 'package:creatoo/features/onboarding/model/onboarding_model.dart';
import 'package:flutter/services.dart';

import '../../../core.dart';
import '../widget/onboarding_slide_widget.dart';

class OnboardingView extends StatefulWidget {
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    _pageController = PageController();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

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
                width: 350.w,
                height: 350.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100.h,
            left: -50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 250.w,
                height: 250.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.1),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                // Progress indicator
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: List.generate(
                      OnboardingModel.data.length,
                      (index) => Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: _currentPageIndex >= index
                                ? AppColor.premiumAccent
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    OnboardingModel.data[_currentPageIndex].title ?? 'Discover, Earn & Enjoy\nwith Creatoo!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),

                // -------------- SLIDES ----------------
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: OnboardingModel.data.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return OnboardingSlide(
                        description: OnboardingModel.data[index].description!,
                        image: OnboardingModel.data[index].image!,
                        isFirstSlide: index == 0,
                        isLastSlide: index == OnboardingModel.data.length - 1,
                        onNext: () async {
                          if (_currentPageIndex <
                              OnboardingModel.data.length - 1) {
                            setState(() => _currentPageIndex++);
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            SharedPreferencesService _pref =
                                SharedPreferencesService();
                            await _pref.saveOnboarding(true);

                            Navigator.pushReplacementNamed(
                              context,
                              RoutesName.startupView,
                            );
                          }
                        },
                      );
                    },
                    onPageChanged: (index) {
                      setState(() => _currentPageIndex = index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
