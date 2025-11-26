import 'package:creatoo/features/notification/view_model/notification_view_model.dart';
import 'package:creatoo/widgets/app_text_widget.dart';

import 'package:creatoo/resources/color.dart';

import '../../../core.dart';
import '../../home/view_model/home_view_model.dart';
import '../../wallet/view/business_wallet_view.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late NotificationViewModel viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      viewModel = Provider.of<NotificationViewModel>(context, listen: false);
      viewModel.fetchNotifications(isRefreshing: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        viewModel.loadMoreNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<NotificationViewModel>(context);

    switch (viewModel.notificationResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return _buildEmptyNotificationWidget(viewModel.notificationResponse.message.toString());
      case Status.completed:
        if (viewModel.noNotificationMessage != null || viewModel.notifications.isEmpty) {
          return _buildEmptyNotificationWidget(viewModel.noNotificationMessage ?? "No Notification received yet");
        }
        return _buildBody();
      default:
        return AppLoadingWidget(); // Default to loading or handle other unexpected states
    }
  }

  Widget _buildEmptyNotificationWidget(String message) {
    return AppScaffold(
      appBar: AppBarWidget(title: "Notification"),
      body: Center(
        child: Text("No Notification received yet"),
      ),
    );
  }

  Widget _buildBody() {
    // The check for empty notifications is now handled in the build method.
    // This method will only be called if there are notifications to display.
    // final notifications = viewModel.notificationResponse.data?.data?.data ?? [];
    final notifications = viewModel.notifications;

    return AppScaffold(
      appBar: AppBarWidget(title: "Notification"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: viewModel.formKey,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: viewModel.notifications.length + 1,
            itemBuilder: (context, index) {
              if (index == viewModel.notifications.length) {
                if (viewModel.isLoading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              }

              final notification = viewModel.notifications[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColor.moreLighterDd, width: 1), // Added border here
                ),
                child: InkWell(
                  onTap: () {
                    if (roleId == Constants.businessUser) {
                      Navigator.pop(context);
                      Provider.of<HomeViewModel>(context, listen: false).changeIndex(1, true);
                      businessWalletKey.currentState?.changeIndex(0);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notifications,
                          color: AppColor.kPrimary,
                          size: 24,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (roleId == Constants.creatorUser)
                                AppTextWidget(
                                  text: notification.notificationSubject ?? "Feedback Review",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              SizedBox(height: 4.h),
                              AppTextWidget(
                                text: notification.notificationText ?? " ",
                                fontSize: 13,
                                color: AppColor.darkGrey,
                              ),
                              if (notification.createdAt != null) ...[
                                SizedBox(height: 6.h),
                                AppTextWidget(
                                  text: "Received: ${notification.createdAt}", // Assuming createdAt exists
                                  fontSize: 10,
                                  color: AppColor.grey,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (roleId == Constants.creatorUser) ...[
                          SizedBox(width: 10.w),
                          if (notification.isRedeemed == "0")
                            SizedBox(
                              width: 80,
                              height: 30,
                              child: AppRoundButton(
                                title: 'Complete',
                                onPress: () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.completeFeedback,
                                  );
                                },
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
