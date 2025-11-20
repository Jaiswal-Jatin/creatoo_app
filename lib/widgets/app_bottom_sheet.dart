import '../core.dart';

class AppBottomSheet {
  static void showBottomSheet() {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      backgroundColor: AppColor.white,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (context) => WillPopScope(
        onWillPop: () async {
          Navigator.popUntil(context, (route) => route.isFirst);
          return true;
        },
        child: Container(
          height: SizeConfig.screenHeight / 2.5,
          margin: EdgeInsets.symmetric(vertical: 30),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LottieBuilder.asset(
                height: 80.h,
                width: 80.h,
                repeat: false,
                "assets/lottie/success.json",
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Creators Shortlisted Successfully',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Congratulations! You've successfully shortlisted the top creators for your project. Get ready to collaborate and bring your vision to life. Let's make something amazing together.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              AppButton(
                text: "Done",
                isIconEnabled: false,
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              )
            ],
          ),
        ),
      ),
    );
  }
}
