import 'package:creatoo/widgets/app_text_widget.dart';

import '../../../core.dart';
import '../../home/view/home_page.dart';

import '../view_model/feedback_view_model.dart';

class ThankYouFeedback extends StatefulWidget {
  const ThankYouFeedback({super.key});

  @override
  _ThankYouFeedbackState createState() => _ThankYouFeedbackState();
}

class _ThankYouFeedbackState extends State<ThankYouFeedback> {
  late FeedbackViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
    super.initState();
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _navigateToHome();
          return false;
        },
        child: AppScaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppTextWidget(
                    text: 'Thank You For Your Feedback At '
                        "${viewModel.businessName}",
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 0,
                    children: [
                      AppTextWidget(
                        text: "You have Earned",
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                      AppTextWidget(
                        text: ' ${viewModel.earnedPoints} ',
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: AppColor.green,
                        maxLines: 2,
                      ),
                      AppTextWidget(
                        text: 'Points.',
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppButton(
                isIconEnabled: true,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RoutesName.homePage,
                    (route) => false,
                  );
                },
                text: "Go to Home",
              )),
        ));
  }
}
