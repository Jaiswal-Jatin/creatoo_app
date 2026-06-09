import 'dart:ui';

import 'package:creatoo/core.dart';
import 'package:creatoo/features/feedback/view_model/feedback_view_model.dart';

import '../../../widgets/app_dot_progress_bar.dart';
import '../../../widgets/app_text_widget.dart';
import '../../../widgets/next_button_widget.dart';

class Question1 extends StatefulWidget {
  final Function(int) onNext;

  const Question1({super.key, required this.onNext});

  @override
  State<Question1> createState() => _Question1State();
}

class _Question1State extends State<Question1> {
  late FeedbackViewModel viewModel;
  int selectedDotIndex = 4;

  final List<String> dogGifs = [
    'assets/gifs/dog1.gif',
    'assets/gifs/dog2.gif',
    'assets/gifs/dog3.gif',
    'assets/gifs/dog4.gif',
    'assets/gifs/dog5.gif',
  ];

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
  }

  void updateSelection(int index) {
    setState(() {
      selectedDotIndex = index;
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

              // Animated Gif Container with Glow
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                      ),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Container(
                    key: ValueKey(selectedDotIndex),
                    width: 220.w,
                    height: 220.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.premiumAccent.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200.w,
                          height: 200.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        ClipOval(
                          child: Image.asset(
                            dogGifs[selectedDotIndex],
                            width: 180.w,
                            height: 180.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Question Text in Glassmorphic Card
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
                          text: "How would you rate your\noverall experience?",
                          fontSize: 20.sp,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        SizedBox(height: 32.h),
                        
                        // Custom Progress Bar / Rating Slider
                        CustomProgressBar(
                          selectedIndex: selectedDotIndex,
                          onDotTap: (index) {
                            updateSelection(index);
                          },
                          progressColor: AppColor.premiumAccent,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          selectedDotColor: Colors.black,
                          dotColor: Colors.white30,
                        ),
                        
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppTextWidget(text: "Poor", color: Colors.white38, fontSize: 12.sp),
                            AppTextWidget(text: "Excellent", color: AppColor.premiumAccent, fontSize: 12.sp, fontWeight: FontWeight.w600),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 100.h), // Bottom spacing
            ],
          ),
        ),

        // Submit Button - Premium Style
        Positioned(
          bottom: 20.h,
          right: 24.w,
          left: 24.w,
          child: AppButton(
            onTap: () {
              widget.onNext(selectedDotIndex + 1);
            },
            text: "SUBMIT REVIEW",
            isLoading: viewModel.feedbackResponse.status == Status.loading,
          ),
        )
      ],
    );
  }
}
