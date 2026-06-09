import 'dart:ui';

import 'package:creatoo/widgets/app_text_widget.dart';

import '../../../core.dart';
import '../../home/view/home_page.dart';

import '../view_model/feedback_view_model.dart';

class ThankYouFeedback extends StatefulWidget {
  const ThankYouFeedback({super.key});

  @override
  _ThankYouFeedbackState createState() => _ThankYouFeedbackState();
}

class _ThankYouFeedbackState extends State<ThankYouFeedback> {
  late FeedbackViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToHome();
        return false;
      },
      child: AppScaffold(
        useGradient: true,
        backgroundColor: AppColor.premiumBg,
        isSafe: false,
        body: Stack(
          children: [
            // Background Glows
            Positioned(
              top: 200.h,
              right: -100.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  width: 300.w,
                  height: 300.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.premiumAccent.withOpacity(0.1),
                  ),
                ),
              ),
            ),

            // Content
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Success Icon with Glow
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.premiumAccent.withOpacity(0.1),
                              border: Border.all(color: AppColor.premiumAccent.withOpacity(0.3)),
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 60.sp,
                              color: AppColor.premiumAccent,
                            ),
                          ),
                          SizedBox(height: 32.h),

                          AppTextWidget(
                            text: 'Thank You!',
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8.h),
                          AppTextWidget(
                            text: 'Your feedback for ${viewModel.businessName} has been submitted.',
                            fontSize: 14.sp,
                            textAlign: TextAlign.center,
                            color: Colors.white70,
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: AppButton(
            onTap: _navigateToHome,
            text: "BACK TO HOME",
          ),
        ),
      ),
    );
  }
}
