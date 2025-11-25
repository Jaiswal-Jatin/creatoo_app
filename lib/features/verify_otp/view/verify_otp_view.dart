import 'package:creatoo/features/verify_otp/view_model/verify_otp_view_model.dart';
import 'package:flutter/services.dart';

import '../../../core.dart';
// using direct maps for payloads; models not required in this view
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
      width: 60.h,
      height: 60.h,
      padding: EdgeInsets.zero,
      textStyle: TextStyle(
        fontSize: 24.sp,
        color: Color(0xFF161616),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.primary),
      borderRadius: BorderRadius.circular(10),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.error),
      borderRadius: BorderRadius.circular(10),
    );

    final VerifyOtpViewModel viewModel = Provider.of<VerifyOtpViewModel>(context);
    return AppScaffold(
      gradient: AppGradient.loginBg,
      body: Column(
        children: [
          // Conditional back button for iOS
          if (Platform.isIOS)
            Padding(
              padding: EdgeInsets.only(top: 20.h, left: 10.w),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColor.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          Expanded(
            child: Form(
              key: viewModel.formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Center(
                child: Container(
                  height: SizeConfig.screenHeight / 1.3,
                  margin: EdgeInsets.all(24.h),
                  padding: EdgeInsets.all(24.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.white.withOpacity(0.6),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'OTP',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SvgPicture.asset(
                          height: 200.h,
                          width: 200.w,
                          AppIcon.otp,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Enter the code we’ve sent to your mobile number +91 ${widget.phone}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF423F3F),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Pinput(
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          length: 6,
                          controller: viewModel.pinController,
                          focusNode: viewModel.focusNode,
                          smsRetriever: viewModel.smsRetriever,
                          isCursorAnimationEnabled: true,
                          animationCurve: Curves.linear,
                          animationDuration: Duration(milliseconds: 100),
                          closeKeyboardWhenCompleted: true,
                          forceErrorState: viewModel.forceValidation,
                          cursor: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          mouseCursor: MouseCursor.defer,
                          showCursor: true,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          errorPinTheme: errorPinTheme,
                          hapticFeedbackType: HapticFeedbackType.heavyImpact,
                          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                          useNativeKeyboard: true,
                          textInputAction: TextInputAction.done,
                          pinContentAlignment: Alignment.center,
                          validator: (value) => viewModel.validateOtp(value!),
                        ),
                        SizedBox(height: 24.h),
                        Visibility(
                          visible: viewModel.timerDuration == 0 ? true : false,
                          replacement: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Resend in ",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w300,
                                    color: AppColor.darkGrey,
                                  ),
                                ),
                                TextSpan(
                                  text: "${viewModel.timerDuration} seconds",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.darkGrey,
                                  ),
                                )
                              ],
                            ),
                            textAlign: TextAlign.left,
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final creatorPayload = {"mobile": viewModel.phone};
                              final businessPayload = {"business_mobile": viewModel.phone};
                              await viewModel.resendOtpFromServer(
                                  roleId == Constants.creatorUser ? creatorPayload : businessPayload);
                            },
                            child: Text(
                              "Resend",
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColor.darkGrey),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        AppButton(
                          text: "Verify",
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
                              };
                              final businessVerifyPayload = {
                                "business_mobile": viewModel.phone,
                                "otp": viewModel.pinController.text,
                                "device_id": viewModel.deviceId,
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
            ),
          ),
        ],
      ),
    );
  }
}
