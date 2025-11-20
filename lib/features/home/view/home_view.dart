import '../../../core.dart';
import '../../../widgets/app_text_widget.dart';
import '../../creator_wallet/view_model/creator_wallet_view_model.dart';
import '../../wallet/view/business_wallet_view.dart';
import '../model/home_screen_response_model.dart';
import '../view_model/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeViewModel viewModel;
  bool hasNewNotification = true;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<HomeViewModel>(context, listen: false);
    viewModel.init();
  }

  void clearNewNotificationFlag() {
    hasNewNotification = false;
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<HomeViewModel>(context);
    switch (viewModel.homeResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.homeResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return AppNoDataWidget();
    }
  }

   Widget _buildBody() {
    return AppScaffold(
      appBar: _buildHomeAppBarWidget(),
      body: Container(
        width: SizeConfig.screenWidth,
        margin: EdgeInsets.symmetric(
          vertical: 10.h,
          horizontal: 17.w,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              (viewModel.homeResponse.data?.data?.banners == null || viewModel.homeResponse.data!.data!.banners!.isEmpty)
                  ? SizedBox.shrink()
                  : buildCarouselSlider(viewModel),
              SizedBox(height: 10.h),
              buildDotIndicator(viewModel),
              SizedBox(height: 10.h),
              Container(
                color: AppColor.transparent,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isBusiness = (roleId == Constants.businessUser);

                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Button
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                              child: _buildCustomCard(
                                icon: Icons.qr_code_scanner,
                                title: isBusiness ? "Show QR" : "Scan",
                                onPressed: () async {
                                  if (isBusiness) {
                                    await Navigator.pushNamed(context, RoutesName.scannerView, arguments: {
                                      'qrUrl':
                                          '${viewModel.homeResponse.data?.data?.roleSpecificData?.qrCode ?? ''}?t=${DateTime.now().millisecondsSinceEpoch}',
                                      'businessName': viewModel.user?.name ?? '',
                                    });
                                    await viewModel.init();
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      RoutesName.qrScannerView,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          // New Button
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                              child: _buildCustomCard(
                                icon: isBusiness ? Icons.store_mall_directory : Icons.credit_card,
                                title: isBusiness ? "Visit" : "Card",
                                onPressed: () {
                                  // TODO: Implement functionality for "Visit" or "Card" button
                                },
                              ),
                            ),
                          ),
                          // Second Button
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                              child: _buildCustomCard(
                                icon: Icons.redeem,
                                title: isBusiness ? "Today's Settlement" : "Balance",
                                balance: isBusiness
                                    ? "${viewModel.roundToTwoDecimalPlaces(viewModel.homeResponse.data?.data?.roleSpecificData?.todayWalletPoints?.toDouble() ?? 0.0).toCommaSeparated()}"
                                    : "${viewModel.roundToTwoDecimalPlaces(viewModel.homeResponse.data?.data?.roleSpecificData?.userCreatooPoints?.toDouble() ?? 0.0).toCommaSeparated()}",
                                onPressed: () {
                                  if (isBusiness) {
                                    Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: false).changeIndex(1, false);
                                    businessWalletKey.currentState?.changeIndex(1);
                                  } else {
                                    Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: false).changeIndex(2, true);
                                    Provider.of<CreatorWalletViewModel>(context, listen: false).changeIndex(1);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              viewModel.homeResponse.data!.data!.topReviewers!.isEmpty
                  ? const SizedBox.shrink()
                  : buildReviewers(name: "Top Reviewers", data: viewModel.homeResponse.data!.data!.topReviewers!),
              viewModel.homeResponse.data!.data!.topBusiness!.isEmpty
                  ? const SizedBox.shrink()
                  : buildBusiness(name: "Top Businesses", data: viewModel.homeResponse.data!.data!.topBusiness!),
              viewModel.homeResponse.data!.data!.newCreator!.isEmpty
                  ? const SizedBox.shrink()
                  : buildUser(name: "Recently Joined", data: viewModel.homeResponse.data!.data!.newCreator!),
              viewModel.homeResponse.data!.data!.newBusiness!.isEmpty
                  ? const SizedBox.shrink()
                  : buildBusiness(name: "New Businesses", data: viewModel.homeResponse.data!.data!.newBusiness!),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBusinessCard(Business item) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutesName.businessDescriptionView,
          arguments: item.id,
        );
      },
      child: Container(
        width: 180.w,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColor.bgLightPurple.withOpacity(0.2),
          border: Border.all(
            color: AppColor.moreLighterDd,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImageWidget(
                height: 110.h, // Reduced height for the image
                width: double.infinity,
                imageUrl: item.businessImage!,
              ),
            ),
            SizedBox(
              height: 8.h,
            ),
            AppTextWidget(
              text: '${item.businessName}',
              textOverflow: TextOverflow.ellipsis,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(
              height: 6.h,
            ),
            Row( // This new Row will hold both discount and address
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Separates discount and address
              children: [
                Container( // Discount with gradient background
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColor.kPrimary, AppColor.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        AppTextWidget(
                          text: '20% OFF',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                if (item.businessArea != null) // Address without yellow background, to the right
                  Expanded( // Use Expanded to give it available space
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end, // Align address to the right
                      children: [
                        SvgPicture.asset(
                          height: 12.h,
                          width: 12.h,
                          AppIcon.location,
                          color: Color(0xFF666666), // Use original address color for icon
                        ),
                        SizedBox(width: 4),
                        Expanded( // Wrap AppTextWidget in Expanded to prevent overflow
                          child: AppTextWidget(
                            text: '${item.businessArea}',
                            maxLines: 1,
                            softWrap: true,
                            textOverflow: TextOverflow.ellipsis,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // SizedBox(
            //   height: 6.h,
            // ),
          ],
        ),
      ),
    );
  }

  Row buildDotIndicator(HomeViewModel homeViewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: homeViewModel.homeResponse.data!.data!.banners!.asMap().entries.map(
        (entry) {
          return Container(
            width: 8.h,
            height: 8.h,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: homeViewModel.position == entry.key ? AppColor.kPrimary : Color(0xFFD1D8DD),
            ),
          );
        },
      ).toList(),
    );
  }

  CarouselSlider buildCarouselSlider(HomeViewModel homeViewModel) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150.0.h,
        autoPlay: true,
        enableInfiniteScroll: true,
        aspectRatio: 2.0,
        viewportFraction: 1,
        autoPlayInterval: const Duration(seconds: 3),
        onPageChanged: (index, reason) => homeViewModel.updateBannerIndex(index),
      ),
      carouselController: homeViewModel.controller,
      items: homeViewModel.homeResponse.data!.data!.banners!.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                homeViewModel.launchBannerUrl(item.link!);
              },
              child: Container(
                width: SizeConfig.screenWidth,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AppImageWidget(
                    imageUrl: item.image!,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Column buildComingSoon(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextWidget(
          text: title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(
          height: 10.h,
        ),
        Container(
          height: 180.h,
          width: SizeConfig.screenWidth,
          decoration: BoxDecoration(
            color: AppColor.darkGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Image.asset(height: 120.h, width: double.infinity, fit: BoxFit.cover, Images.appLogo),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Color(0xFFFFFFFF).withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            height: 20.h,
                            width: 20.h,
                            AppIcon.calender,
                          ),
                          SizedBox(width: 5),
                          AppTextWidget(
                            text: '22 Dec 2024',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColor.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTextWidget(text: 'Coming Soon...', fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColor.white),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        SvgPicture.asset(
                          height: 14.h,
                          width: 14.h,
                          color: AppColor.white,
                          AppIcon.location,
                        ),
                        SizedBox(width: 5.w),
                        AppTextWidget(
                          text: 'Pune',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColor.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildReviewers({required String name, required List<Reviewer> data}) {
    return Column(
      children: [
        Container(
          height: 170.h,
          width: SizeConfig.screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextWidget(
                text: name,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(
                height: 18.h,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (data[index].name == null) {
                      return SizedBox.shrink();
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: Utils.getValueBasedOnIndex(index, data.length),
                        ),
                        child: buildReviewersCard(data[index], name),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }

  Widget buildUser({required String name, required List<Creator> data}) {
    return Column(
      children: [
        Container(
          height: 160.h,
          width: SizeConfig.screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextWidget(
                text: name,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(
                height: 18.h,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: Utils.getValueBasedOnIndex(index, data.length),
                      ),
                      child: buildCreatorCard(data[index], name),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }

  Widget buildBusiness({required String name, required List<Business> data}) {
    return Column(
      children: [
        Container(
          height: 220.h, // Adjusted height for the section containing business cards
          width: SizeConfig.screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextWidget(
                text: name,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(
                height: 18.h,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: Utils.getValueBasedOnIndex(index, data.length),
                      ),
                      child: SizedBox(
                        height: 160.h, // Constrain the height of each business card item
                        child: buildBusinessCard(data[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget buildReviewersCard(Reviewer item, String name) {
    return GestureDetector(
      onTap: () {
        if (name == "Top Reviewers") {
          Navigator.pushNamed(
            context,
            RoutesName.reviewView,
            arguments: item.id,
          );
        }
      },
      child: Container(
        // width: 70.w,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: AppImageWidget(
                  isProfile: true,
                  height: 65.h,
                  width: 65.h,
                  iconSize: 70.sp,
                  imageUrl: item.userImage ?? '',
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              width: 65.h,
              child: AppTextWidget(
                text: "${item.name}",
                maxLines: 2,
                softWrap: true,
                textAlign: TextAlign.center,
                textOverflow: TextOverflow.ellipsis,
                fontSize: 12.sp,
              ),
            ),
            Container(
              width: 70.h,
              child: AppTextWidget(
                text: "${item.totalReviews} Reviews",
                maxLines: 2,
                softWrap: true,
                textAlign: TextAlign.center,
                textOverflow: TextOverflow.ellipsis,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCreatorCard(Creator item, String name) {
    return GestureDetector(
      onTap: () {
        AppDialog.showFullScreenDialog(
          Item(
            image: item.userImage,
            name: item.name,
            address: item.address,
            role: item.roleId == 2 ? "Business" : "Creator",
            isActive: item.isActive == 1 ? true : false,
          ),
        );
      },
      child: Container(
        // width: 80.w,
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: AppImageWidget(
                  isProfile: true,
                  iconSize: 70.sp,
                  height: 65.h,
                  width: 65.h,
                  imageUrl: item.userImage ?? '',
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              width: 65.h,
              child: AppTextWidget(
                text: "${item.name}",
                maxLines: 2,
                softWrap: true,
                textAlign: TextAlign.center,
                textOverflow: TextOverflow.ellipsis,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCard({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
    String? balance,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Container for Icon
          Container(
            padding: EdgeInsets.all(10.h),
            decoration: BoxDecoration(
              color: AppColor.primary.shade100,
              borderRadius: BorderRadius.circular(10.sp),
              // border: Border.all(color: AppColor.primary),
            ),
            child: Icon(
              icon,
              size: 25,
              color: AppColor.white,
            ),
          ),
          SizedBox(height: 8.h),
          // Title

          AppTextWidget(
            text: title,
            fontSize: 13.sp,
            color: AppColor.black,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          if (balance != null) ...[
            SizedBox(height: 4.h),
            AppTextWidget(
              text: balance,
              fontSize: 12,
              color: AppColor.activeGreen,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  AppBar _buildHomeAppBarWidget() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            child: Center(
              child: CircleAvatar(
                backgroundColor: AppColor.transparent,
                child: AppImageWidget(
                  height: 50,
                  width: 50,
                  isProfile: true,
                  fit: BoxFit.cover,
                  iconSize: 35,
                  imageUrl: viewModel.user?.image ?? "",
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTextWidget(
                  text: 'Welcome back!',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  textOverflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 5),
                AppTextWidget(
                  text: viewModel.user?.name ?? '',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  textOverflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, RoutesName.notificationView);
            clearNewNotificationFlag();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40, // Ensure circular shape
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.lightGrey,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.notifications, size: 24),
                ),
                if (viewModel.homeResponse.data?.data?.isPendingReviewFlag != null)
                  Positioned(
                    right: 10, // Adjust position of red dot
                    top: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
