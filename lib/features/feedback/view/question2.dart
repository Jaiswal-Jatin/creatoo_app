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
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 120),
                    painter: SemiArchPainter(
                      gradientColors: [Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      AppTextWidget(
                        text: satisfactionLevels[selectedDotIndex],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.darkRed,
                      ),
                      const SizedBox(height: 12),
                      AppTextWidget(
                        text: "${selectedDotIndex + 1}",
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColor.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AppTextWidget(
              text: "How satisfied are you with\n    our service quality?",
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 40),
            CustomProgressBar(
              selectedIndex: selectedDotIndex,
              onDotTap: (index) {
                updateSelection(index);
              },
              progressColor: AppColor.kPrimary,
              backgroundColor: AppColor.scaffoldColor,
              selectedDotColor: Colors.white,
              dotColor: Colors.black,
            ),
          ],
        ),

        // Next Button
        NextButtonWidget(
          onNext: () {
            widget.onNext((selectedDotIndex + 1));
          },
          answer: (selectedDotIndex + 1),
        )
      ],
    );
  }
}
