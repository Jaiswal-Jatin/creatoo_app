import '../../../core.dart';
import '../../../widgets/app_text_widget.dart';
import '../view_model/feedback_view_model.dart';

class Question6 extends StatefulWidget {
  final VoidCallback onSubmit;

  const Question6({super.key, required this.onSubmit});

  @override
  _Question6State createState() => _Question6State();
}

class _Question6State extends State<Question6> {
  late FeedbackViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        AppTextWidget(
          text: "Do you want to write/tell us\nsomething else?",
          fontSize: 22,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.moreLighterDd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: viewModel.feedbackTextController,
                  maxLines: 6,
                  minLines: 6,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    hintText: "Enter your feedback...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
