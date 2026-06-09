import 'dart:ui';

import 'package:creatoo/core.dart';
import 'package:creatoo/features/feedback/view_model/feedback_view_model.dart';

import '../../../widgets/app_dot_progress_bar.dart';
import '../../../widgets/app_text_widget.dart';
import '../../../widgets/next_button_widget.dart';

class Question5 extends StatefulWidget {
  final Function(int) onNext;

  const Question5({super.key, required this.onNext});

  @override
  State<Question5> createState() => _Question5State();
}

class _Question5State extends State<Question5> {
  late FeedbackViewModel viewModel;
  int _rating = 5;

  final List<String> emojiPaths = [
    'assets/gifs/emoji1.gif',
    'assets/gifs/emoji2.gif',
    'assets/gifs/emoji3.gif',
    'assets/gifs/emoji4.gif',
    'assets/gifs/emoji5.gif',
  ];

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
  }

  void _onRatingSelected(int index) {
    bool isTappingDefault = (index == 4);
    bool isSameAsBefore = (_rating == index + 1);

    if (isSameAsBefore && !isTappingDefault) return;

    setState(() {
      _rating = index + 1;
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

              // Animated Emoji with Glow
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Container(
                    key: ValueKey(_rating),
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
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180.w,
                          height: 180.w,
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
                            emojiPaths[_rating - 1],
                            width: 160.w,
                            height: 160.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
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
                          text: "Would you continue to interact with us in the future?",
                          fontSize: 18.sp,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        SizedBox(height: 32.h),
                        
                        CustomProgressBar(
                          selectedIndex: _rating - 1,
                          onDotTap: _onRatingSelected,
                          progressColor: AppColor.premiumAccent,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          selectedDotColor: Colors.black,
                          dotColor: Colors.white30,
                          useStarIcon: true,
                        ),

                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppTextWidget(text: "Unlikely", color: Colors.white38, fontSize: 12.sp),
                            AppTextWidget(text: "Definitely", color: AppColor.premiumAccent, fontSize: 12.sp, fontWeight: FontWeight.w600),
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
              viewModel.saveAnswer("interaction", _rating);
              widget.onNext(_rating);
            },
            answer: _rating,
          ),
        )
      ],
    );
  }
}
