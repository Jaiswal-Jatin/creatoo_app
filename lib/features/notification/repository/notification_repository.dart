import 'package:creatoo/core.dart';

import '../model/notification_response_model.dart';

class NotificationRepository extends ChangeNotifier {
  final BaseApiServices _apiServices = NetworkApiService();
  Future<Either<AppException, NotificationResponseModel>> getNotificationApi(dynamic body, {required int page}) async {
    return await _apiServices.callPostAPI(
      "${AppUrl.getNotificationApi}?page=$page",
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: body,
      Parser.parseNotificationResponse,
    );
  }
}
