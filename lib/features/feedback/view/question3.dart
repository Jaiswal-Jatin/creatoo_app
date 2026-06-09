import 'dart:ui';

import 'package:creatoo/core.dart';
import 'package:creatoo/features/feedback/view_model/feedback_view_model.dart';

import '../../../widgets/app_text_widget.dart';
import '../../../widgets/next_button_widget.dart';

class Question3 extends StatefulWidget {
  final Function(int) onNext;

  const Question3({super.key, required this.onNext});

  @override
  State<Question3> createState() => _Question3State();
}

class _Question3State extends State<Question3> {
  late FeedbackViewModel viewModel;
  int selectedAnswer = 1;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
  }

  void updateSelection(int recommend) {
    setState(() {
      selectedAnswer = recommend;
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<FeedbackViewModel>(context);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),

              // Gif Container with Glow
              Center(
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.premiumAccent.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/gifs/screen3_gif.gif',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Question Card
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        AppTextWidget(
                          text: "Would you recommend us\nto others?",
                          fontSize: 20.sp,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        SizedBox(height: 32.h),
                        
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => updateSelection(1),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  decoration: BoxDecoration(
                                    gradient: selectedAnswer == 1 
                                      ? LinearGradient(colors: [AppColor.premiumAccent, AppColor.premiumAccent.withOpacity(0.8)])
                                      : null,
                                    color: selectedAnswer == 1 ? null : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selectedAnswer == 1 ? Colors.transparent : Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Center(
                                    child: AppTextWidget(
                                      text: "Yes",
                                      color: selectedAnswer == 1 ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: InkWell(
                                onTap: () => updateSelection(0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  decoration: BoxDecoration(
                                    gradient: selectedAnswer == 0 
                                      ? LinearGradient(colors: [AppColor.premiumAccent, AppColor.premiumAccent.withOpacity(0.8)])
                                      : null,
                                    color: selectedAnswer == 0 ? null : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selectedAnswer == 0 ? Colors.transparent : Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Center(
                                    child: AppTextWidget(
                                      text: "No",
                                      color: selectedAnswer == 0 ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 100.h),
            ],
          ),
        ),

        // Next Button
        Positioned(
          bottom: 20.h,
          right: 0,
          left: 0,
          child: NextButtonWidget(
            onNext: () {
              if (selectedAnswer != -1) {
                viewModel.saveAnswer("recommend", selectedAnswer);
                widget.onNext(selectedAnswer);
              } else {
                Utils.toastMessage("Please select an answer before proceeding.");
              }
            },
            answer: selectedAnswer,
          ),
        )
      ],
    );
  }
}
