import 'package:creatoo/features/notification/model/notification_response_model.dart';
import 'package:creatoo/features/notification/repository/notification_repository.dart';

import '../../../core.dart';

class NotificationViewModel with ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  late NotificationResponseModel model;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int lastNotificationCount = 0;
  bool hasNewNotification = false;
  List<NotificationData> notifications = [];
  bool isLoading = false;
  int currentPage = 1;
  int totalPages = 1;

  ApiResponse<NotificationResponseModel> notificationResponse = ApiResponse.loading();

  void setResponse(ApiResponse<NotificationResponseModel> response) {
    notificationResponse = response;
    notifyListeners();
  }

  Future<void> fetchNotifications({bool isRefreshing = false}) async {
    if (isRefreshing) {
      currentPage = 1;
      notifications.clear();
    }

    if (isLoading || currentPage > totalPages) return;
    isLoading = true;
    notifyListeners();

    var response = await _repo.getNotificationApi({
      "user_id": userId,
      "role_id": roleId,
      "token": '$token',
    }, page: currentPage);

    response.fold(
      (l) {
        isLoading = false;
        setResponse(ApiResponse.error(l.message));
        notifyListeners();
      },
      (r) {
        if (r.data?.data != null) {
          if (isRefreshing) {
            notifications = List.from(r.data!.data!);
          } else {
            notifications.addAll(r.data!.data!);
          }
          totalPages = r.data!.lastPage ?? 1;
          currentPage++;
        }

        isLoading = false;
        setResponse(ApiResponse.completed(r));
      },
    );

    notifyListeners();
  }

  Future<void> loadMoreNotifications() async {
    if (!isLoading && currentPage <= totalPages) {
      await fetchNotifications();
    }
  }
}
