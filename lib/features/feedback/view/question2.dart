import 'dart:ui';

import 'package:creatoo/core.dart';
import 'package:creatoo/features/feedback/view_model/feedback_view_model.dart';

import '../../../widgets/app_dot_progress_bar.dart';
import '../../../widgets/app_text_widget.dart';
import '../../../widgets/custom_painter/semi_arch.dart';
import '../../../widgets/next_button_widget.dart';

class Question2 extends StatefulWidget {
  final Function(int) onNext;

  const Question2({super.key, required this.onNext});

  @override
  State<Question2> createState() => _Question2State();
}

class _Question2State extends State<Question2> {
  late FeedbackViewModel viewModel;
  int selectedDotIndex = 4;

  final List<String> satisfactionLevels = ['Very Dissatisfied', 'Dissatisfied', 'Neutral', 'Satisfied', 'Very Satisfied'];

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
              SizedBox(height: 30.h),

              // Arc Visualization Card
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
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: Size(240.w, 130.h),
                                painter: SemiArchPainter(
                                  gradientColors: [
                                    Colors.redAccent,
                                    Colors.orangeAccent,
                                    Colors.yellowAccent,
                                    Colors.lightGreenAccent,
                                    Colors.greenAccent
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 10.h,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppTextWidget(
                                      text: satisfactionLevels[selectedDotIndex],
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.premiumAccent,
                                    ),
                                    SizedBox(height: 4.h),
                                    AppTextWidget(
                                      text: "${selectedDotIndex + 1}",
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 40.h),
                        AppTextWidget(
                          text: "How satisfied are you with\nour service quality?",
                          fontSize: 18.sp,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        
                        SizedBox(height: 32.h),
                        
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
              widget.onNext((selectedDotIndex + 1));
            },
            answer: (selectedDotIndex + 1),
          ),
        )
      ],
    );
  }
}
