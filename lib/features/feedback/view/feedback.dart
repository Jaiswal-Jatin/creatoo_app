import 'dart:ui';
import 'package:creatoo/widgets/app_text_widget.dart';

import '../../../core.dart';
import '../../../widgets/app_progress_bar.dart';
import '../view_model/feedback_view_model.dart';
import 'question1.dart';
import 'question2.dart';
import 'question3.dart';
import 'question4.dart';
import 'question5.dart';
import 'question6.dart';

class FeedbackScreen extends StatefulWidget {
  final String businessName;
  final int businessId;
  final String orderId;

  const FeedbackScreen(
      {super.key,
      required this.businessName,
      required this.businessId,
      required this.orderId});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late FeedbackViewModel viewModel;
  int currentPage = 1;
  final int totalPages = 1; // Only 1 step now

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
    viewModel.businessId = widget.businessId;
    viewModel.businessName = widget.businessName;
    viewModel.orderId = widget.orderId;
  }

  void _saveAnswerAndNext(int answer) {
    String key = _getFeedbackKey(currentPage);
    viewModel.saveAnswer(key, answer);
    _submitFeedback(); // Submit immediately after step 1
  }

  void _nextPage() {
    // Commented out since there's only 1 step
    // if (currentPage < totalPages) {
    //   setState(() {
    //     currentPage++;
    //   });
    // }
  }

  String _getFeedbackKey(int page) {
    switch (page) {
      case 1:
        return "experience";
      // case 2:
      //   return "expectation";
      // case 3:
      //   return "recommend";
      // case 4:
      //   return "fair_money";
      // case 5:
      //   return "interaction";
      // case 6:
      //   return "review_text";
      default:
        return "";
    }
  }

  Widget _getQuestionWidget() {
    print("Navigating to Question: $currentPage");
    switch (currentPage) {
      case 1:
        return Question1(onNext: _saveAnswerAndNext);
      // case 2:
      //   return Question2(onNext: _saveAnswerAndNext);
      // case 3:
      //   return Question3(onNext: _saveAnswerAndNext);
      // case 4:
      //   return Question4(onNext: _saveAnswerAndNext);
      // case 5:
      //   return Question5(onNext: _saveAnswerAndNext);
      // case 6:
      //   return Question6(onSubmit: _submitFeedback);
      default:
        return const SizedBox();
    }
  }

  Future<void> _submitFeedback() async {
    bool success = await viewModel.submitFeedback();
    if (success && mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFeedbackSubmitted', true);
      await prefs.setString(
          'feedbackBusinessName', viewModel.businessName ?? "");
      await prefs.setString('feedbackOrderId', viewModel.orderId ?? "");
      Navigator.pushNamed(context, RoutesName.thankYouFeedback);
    }
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<FeedbackViewModel>(context);

    switch (viewModel.feedbackResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.feedbackResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    return WillPopScope(
      onWillPop: () async => false,
      child: AppScaffold(
        useGradient: true,
        backgroundColor: AppColor.premiumBg,
        isSafe: false,
        body: Stack(
          children: [
            // Background Glows
            Positioned(
              top: -50.h,
              left: -50.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 250.w,
                  height: 250.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.premiumAccent.withOpacity(0.08),
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Custom AppBar Area
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: Row(
                      children: [
                        const SizedBox(width: 48), // Spacer for centering
                        Expanded(
                          child: AppTextWidget(
                            text: widget.businessName,
                            textAlign: TextAlign.center,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 48), // Spacer for centering
                      ],
                    ),
                  ),

                  // Progress Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppTextWidget(
                              text: "Step $currentPage of $totalPages",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.premiumAccent,
                            ),
                            AppTextWidget(
                              text: "${((currentPage / totalPages) * 100).toInt()}%",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: currentPage / totalPages,
                            minHeight: 6.h,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColor.premiumAccent),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Question Area
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                      child: _getQuestionWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: (currentPage == 6)
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                child: AppButton(
                  onTap: _submitFeedback,
                  text: "SUBMIT REVIEW",
                  isLoading: viewModel.feedbackResponse.status == Status.loading,
                ),
              )
            : null,
      ),
    );
  }
}
