import 'package:creatoo/features/onboarding/model/onboarding_model.dart';
import 'package:flutter/services.dart';
import 'package:creatoo/features/force_update/service/version_check_service.dart';

import '../../../core.dart';
import '../widget/onboarding_slide_widget.dart';

class OnboardingView extends StatefulWidget {
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  bool _isInitializing = true; // Track initialization state

  @override
  void initState() {
    super.initState();
    initialization(); // Directly call initialization without force update check
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    _pageController = PageController();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  // ------------------ VERSION CHECK ---------------------
  Future<void> _checkVersionAndInitialize() async {
    try {
      final versionResponse = await VersionCheckService.checkAppVersion();

      if (versionResponse != null && versionResponse.needsUpdate) {
        FlutterNativeSplash.remove();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            RoutesName.forceUpdateView,
            arguments: {
              'message': versionResponse.message,
              'currentVersion': versionResponse.clientVersion,
              'latestVersion': versionResponse.latestVersion,
            },
          );
        });
        return;
      }

      initialization();
    } catch (e, st) {
      print("Error during version check: $e\n$st");
      initialization();
    }
  }

  // ------------------ INITIALIZATION ---------------------
  void initialization() async {
    try {
      final SharedPreferencesService _preferencesService = SharedPreferencesService();
      var myToken = await _preferencesService.getToken();
      var isOnboarded = await _preferencesService.getOnboarding() ?? false;

      // First time user → show onboarding
      if (!isOnboarded && myToken == null) {
        // Only set _isInitializing to false when we want to show onboarding UI
        if (mounted) {
          setState(() => _isInitializing = false);
        }
        FlutterNativeSplash.remove();
        return;
      }

      // Logged-in user → go home
      if (isOnboarded && myToken != null) {
        token = myToken;
        userId = await _preferencesService.getUserId();
        roleId = await _preferencesService.getUserRoleId();

        if (kDebugMode) {
          print("UserId : $userId\nRoleId : $roleId\nJWT Token : $myToken\n\n");
        }

        FlutterNativeSplash.remove();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            RoutesName.homePage,
            arguments: 0,
          );
        });
        return;
      }

      // Onboarded but not logged-in → open startup view
      else if (isOnboarded) {
        FlutterNativeSplash.remove();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            RoutesName.startupView,
          );
        });
        return;
      }
    } catch (e, st) {
      print("Error during initialization: $e\n$st");
      FlutterNativeSplash.remove();
    }
  }

  // ------------------ UI ---------------------
  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (_isInitializing) {
      return const Scaffold(
        body: SizedBox.shrink(), // Keep splash screen visible
      );
    }

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isSmall = h < 700;

    return AppScaffold(
      gradient: AppGradient.onboardingBg,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(isSmall ? w * 0.04 : 16.w),
          child: Column(
            children: [
              // Progress indicator
              Stack(
                children: [
                  Container(
                    height: isSmall ? h * 0.012 : 10.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
                    ),
                  ),
                  AnimatedAlign(
                    alignment: _currentPageIndex == 0
                        ? Alignment.centerLeft
                        : _currentPageIndex == 1
                            ? Alignment.center
                            : Alignment.centerRight,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                    child: Container(
                      height: isSmall ? h * 0.012 : 10.h,
                      width: w / OnboardingModel.data.length,
                      decoration: BoxDecoration(
                        color: AppColor.mangoYellow,
                        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
                      ),
                    ),
                  )
                ],
              ),

              SizedBox(height: isSmall ? h * 0.04 : 32.h),

              // Title
              Text(
                'Discover, Earn & Enjoy\nwith Creatoo!',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: isSmall ? w * 0.06 : 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),

              SizedBox(height: isSmall ? h * 0.02 : 16.h),

              // -------------- SLIDES ----------------
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: OnboardingModel.data.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return OnboardingSlide(
                      description: OnboardingModel.data[index].description!,
                      image: OnboardingModel.data[index].image!,
                      isFirstSlide: index == 0,
                      isLastSlide: index == OnboardingModel.data.length - 1,
                      onNext: () async {
                        if (_currentPageIndex < OnboardingModel.data.length - 1) {
                          setState(() => _currentPageIndex++);
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        } else {
                          SharedPreferencesService _pref = SharedPreferencesService();
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
      ),
    );
  }
}
