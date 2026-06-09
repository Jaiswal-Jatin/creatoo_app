import 'dart:ui';
import 'package:creatoo/features/verify_otp/view_model/verify_otp_view_model.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import 'package:flutter/services.dart';
import '../../../core.dart';
import '../../home/view_model/home_view_model.dart';

class VerifyOtpView extends StatefulWidget {
  final String phone;
  final String otp;

  const VerifyOtpView({super.key, required this.phone, required this.otp});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  late VerifyOtpViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<VerifyOtpViewModel>(context, listen: false);
    viewModel.init(widget.phone, widget.otp);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      viewModel.disposeData();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50.h,
      height: 50.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: AppColor.premiumAccent),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.redAccent),
      ),
    );

    final VerifyOtpViewModel viewModel = Provider.of<VerifyOtpViewModel>(context);
    
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

          // Back Button
          if (Platform.isIOS)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 16.w,
              child: const CustomBackButton(),
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
                      // Illustration
                      SvgPicture.asset(
                        AppIcon.otp,
                        height: 180.h,
                        width: 180.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 30.h),
                      
                      // Title
                      Text(
                        'Verification',
                        style: GoogleFonts.montserrat(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Enter the 6-digit code sent to your mobile number +91 ${widget.phone}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColor.premiumTextSecondary,
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // OTP Card
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
                                Pinput(
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  length: 6,
                                  controller: viewModel.pinController,
                                  focusNode: viewModel.focusNode,
                                  defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: focusedPinTheme,
                                  errorPinTheme: errorPinTheme,
                                  validator: (value) => viewModel.validateOtp(value!),
                                ),
                                SizedBox(height: 30.h),
                                
                                // Timer / Resend
                                Visibility(
                                  visible: viewModel.timerDuration == 0,
                                  replacement: Text(
                                    "Resend in ${viewModel.timerDuration}s",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColor.premiumTextSecondary,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      final creatorPayload = {"mobile": viewModel.phone};
                                      final businessPayload = {"business_mobile": viewModel.phone};
                                      await viewModel.resendOtpFromServer(
                                          roleId == Constants.creatorUser ? creatorPayload : businessPayload);
                                    },
                                    child: Text(
                                      "Resend Code",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.premiumAccent,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30.h),

                                // Verify Button
                                AppButton(
                                  text: "Verify OTP",
                                  isIconEnabled: false,
                                  isLoading: viewModel.verifyOtp.status == Status.loading,
                                  onTap: () async {
                                    Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: false).isLogout = false;
                                    if (viewModel.formKey.currentState!.validate()) {
                                      viewModel.updateValidation(false);
                                      final creatorVerifyPayload = {
                                        "mobile": viewModel.phone,
                                        "otp": viewModel.pinController.text,
                                        "device_id": viewModel.deviceId,
                                        "remember_token": fcmToken,
                                      };
                                      final businessVerifyPayload = {
                                        "business_mobile": viewModel.phone,
                                        "otp": viewModel.pinController.text,
                                        "device_id": viewModel.deviceId,
                                        "remember_token": fcmToken,
                                      };
                                      await viewModel.verifyOtpFromServer(
                                        roleId == Constants.creatorUser ? creatorVerifyPayload : businessVerifyPayload,
                                      );
                                    } else {
                                      viewModel.updateValidation(true);
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
        ],
      ),
    );
  }
}
