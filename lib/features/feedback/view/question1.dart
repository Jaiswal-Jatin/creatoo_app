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
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),

            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                    child: child,
                  );
                },
                child: Container(
                  key: ValueKey(selectedDotIndex),
                  width: 200,
                  height: 210,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        bottom: 10,
                        child: ClipOval(
                          child: Image.asset(
                            dogGifs[selectedDotIndex],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            AppTextWidget(
              text: "How would you rate your\noverall experience?",
              fontSize: 22,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
            ),

            const SizedBox(height: 30),

            // Custom Progress Bar
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
            widget.onNext(selectedDotIndex + 1);
          },
          answer: selectedDotIndex + 1,
        )
      ],
    );
  }
}
