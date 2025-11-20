import 'package:creatoo/features/review/model/reviews_response_model.dart';

import '../../../core.dart';
import '../repository/reviews_repository.dart';

class ReviewsViewModel with ChangeNotifier {
  final ReviewsRepository _myRepo = ReviewsRepository();
  late ReviewsResponseModel model;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ApiResponse<ReviewsResponseModel> reviewsResponse = ApiResponse.loading();
  List<ReviewsData> reviewList = [];

  void setResponse(ApiResponse<ReviewsResponseModel> response) {
    reviewsResponse = response;
  }

  void notify() {
    notifyListeners();
  }

  Future<void> getReviews({required int creatorId}) async {
    setResponse(ApiResponse.loading());
    var response = await _myRepo.allReviewsApi(body: {"user_id": creatorId, "token": token});
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        reviewList = r.data ?? [];
        setResponse(ApiResponse.completed(r));
      },
    );
    notifyListeners();
  }
}
