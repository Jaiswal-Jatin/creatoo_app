import 'package:creatoo/core.dart';
import 'package:creatoo/features/feedback/model/feedback_response_model.dart';

import '../model/skip_feedback_response_model.dart';

class FeedbackRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, FeedbackResponseModel>> sendFeedbackApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.sendFeedback,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseFeedbackResponse,
      body: body,
    );
  }

  Future<Either<AppException, SkipFeedbackResponseModel>> skipFeedbackApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.skipFeedback,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseSkipFeedbackResponse,
      body: body,
    );
  }
}
