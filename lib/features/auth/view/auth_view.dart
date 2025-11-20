import 'package:creatoo/core.dart';
import 'package:creatoo/features/auth/model/auth_creator_request_model.dart';
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
              child: Center(
                child: Container(
                  height: SizeConfig.screenHeight / 1.4,
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
                          'Login',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SvgPicture.asset(
                          height: 200.h,
                          width: 200.w,
                          AppIcon.auth,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 12.h),
                        Text('Hello! Looks like you’re enjoying our page, but you haven’t Log In for an account yet.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              textStyle: Theme.of(navigatorKey.currentContext!).textTheme.displayLarge,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                            )),
                        SizedBox(height: 24.h),
                        Container(
                          height: 70.h,
                          child: AppTextField(
                            // autofocus: true,
                            controller: viewModel.phoneController,
                            hintText: "Mobile Number",
                            textInputType: TextInputType.number,
                            maxLength: 10,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 15.0, right: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SvgPicture.asset(
                                    height: 20.h,
                                    width: 20.h,
                                    AppIcon.indiaFlag,
                                    fit: BoxFit.contain,
                                  ),
                                  Text(
                                    '${viewModel.countryCode}',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColor.primary,
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
                        SizedBox(height: 24.h),
                        AppButton(
                          text: "Log In",
                          isIconEnabled: false,
                          isLoading: viewModel.otp.status == Status.loading,
                          onTap: () async {
                            if (viewModel.formKey.currentState!.validate()) {
                              AuthCreatorRequestModel creatorData = AuthCreatorRequestModel(
                                mobile: "${viewModel.phoneController.text}",
                                rememberToken: fcmToken,
                              );
                              AuthBusinessRequestModel businessData = AuthBusinessRequestModel(
                                businessMobile: "${viewModel.phoneController.text}",
                                rememberToken: fcmToken,
                              );
                              await viewModel.getOtpFromServer(
                                roleId == Constants.creatorUser ? creatorData.toJson() : businessData.toJson(),
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
