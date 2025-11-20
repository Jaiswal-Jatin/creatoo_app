import 'package:creatoo/core.dart';
import 'package:creatoo/features/feedback/model/feedback_response_model.dart';
import 'package:creatoo/features/feedback/model/skip_feedback_response_model.dart';
import 'package:creatoo/features/feedback/repository/feedback_repository.dart';

class FeedbackViewModel with ChangeNotifier {
  final FeedbackRepository _repo = FeedbackRepository();
  late FeedbackResponseModel model;
  late SkipFeedbackResponseModel skipModel;
  List<GlobalKey<FormState>> get formKeys => List.generate(6, (_) => GlobalKey<FormState>());
  TextEditingController feedbackTextController = TextEditingController();
  ApiResponse<FeedbackResponseModel> feedbackResponse = ApiResponse.completed(FeedbackResponseModel());
  ApiResponse<SkipFeedbackResponseModel> skipResponse = ApiResponse.loading();
  int? businessId;
  String? businessName;
  int? earnedPoints;
  String? orderId;

  void setFeedbackResponse(ApiResponse<FeedbackResponseModel> response) {
    feedbackResponse = response;
    notifyListeners();
  }

  void setSkipResponse(ApiResponse<SkipFeedbackResponseModel> responseSkip) {
    skipResponse = responseSkip;
    notifyListeners();
  }

  void init() {
    feedbackTextController = TextEditingController();
  }

  Map<String, dynamic> feedbackAnswers = {
    "experience": null,
    "expectation": null,
    "recommend": null,
    "fair_money": null,
    "interaction": null,
    "review_text": "",
  };

  void saveAnswer(String key, dynamic value) {
    feedbackAnswers[key] = value;
    notifyListeners();
  }

  String? getAnswer(String key) {
    return feedbackAnswers[key]?.toString();
  }

  void notify() {
    notifyListeners();
  }

  Future<bool> submitFeedback() async {
    feedbackAnswers["review_text"] = feedbackTextController.text;
    setFeedbackResponse(ApiResponse.loading());
    notifyListeners();

    var response = await _repo.sendFeedbackApi(
      {
        "user_id": userId,
        "business_id": businessId,
        "role_id": roleId,
        "order_id": orderId,
        ...feedbackAnswers,
        "token": '$token',
      },
    );

    return response.fold(
      (l) {
        setFeedbackResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
        notifyListeners();
        return false;
      },
      (r) {
        earnedPoints = r.pointsEarnerd;
        setFeedbackResponse(ApiResponse.completed(r));
        Utils.toastMessage("Feedback submitted successfully!");
        feedbackTextController.clear();
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> skipFeedback() async {
    setSkipResponse(ApiResponse.loading());

    var response = await _repo.skipFeedbackApi({
      "user_id": userId,
      "order_id": orderId,
      "token": '$token',
    });

    return response.fold(
      (l) {
        setSkipResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
        return false;
      },
      (r) {
        setSkipResponse(ApiResponse.completed(r));
        Utils.toastMessage("Feedback skipped successfully!");
        return true;
      },
    );
  }
}
