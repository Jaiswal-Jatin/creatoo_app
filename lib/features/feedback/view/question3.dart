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
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/gifs/screen3_gif.gif',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AppTextWidget(
              text: "Would you recommend us\n              to others?",
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => updateSelection(1), // Yes = 1
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAnswer == 1 ? AppColor.kPrimary : Colors.white,
                    side: BorderSide(color: AppColor.kPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: Text(
                    "Yes",
                    style: TextStyle(color: selectedAnswer == 1 ? Colors.white : Colors.black),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => updateSelection(0), // No = 0
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAnswer == 0 ? AppColor.kPrimary : Colors.white,
                    side: BorderSide(color: AppColor.kPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: Text(
                    "No",
                    style: TextStyle(color: selectedAnswer == 0 ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
        NextButtonWidget(
          onNext: () {
            if (selectedAnswer != -1) {
              // Ensure an answer is selected
              viewModel.saveAnswer("recommend", selectedAnswer);
              widget.onNext(selectedAnswer);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select an answer before proceeding.")),
              );
            }
          },
          answer: selectedAnswer,
        ),
      ],
    );
  }
}
