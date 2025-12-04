import 'package:creatoo/core.dart';
// creator request model not required here after minimal payload change
import 'package:creatoo/features/auth/view_model/auth_view_model.dart';
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
    final isSmall = h < 700;
    
    return AppScaffold(
      gradient: AppGradient.loginBg,
      body: Column(
        children: [
          // Conditional back button for iOS
          if (Platform.isIOS)
            Padding(
              padding: EdgeInsets.only(top: isSmall ? h * 0.025 : 20.h, left: w * 0.025),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColor.primary,
                    size: isSmall ? w * 0.05 : null,
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
              child: Center(
                child: Container(
                  height: isSmall ? h * 0.65 : SizeConfig.screenHeight / 1.4,
                  margin: EdgeInsets.all(isSmall ? w * 0.06 : 24.h),
                  padding: EdgeInsets.all(isSmall ? w * 0.06 : 24.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.white.withOpacity(0.6),
                    borderRadius: BorderRadius.all(
                      Radius.circular(isSmall ? 10 : 12),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: isSmall ? w * 0.07 : 30.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: isSmall ? h * 0.015 : 12.h),
                        SvgPicture.asset(
                          height: isSmall ? h * 0.25 : 200.h,
                          width: isSmall ? w * 0.5 : 200.w,
                          AppIcon.auth,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: isSmall ? h * 0.015 : 12.h),
                        Flexible(
                          child: Text(
                            'Hello! Looks like you\'re enjoying our page, but you haven\'t Log In for an account yet.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              textStyle: Theme.of(navigatorKey.currentContext!).textTheme.displayLarge,
                              fontSize: isSmall ? w * 0.035 : 15.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            softWrap: true,
                          ),
                        ),
                        SizedBox(height: isSmall ? h * 0.03 : 24.h),
                        Container(
                          height: isSmall ? h * 0.08 : 70.h,
                          child: AppTextField(
                            // autofocus: true,
                            controller: viewModel.phoneController,
                            hintText: "Mobile Number",
                            textInputType: TextInputType.number,
                            maxLength: 10,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: isSmall ? w * 0.04 : 15.0, right: isSmall ? w * 0.015 : 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    height: isSmall ? w * 0.05 : 20.h,
                                    width: isSmall ? w * 0.05 : 20.h,
                                    AppIcon.indiaFlag,
                                    fit: BoxFit.contain,
                                  ),
                                  Text(
                                    '${viewModel.countryCode}',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700,
                                      fontSize: isSmall ? w * 0.032 : 14.sp,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColor.primary,
                                    size: isSmall ? w * 0.04 : null,
                                  ),
                                  VerticalDivider(
                                    thickness: 1,
                                    color: Color(0xFFC0BFBF),
                                  )
                                ],
                              ),
                            ),
                            // suffixIcon: SvgPicture.asset(
                            //   height: 20.h,
                            //   width: 20.h,
                            //   AppIcon.person,
                            //   fit: BoxFit.contain,
                            // ),
                            validator: (v) => Validator.validate(v, "Mobile Number"),
                          ),
                        ),
                        SizedBox(height: isSmall ? h * 0.03 : 24.h),
                        AppButton(
                          text: "Log In",
                          isIconEnabled: false,
                          isLoading: viewModel.otp.status == Status.loading,
                          onTap: () async {
                            if (viewModel.formKey.currentState!.validate()) {
                              // Send minimal payloads: creator -> only mobile, business -> businessMobile + remember token
                              final Map<String, dynamic> creatorPayload = {
                                "mobile": viewModel.phoneController.text,
                                "is_verified": 0,
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
            ),
          ),
        ],
      ),
    );
  }
}
