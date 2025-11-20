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
      gradient: AppGradient.onboardingBg,
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                height: 350.h,
                width: 350.w,
                AppIcon.userRole,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 100.h),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  height: 200.h,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(12.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, bottom: 5),
                        child: Text(
                          'Are you ?',
                          style: GoogleFonts.manrope(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.black,
                          ),
                        ),
                      ),
                      AppButton(
                        height: 55.h,
                        text: "Business",
                        isIconEnabled: false,
                        onTap: () async {
                          viewModel.saveUser(Constants.businessUser);
                          Navigator.pushNamed(context, RoutesName.authView); //RoleId for Business 2
                        },
                      ),
                      // SizedBox(height: 5.h),
                      AppButton(
                        height: 55.h,
                        text: "User",
                        isIconEnabled: false,
                        buttonColor: AppColor.white,
                        textColor: AppColor.black,
                        enableBorder: true,
                        onTap: () {
                          viewModel.saveUser(Constants.creatorUser);
                          Navigator.pushNamed(context, RoutesName.authView); //RoleId for Creator 3
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
