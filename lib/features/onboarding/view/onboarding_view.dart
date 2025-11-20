import 'package:creatoo/features/onboarding/model/onboarding_model.dart';
import 'package:flutter/services.dart';

import '../../../core.dart';
import '../widget/onboarding_slide_widget.dart';

class OnboardingView extends StatefulWidget {
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController; // Page controller for managing pages
  int _currentPageIndex = 0; // Track current page index

  @override
  void initState() {
    super.initState();
    initialization();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    _pageController = PageController(); // Initialize page controller
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values); // to re-show bars
  }

  void initialization() async {
    try {
      final SharedPreferencesService _preferencesService = SharedPreferencesService();
      var myToken = await _preferencesService.getToken();
      var isOnboarded = await _preferencesService.getOnboarding();
      isOnboarded = isOnboarded ?? false;

      if (!isOnboarded && myToken == null) {
        return;
      }

      if (isOnboarded && myToken != null) {
        token = myToken;
        userId = await _preferencesService.getUserId();
        roleId = await _preferencesService.getUserRoleId();

        if (kDebugMode) {
          print("UserId : $userId\nRoleId : $roleId\nJWT Token : $myToken\n\n");
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(navigatorKey.currentContext!, RoutesName.homePage, arguments: 0);
        });
      } else if (isOnboarded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(navigatorKey.currentContext!, RoutesName.startupView);
        });
      }
    } catch (e, st) {
      print("Error during initialization: $e\n$st");
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      gradient: AppGradient.onboardingBg,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(16),
          child: Stack(
            children: [
              Container(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          width: SizeConfig.screenWidth,
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(10),
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
                            height: 10,
                            width: SizeConfig.screenWidth / OnboardingModel.data.length,
                            decoration: BoxDecoration(
                              color: AppColor.mangoYellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      'Discover, Earn & Enjoy\nwith Creatoo!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              PageView.builder(
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
                        _currentPageIndex++;
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      } else {
                        SharedPreferencesService _pref = SharedPreferencesService();
                        await _pref.saveOnboarding(true);
                        Navigator.pushReplacementNamed(context, RoutesName.startupView);
                      }
                    },
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
