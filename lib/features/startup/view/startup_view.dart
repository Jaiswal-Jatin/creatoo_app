import 'dart:ui';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/startup/view_model/startup_view_model.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  late StartupViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<StartupViewModel>(context, listen: false);
    viewModel.checkUserLogIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final StartupViewModel viewModel = Provider.of<StartupViewModel>(context);
    
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100.h,
            left: -100.w,
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
          Positioned(
            bottom: -50.h,
            right: -50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 250.w,
                height: 250.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.12),
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration
                    SvgPicture.asset(
                      AppIcon.userRole,
                      height: 300.h,
                      width: 300.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 60.h),
                    
                    // Welcome Title
                    Text(
                      'Welcome to Creatoo',
                      style: GoogleFonts.montserrat(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Select your account type to get started.',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColor.premiumTextSecondary,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Role Selection Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'I am a...',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              AppButton(
                                text: "Business",
                                isIconEnabled: false,
                                onTap: () async {
                                  viewModel.saveUser(Constants.businessUser);
                                  Navigator.pushNamed(context, RoutesName.authView);
                                },
                              ),
                              SizedBox(height: 16.h),
                              AppButton(
                                text: "User / Creator",
                                isIconEnabled: false,
                                buttonColor: Colors.white.withOpacity(0.1),
                                textColor: Colors.white,
                                enableBorder: true,
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                onTap: () {
                                  viewModel.saveUser(Constants.creatorUser);
                                  Navigator.pushNamed(context, RoutesName.authView);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

