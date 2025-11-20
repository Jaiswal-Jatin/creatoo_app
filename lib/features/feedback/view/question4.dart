import 'package:creatoo/core.dart';
import 'package:creatoo/features/feedback/view_model/feedback_view_model.dart';

import '../../../widgets/app_text_widget.dart';
import '../../../widgets/next_button_widget.dart';

class Question4 extends StatefulWidget {
  final Function(int) onNext;

  const Question4({super.key, required this.onNext});

  @override
  State<Question4> createState() => _Question4State();
}

class _Question4State extends State<Question4> {
  late FeedbackViewModel viewModel;
  String _gifPath = 'assets/gifs/eye1.gif';
  int? selectedAnswer = 1;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
  }

  void updateSelection(int fairMoney) {
    setState(() {
      selectedAnswer = fairMoney;
      if (fairMoney == 0) {
        _gifPath = 'assets/gifs/eye2.gif';
      } else {
        _gifPath = 'assets/gifs/eye1.gif';
      }
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
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: Image.asset(
                    _gifPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AppTextWidget(
              text: "   Did you find the pricing/\n  value for money to be fair?",
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => updateSelection(1),
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
                  onPressed: () => updateSelection(0),
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
            if (selectedAnswer != null) {
              viewModel.saveAnswer("fair_money", selectedAnswer);
              widget.onNext(selectedAnswer!);
            }
          },
          answer: selectedAnswer ?? 0,
        ),
      ],
    );
  }
}
