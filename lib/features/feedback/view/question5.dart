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
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Animated Emoji
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_rating),
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.asset(
                      emojiPaths[_rating - 1],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Star Rating Progress Bar
            CustomProgressBar(
              selectedIndex: _rating - 1,
              onDotTap: _onRatingSelected,
              progressColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey[300]!,
              selectedDotColor: AppColor.white,
              dotColor: AppColor.moreLighterDd,
              useStarIcon: true,
            ),
            const SizedBox(height: 40),
            AppTextWidget(
              text: "Would you continue to interact with us in the future?",
              fontSize: 20,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        ),
        NextButtonWidget(
          onNext: () {
            viewModel.saveAnswer("interaction", _rating);
            widget.onNext(_rating);
          },
          answer: _rating,
        ),
      ],
    );
  }
}
