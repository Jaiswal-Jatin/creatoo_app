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
    
    debugPrint('\n\n=== [${DateTime.now()}] Starting submitFeedback ===');
    debugPrint('📤 Feedback Submission Details:');
    debugPrint('🔹 User ID: $userId');
    debugPrint('🔹 Business ID: $businessId');
    debugPrint('🔹 Business Name: $businessName');
    debugPrint('🔹 Order ID: $orderId');
    debugPrint('🔹 Role ID: $roleId');
    debugPrint('🔹 Feedback Answers: $feedbackAnswers');
    
    setFeedbackResponse(ApiResponse.loading());
    notifyListeners();

    var requestData = {
      "user_id": userId,
      "business_id": businessId,
      "role_id": roleId,
      "order_id": orderId,
      ...feedbackAnswers,
      "token": '$token',
    };
    
    debugPrint('\n📦 API Request Payload:');
    debugPrint(requestData.toString());
    debugPrint('\n🔄 Sending feedback API request...');

    var response = await _repo.sendFeedbackApi(requestData);

    return response.fold(
      (l) {
        debugPrint('\n❌ Feedback API Error:');
        debugPrint('🔴 Error Message: ${l.message}');
        debugPrint('🔴 Status Code: ${l.statusCode}');
        setFeedbackResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
        notifyListeners();
        debugPrint('\n🏁 Completed submitFeedback with error');
        debugPrint('==================================================\n');
        return false;
      },
      (r) {
        debugPrint('\n✅ Feedback API Success:');
        debugPrint('🟢 Points Earned: ${r.pointsEarnerd}');
        earnedPoints = r.pointsEarnerd;
        setFeedbackResponse(ApiResponse.completed(r));
        Utils.toastMessage("Feedback submitted successfully!");
        feedbackTextController.clear();
        notifyListeners();
        debugPrint('\n🏁 Completed submitFeedback successfully');
        debugPrint('==================================================\n');
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
