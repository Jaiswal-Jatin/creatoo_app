import 'dart:ui';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/auth/view_model/auth_view_model.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import 'package:flutter/services.dart';
import '../model/auth_business_request_model.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late AuthViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<AuthViewModel>(context, listen: false);
    viewModel.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  @override
  void dispose() {
    viewModel.disposeData();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final permissionService = PermissionHandlerService(context);
    await permissionService.requestMultiplePermissions();
  }

  @override
  Widget build(BuildContext context) {
    final AuthViewModel viewModel = Provider.of<AuthViewModel>(context);
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
            left: -50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
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

          // Main Content
          SafeArea(
            child: Form(
              key: viewModel.formKey,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Illustration/Logo
                      Hero(
                        tag: 'auth_icon',
                        child: SvgPicture.asset(
                          AppIcon.auth,
                          height: 180.h,
                          width: 180.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      
                      // Welcome Text
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.montserrat(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Login to your account to continue your creative journey.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColor.premiumTextSecondary,
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Login Card
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
                              children: [
                                // Phone Input
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: AppTextField(
                                    controller: viewModel.phoneController,
                                    backgroundColor: Colors.transparent,
                                    textColor: Colors.white,
                                    cursorColor: Colors.white,
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14.sp),
                                    hintText: "Mobile Number",
                                    textInputType: TextInputType.number,
                                    maxLength: 10,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    prefixIcon: Container(
                                      width: 90.w,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            AppIcon.indiaFlag,
                                            height: 16.h,
                                            width: 16.h,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${viewModel.countryCode}',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.sp,
                                              color: AppColor.premiumAccent,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Icon(Icons.keyboard_arrow_down, color: AppColor.premiumAccent, size: 16),
                                        ],
                                      ),
                                    ),
                                    validator: (v) => Validator.validate(v, "Mobile Number"),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                
                                // Login Button
                                AppButton(
                                  text: "Log In",
                                  isIconEnabled: false,
                                  isLoading: viewModel.otp.status == Status.loading,
                                  onTap: () async {
                                    if (viewModel.formKey.currentState!.validate()) {
                                      final Map<String, dynamic> creatorPayload = {
                                        "mobile": viewModel.phoneController.text,
                                        "is_verified": 0,
                                        "remember_token": fcmToken,
                                      };
                                      AuthBusinessRequestModel businessData = AuthBusinessRequestModel(
                                        businessMobile: "${viewModel.phoneController.text}",
                                        rememberToken: fcmToken,
                                      );
                                      await viewModel.getOtpFromServer(
                                        roleId == Constants.creatorUser ? creatorPayload : businessData.toJson(),
                                      );
                                    }
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
          ),

          // Back Button (on top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 16.w,
            child: CustomBackButton(
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
