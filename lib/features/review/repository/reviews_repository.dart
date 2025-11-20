import 'package:creatoo/features/review/model/reviews_response_model.dart';

import '../../../core.dart';

class ReviewsRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, ReviewsResponseModel>> allReviewsApi({required Map<String, dynamic> body}) async {
    return await _apiServices.callPostAPI(
      AppUrl.reviewList,
      {'Content-Type': 'application/json'},
      Parser.parseReviewsResponse,
      body: body,
    );
  }
}
