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
    super.initState();
    Future.microtask(() {
      viewModel = Provider.of<NotificationViewModel>(context, listen: false);
      viewModel.fetchNotifications(isRefreshing: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        viewModel.loadMoreNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<NotificationViewModel>(context);

    // Apply exact styling container as used in Search/Home
    return AppScaffold(
      useGradient: true, // Must be true so the background slides with the content
      isSafe: false,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h),
        child: Column(
          children: [
            _buildPremiumHeader(),
            SizedBox(height: 20.h),
            Expanded(
              child: _buildStatefulBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatefulBody() {
    switch (viewModel.notificationResponse.status) {
      case Status.loading:
        if (viewModel.notifications.isEmpty) {
          return AppLoadingWidget();
        }
        return _buildNotificationList();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.notificationResponse.message.toString());
      case Status.completed:
        if (viewModel.noNotificationMessage != null ||
            viewModel.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lottie/empty_search.json', height: 180.h, repeat: true),
                SizedBox(height: 10.h),
                AppTextWidget(
                  text: viewModel.noNotificationMessage ?? "No Notifications Yet",
                  color: AppColor.premiumTextSecondary,
                  fontSize: 15.sp,
                ),
              ],
            ),
          );
        }
        return _buildNotificationList();
      default:
        return AppLoadingWidget();
    }
  }

  Widget _buildPremiumHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Row(
        children: [
          _buildHeaderIcon(Icons.arrow_back_ios_new, () {
            Navigator.pop(context);
          }),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  text: "UPDATES",
                  fontSize: 11.sp,
                  color: AppColor.premiumAccent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
                SizedBox(height: 2.h),
                AppTextWidget(
                  text: "Notifications",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.premiumTextPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColor.premiumTextPrimary, size: 20.sp),
      ),
    );
  }

  Map<String, dynamic> _getNotificationTheme(dynamic notification) {
    // For pending reviews/alerts
    if (roleId == Constants.creatorUser && notification.isRedeemed == "0") {
      return {"color": AppColor.orange, "icon": Icons.assignment_late_rounded};
    }
    // Completed state
    if (roleId == Constants.creatorUser && notification.isRedeemed == "1") {
      return {"color": AppColor.activeGreen, "icon": Icons.check_circle};
    }
    // Generic notification
    return {"color": AppColor.premiumAccent, "icon": Icons.notifications_active};
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
      itemCount: viewModel.notifications.length + 1,
      itemBuilder: (context, index) {
        if (index == viewModel.notifications.length) {
          if (viewModel.isLoading) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(15.h),
                child: CircularProgressIndicator(color: AppColor.premiumAccent),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        }

        final notification = viewModel.notifications[index];
        final theme = _getNotificationTheme(notification);

        // Staggered List Entrance Animation
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)), // dynamic stagger
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 25 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 15.h),
            decoration: BoxDecoration(
              color: AppColor.premiumCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (theme["color"] as Color).withOpacity(0.15),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                if (roleId == Constants.businessUser) {
                  Navigator.pop(context);
                  Provider.of<HomeViewModel>(context, listen: false)
                      .changeIndex(1, true);
                  businessWalletKey.currentState?.changeIndex(0);
                }
              },
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Glowing Icon Container
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: (theme["color"] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (theme["color"] as Color).withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        theme["icon"] as IconData,
                        color: theme["color"] as Color,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (roleId == Constants.creatorUser)
                            AppTextWidget(
                              text: notification.notificationSubject ?? "Alert",
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColor.premiumTextPrimary,
                            ),
                          SizedBox(height: 5.h),
                          AppTextWidget(
                            text: notification.notificationText ?? "",
                            fontSize: 13.sp,
                            color: AppColor.premiumTextSecondary,
                          ),
                          SizedBox(height: 10.h),
                          if (notification.createdAt != null)
                            Row(
                              children: [
                                Icon(Icons.access_time, 
                                    size: 12.sp, color: AppColor.grey),
                                SizedBox(width: 4.w),
                                AppTextWidget(
                                  text: notification.createdAt!.toString().split('.')[0], // Format to exclude milliseconds
                                  fontSize: 11.sp,
                                  color: AppColor.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (roleId == Constants.creatorUser && notification.isRedeemed == "0") ...[
                      SizedBox(width: 10.w),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RoutesName.completeFeedback,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.mangoYellow,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          shadowColor: AppColor.mangoYellow.withOpacity(0.4),
                        ),
                        child: Text(
                          "Complete",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
