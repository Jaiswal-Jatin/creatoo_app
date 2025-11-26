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
  String? noNotificationMessage; // New property to hold "no notification" message

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
        if (l.message == "Empty Notification.") {
          noNotificationMessage = "No new notifications.";
          setResponse(ApiResponse.completed(null)); // Treat as a successful "no data" state
        } else {
          noNotificationMessage = null; // Clear if it was set previously
          setResponse(ApiResponse.error(l.message));
        }
        notifyListeners();
      },
      (r) {
        isLoading = false; // Set loading to false when response is received
        if (r.data?.data != null && r.data!.data!.isNotEmpty) {
          if (isRefreshing) {
            notifications = List.from(r.data!.data!);
          } else {
            notifications.addAll(r.data!.data!);
          }
          totalPages = r.data!.lastPage ?? 1;
          currentPage++;
          noNotificationMessage = null; // Clear message if notifications are found
        } else {
          // If data is null or empty, and no existing notifications, show "No new notifications"
          if (notifications.isEmpty) {
            noNotificationMessage = "No new notifications.";
          }
          setResponse(ApiResponse.completed(r)); // Still a completed response, just no data
        }
        notifyListeners(); // Notify listeners after processing both branches
      },
    );
  }

  Future<void> loadMoreNotifications() async {
    if (!isLoading && currentPage <= totalPages) {
      await fetchNotifications();
    }
  }
}
