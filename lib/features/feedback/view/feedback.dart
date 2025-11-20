import '../../../core.dart';
import '../../../widgets/app_progress_bar.dart';
import '../view_model/feedback_view_model.dart';
import 'question1.dart';
import 'question2.dart';
import 'question3.dart';
import 'question4.dart';
import 'question5.dart';
import 'question6.dart';

class FeedbackScreen extends StatefulWidget {
  final String businessName;
  final int businessId;
  final String orderId;

  const FeedbackScreen({super.key, required this.businessName, required this.businessId, required this.orderId});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late FeedbackViewModel viewModel;
  int currentPage = 1;
  final int totalPages = 6;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
    viewModel.businessId = widget.businessId;
    viewModel.businessName = widget.businessName;
    viewModel.orderId = widget.orderId;
  }

  void _saveAnswerAndNext(int answer) {
    if (answer == null && currentPage < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose your answer before proceeding.")),
      );
      return;
    }

    String key = _getFeedbackKey(currentPage);
    viewModel.saveAnswer(key, answer);
    _nextPage();
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  String _getFeedbackKey(int page) {
    switch (page) {
      case 1:
        return "experience";
      case 2:
        return "expectation";
      case 3:
        return "recommend";
      case 4:
        return "fair_money";
      case 5:
        return "interaction";
      case 6:
        return "review_text";
      default:
        return "";
    }
  }

  Widget _getQuestionWidget() {
    print("Navigating to Question: $currentPage");
    switch (currentPage) {
      case 1:
        return Question1(onNext: _saveAnswerAndNext);
      case 2:
        return Question2(onNext: _saveAnswerAndNext);
      case 3:
        return Question3(onNext: _saveAnswerAndNext);
      case 4:
        return Question4(onNext: _saveAnswerAndNext);
      case 5:
        return Question5(onNext: _saveAnswerAndNext);
      case 6:
        return Question6(onSubmit: _submitFeedback);
      default:
        return const SizedBox();
    }
  }

  Future<void> _submitFeedback() async {
    bool success = await viewModel.submitFeedback();
    if (success && mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFeedbackSubmitted', true);
      await prefs.setString('feedbackBusinessName', viewModel.businessName ?? "");
      await prefs.setString('feedbackOrderId', viewModel.orderId ?? "");
      Navigator.pushNamed(context, RoutesName.thankYouFeedback);
    }
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<FeedbackViewModel>(context);

    switch (viewModel.feedbackResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.feedbackResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AppScaffold(
        appBar: AppBarWidget(
          disableLeadingButton: true,
          title: widget.businessName,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ProgressBar(currentPage: currentPage, totalPages: totalPages),
              Expanded(child: _getQuestionWidget()),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: (currentPage == 6)
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppButton(
                  isIconEnabled: true,
                  onTap: _submitFeedback,
                  text: "SUBMIT",
                ),
              )
            : null,
      ),
    );
  }
}
