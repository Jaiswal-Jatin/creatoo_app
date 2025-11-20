import 'package:creatoo/core.dart';
import 'package:creatoo/features/creator_home/view_model/creator_home_view_model.dart';

class CreatorHomeView extends StatefulWidget {
  const CreatorHomeView({super.key});

  @override
  State<CreatorHomeView> createState() => _CreatorHomeViewState();
}

class _CreatorHomeViewState extends State<CreatorHomeView> {
  late CreatorHomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<CreatorHomeViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CreatorHomeViewModel>(context);
    switch (viewModel.homeResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.homeResponse.message!);
      case Status.completed:
        var application = viewModel.homeResponse.data!.data!;
        var user = viewModel.profileResponse.data?.data!;
        return AppScaffold(
          isSafe: false,
          body: Stack(
            children: [
              Container(
                height: SizeConfig.screenHeight,
                width: SizeConfig.screenWidth,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 220.h,
                        child: Stack(
                          children: [
                            Container(
                              // height: 155.h,
                              child: SvgPicture.asset(
                                AppIcon.profileBgShort,
                                // height: 200.h,
                                width: SizeConfig.screenWidth,
                              ),
                            ),
                            Positioned(
                              top: SizeConfig.screenWidth / 5,
                              left: SizeConfig.screenWidth / 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: AppGradient.profileBg,
                                ),
                                child: CircleAvatar(
                                  radius: 65.h,
                                  backgroundColor: AppColor.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: AppImageWidget(
                                      height: 130.h,
                                      width: 130.h,
                                      imageUrl:
                                          user == null ? "" : user.userImage!,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user?.name ?? "",
                              style: GoogleFonts.montserrat(
                                textStyle:
                                    Theme.of(navigatorKey.currentContext!)
                                        .textTheme
                                        .displayLarge,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                                height: user?.instagramUsername != null &&
                                        user?.instagramVerificationStatus ==
                                            InstagramStatus.approved.index
                                    ? 10.h
                                     : 0),
                            AppConditionalWidget(
                              visibility: user?.instagramVerificationStatus! ==
                                  InstagramStatus.approved.index,
                              child: Text(
                                user?.instagramUsername ?? "",
                                style: AppTextStyles.body(
                                  fontSize: 14.sp,
                                  color: Color(0xFF838383),
                                ),
                              ),
                            ),
                            SizedBox(height: user?.bio == null ? 0 : 10.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.bio ?? "",
                                    style: AppTextStyles.body(
                                      fontSize: 12.sp,
                                      color: Color(0xFF838383),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: user?.bio == null ? 10.h : 30.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildContainer(
                                  "Opportunities",
                                  application.opportunities!,
                                  onTap: () async => viewModel
                                      .navigateTo(ApplicationStatus.all),
                                ),
                                SizedBox(width: 10.w),
                                buildContainer(
                                  ApplicationStatus
                                      .applied.name.capitalizeFirst,
                                  application.applied!,
                                  onTap: () async => viewModel
                                      .navigateTo(ApplicationStatus.applied),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildContainer(
                                  "Ongoing Deals",
                                  application.onGoingDeals!,
                                  onTap: () async => viewModel
                                      .navigateTo(ApplicationStatus.ongoing),
                                ),
                                SizedBox(width: 10.w),
                                buildContainer(
                                  "Successful Deals",
                                  application.successfulDeals!,
                                  onTap: () async => viewModel
                                      .navigateTo(ApplicationStatus.completed),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RoutesName.settingsView);
                          },
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.settings),
                              SizedBox(width: 5.w),
                              Text('Settings',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp)),
                            ],
                          ),
                          icon: SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return AppNoDataWidget();
    }
  }

  Widget buildContainer(String name, int value, {void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100.h,
        width: SizeConfig.screenWidth / 2.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.white,
          boxShadow: [
            BoxShadow(
              color: AppColor.lightGrey,
              spreadRadius: 1,
              blurRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$value",
              style: GoogleFonts.montserrat(
                textStyle: Theme.of(navigatorKey.currentContext!)
                    .textTheme
                    .displayLarge,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.montserrat(
                  textStyle: Theme.of(navigatorKey.currentContext!)
                      .textTheme
                      .displayLarge,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B6B6B)),
            ),
          ],
        ),
      ),
    );
  }
}
