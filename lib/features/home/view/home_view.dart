import 'package:lottie/lottie.dart';
import 'dart:developer';
import '../../../core.dart';
import 'package:flutter/services.dart';
import 'package:creatoo/features/visits/repository/visits_repository.dart';
import 'package:creatoo/features/visits/model/visit_check_response_model.dart';
import '../../../../data/services/shared_preference_service.dart';
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
    final isBusiness = (roleId == Constants.businessUser);
    final w = MediaQuery.of(navigatorKey.currentContext!).size.width;
    final h = MediaQuery.of(navigatorKey.currentContext!).size.height;
    final isSmall = h < 700;
    
    return AppScaffold(
      appBar: _buildHomeAppBarWidget(),
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          vertical: isSmall ? h * 0.012 : 10.h,
          horizontal: isSmall ? w * 0.04 : 17.w,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
          
              (viewModel.homeResponse.data?.data?.banners == null || viewModel.homeResponse.data!.data!.banners!.isEmpty)
                  ? SizedBox.shrink()
                  : buildCarouselSlider(viewModel),
              SizedBox(height: isSmall ? h * 0.012 : 10.h),
              buildDotIndicator(viewModel),
              SizedBox(height: isSmall ? h * 0.012 : 10.h),
              Container(
                color: AppColor.transparent,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isBusiness = (roleId == Constants.businessUser);

                    return Container(
                      padding: EdgeInsets.symmetric(vertical: isSmall ? h * 0.025 : 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Button
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: isSmall ? w * 0.015 : 6.w),
                              child: _buildCustomCard(
                                icon: isBusiness ? 'assets/icons/qr-code.png' : 'assets/icons/qr-code.png',
                                isImage: true,
                                title: isBusiness ? "Show QR" : "Scan",
                                onPressed: () async {
                                  if (isBusiness) {
                                    // Navigate to new QR view that generates QR locally
                                    Navigator.pushNamed(
                                      context,
                                      RoutesName.businessQrView,
                                      arguments: {
                                        'businessId': userId ?? 0,
                                        'businessName': viewModel.user?.name ?? 'Business',
                                      },
                                    );
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
                              margin: EdgeInsets.symmetric(horizontal: isSmall ? w * 0.015 : 6.w),
                              child: _buildCustomCard(
                                icon: isBusiness ? Icons.location_on : 'assets/icons/credit-card.png',
                                isImage: !isBusiness,
                                title: isBusiness ? "Visit" : "Card",
                                onPressed: () {
                                  if (isBusiness) {
                                    // Check subscription before showing visit dialog
                                    if (viewModel.businessSubscription == null) {
                                      AppDialog.showSubscriptionRequiredDialog();
                                    } else {
                                      _showVisitDialog();
                                    }
                                  } else {
                                    // Navigate to cards screen in bottom nav
                                    Provider.of<HomeViewModel>(context, listen: false).changeIndex(2, false);
                                  }
                                },
                              ),
                            ),
                          ),
                          // Second Button
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: isSmall ? w * 0.015 : 6.w),
                              child: _buildCustomCard(
                                icon: isBusiness ? 'assets/icons/wallet.png' : 'assets/icons/wallet.png',
                                isImage: true,
                                title: isBusiness ? "Today's Settlement" : "Balance",
                                // Only show balance for creator, not for business
                                balance: isBusiness
                                    ? null  // Hide balance for business
                                    : "${viewModel.roundToTwoDecimalPlaces(viewModel.homeResponse.data?.data?.roleSpecificData?.userCreatooPoints?.toDouble() ?? 0.0).toCommaSeparated()}",
                                onPressed: () {
                                  if (isBusiness) {
                                    Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: false).changeIndex(2, false);
                                    businessWalletKey.currentState?.changeIndex(1);
                                  } else {
                                    Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: false).changeIndex(3, true);
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
              // Show Top Reviewers only for regular users
              (roleId != Constants.businessUser && viewModel.homeResponse.data!.data!.topReviewers!.isNotEmpty)
                  ? buildReviewers(name: "Top Reviewers", data: viewModel.homeResponse.data!.data!.topReviewers!)
                  : const SizedBox.shrink(),
              
              // Show Top Businesses for regular users, Lottie animation for business users
              (roleId == Constants.businessUser)
                  ? Builder(
                      builder: (context) {
                        final h = MediaQuery.of(context).size.height;
                        // 15% of screen height - adjusts automatically
                        final lottieHeight = h * 0.35;
                        
                        return Container(
                          height: lottieHeight,
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 0, top: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.transparent,
                          ),
                          child: Lottie.asset(
                            'assets/lottie/Main menu.json',
                            fit: BoxFit.contain,
                            repeat: true,
                            animate: true,
                          ),
                        );
                      },
                    )
                  : Column(
                      children: [
                        // Show Top Businesses for regular users
                        (viewModel.homeResponse.data!.data!.topBusiness == null || viewModel.homeResponse.data!.data!.topBusiness!.isEmpty)
                            ? const SizedBox.shrink()
                            : buildBusiness(name: "Top Businesses", data: viewModel.homeResponse.data!.data!.topBusiness!),
                        
                        // Show New Businesses for regular users
                        (viewModel.homeResponse.data!.data!.newBusiness == null || viewModel.homeResponse.data!.data!.newBusiness!.isEmpty)
                            ? const SizedBox.shrink()
                            : buildBusiness(name: "New Businesses", data: viewModel.homeResponse.data!.data!.newBusiness!),
                      ],
                    ),
                  
              // Show Recently Joined users
              viewModel.homeResponse.data!.data!.newCreator!.isEmpty
                  ? const SizedBox.shrink()
                  : buildUser(name: "Recently Joined", data: viewModel.homeResponse.data!.data!.newCreator!),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBusinessCard(Business item) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    
    // More granular responsive breakpoints for different screen sizes
    final isVerySmall = h < 600; // Very small iPhones (SE, Mini)
    final isSmall = h < 700 && !isVerySmall; // Small screens
    final isMedium = h >= 700 && h < 850; // Medium screens
    // Large screens are h >= 850
    
    // Calculate responsive values based on screen size
    double cardWidth;
    double imageHeight;
    double cardPadding;
    double titleFontSize;
    double discountFontSize;
    double borderRadius;
    
    if (isVerySmall) {
      cardWidth = w * 0.38;
      imageHeight = h * 0.08;
      cardPadding = 6;
      titleFontSize = 10.sp;
      discountFontSize = 7.sp;
      borderRadius = 12;
    } else if (isSmall) {
      cardWidth = w * 0.40;
      imageHeight = h * 0.09;
      cardPadding = 8;
      titleFontSize = 11.sp;
      discountFontSize = 8.sp;
      borderRadius = 14;
    } else if (isMedium) {
      cardWidth = w * 0.42;
      imageHeight = h * 0.10;
      cardPadding = 9;
      titleFontSize = 12.sp;
      discountFontSize = 9.sp;
      borderRadius = 15;
    } else {
      cardWidth = 180.w;
      imageHeight = 110.h;
      cardPadding = 10;
      titleFontSize = 14.sp;
      discountFontSize = 10.sp;
      borderRadius = 16;
    }
    
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutesName.businessDescriptionView,
          arguments: item.id,
        );
      },
      child: Container(
        width: cardWidth,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: AppColor.moreLighterDd.withOpacity(0.3),
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
            // Image with constrained height
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImageWidget(
                height: imageHeight,
                width: double.infinity,
                imageUrl: item.businessImage!,
              ),
            ),
            SizedBox(height: cardPadding * 0.5),
            // Title
            AppTextWidget(
              text: '${item.businessName}',
              textOverflow: TextOverflow.ellipsis,
              maxLines: 1,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
            ),
            if (item.set_first_time_discount != null) ...[
              SizedBox(height: cardPadding * 0.3),
              // Discount tag
              Container(
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.circular(borderRadius * 0.5),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardPadding * 0.8, 
                    vertical: cardPadding * 0.25
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: discountFontSize,
                        color: Colors.white,
                      ),
                      SizedBox(width: cardPadding * 0.3),
                      AppTextWidget(
                        text: '${item.set_first_time_discount}% OFF',
                        fontSize: discountFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    final h = MediaQuery.of(context).size.height;
    
    // More granular responsive breakpoints for different screen sizes
    final isVerySmall = h < 600; // Very small iPhones (SE, Mini)
    final isSmall = h < 700 && !isVerySmall; // Small screens
    final isMedium = h >= 700 && h < 850; // Medium screens
    // Large screens are h >= 850
    
    // Calculate responsive values based on screen size
    double sectionHeight;
    double cardHeight;
    double titleSpacing;
    double titleFontSize;
    double bottomSpacing;
    
    if (isVerySmall) {
      sectionHeight = h * 0.20;
      cardHeight = h * 0.14;
      titleSpacing = h * 0.008;
      titleFontSize = 14.sp;
      bottomSpacing = h * 0.012;
    } else if (isSmall) {
      sectionHeight = h * 0.22;
      cardHeight = h * 0.16;
      titleSpacing = h * 0.01;
      titleFontSize = 15.sp;
      bottomSpacing = h * 0.015;
    } else if (isMedium) {
      sectionHeight = h * 0.23;
      cardHeight = h * 0.17;
      titleSpacing = h * 0.012;
      titleFontSize = 17.sp;
      bottomSpacing = h * 0.018;
    } else {
      sectionHeight = 220.h;
      cardHeight = 160.h;
      titleSpacing = 18.h;
      titleFontSize = 18.sp;
      bottomSpacing = 20.h;
    }
    
    return Column(
      children: [
        Container(
          height: sectionHeight,
          width: SizeConfig.screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextWidget(
                text: name,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: titleSpacing),
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
                        height: cardHeight,
                        child: buildBusinessCard(data[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: bottomSpacing),
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
                fontWeight: FontWeight.w800,
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
                fontSize: 10.sp,
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
    required dynamic icon,
    required String title,
    required VoidCallback onPressed,
    String? balance,
    bool isImage = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Container for Icon/Image
          Container(
            padding: EdgeInsets.all(10.h),
            decoration: BoxDecoration(
              color: AppColor.primary.shade100,
              borderRadius: BorderRadius.circular(10.sp),
              // border: Border.all(color: AppColor.primary),
            ),
            child: isImage 
              ? Image.asset(
                  icon,
                  width: 35.w,
                  height: 35.h,
                  color: Colors.white,
                )
              : Icon(
                  icon,
                  size: 35.sp,
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

  // Helper method to get month name from month number
  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  void _showVerificationSuccessDialogWithData(VisitCheckResponse data) {
    final now = DateTime.now();
    final formattedDate = '${now.day} ${_getMonthName(now.month)}, ${now.year}';
    final formattedTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    showDialog(
      context: context,
      barrierDismissible: false, // must tap Done to dismiss
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie Animation
                Container(
                  width: 150.w,
                  height: 150.w,
                  child: Lottie.asset(
                    'assets/lottie/success confetti.json',
                    fit: BoxFit.contain,
                    repeat: false,
                  ),
                ),

                SizedBox(height: 16.h),

                // Success Message
                Text(
                  'Visit Verified!',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 4.h),

                // Subtitle
                Text(
                  'Customer details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.darkGrey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

                // User Details Card with Date & Time
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // User Avatar and Name
                      Row(
                        children: [
                          // User Avatar
                          Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.kPrimary.withOpacity(0.2),
                                width: 1.5,
                              ),
                              image: DecorationImage(
                                image: data.card?.userImage != null && data.card!.userImage!.isNotEmpty
                                    ? NetworkImage(data.card!.userImage!) as ImageProvider
                                    : AssetImage('assets/images/default_user.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          SizedBox(width: 12.w),

                          // User Name and Tier
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.card?.name ?? 'Customer',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFC000),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    // Map API tiers for display: gold/new -> PREMIUM, silver -> ELITE, bronze -> CORE
                                    (() {
                                      final raw = (data.tier ?? 'Tier').toString().toLowerCase();
                                      if (raw == 'gold' || raw == 'new' || raw == 'premium') return 'PREMIUM';
                                      if (raw == 'silver' || raw == 'elite') return 'ELITE';
                                      if (raw == 'bronze' || raw == 'core') return 'CORE';
                                      return raw.toUpperCase();
                                    })(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Divider(height: 24.h, color: Colors.grey[200]),

                      // Date and Time Section
                      Row(
                        children: [
                          // Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColor.darkGrey,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Vertical Divider
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[200],
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                          ),

                          // Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColor.darkGrey,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Done Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _callAddVisitAPI(String cardNumber, String token) {
    // Run in background without blocking UI
    Future.microtask(() async {
      try {
        print("📞 Calling addVisit API with card: $cardNumber");
        final repo = VisitsRepository();
        final result = await repo.addVisit(cardNumber, token);
        
        result.fold(
          (error) {
            print("❌ addVisit failed: ${error.message}");
          },
          (success) {
            print("✅ addVisit completed successfully - Status: ${success.status}, Message: ${success.message}");
          },
        );
      } catch (e, stacktrace) {
        print("❌ addVisit exception: $e");
        print("📍 Stacktrace: $stacktrace");
      }
    });
  }

  void _showVisitDialog() {
    final _formKey = GlobalKey<FormState>();
    // OTP controllers and focus nodes for 4-digit input
    final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
    final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
    

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Customer Code',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Customer Code',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Form content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter the customer code below',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.darkGrey,
                          height: 1.4,
                        ),
                      ),
                      
                      SizedBox(height: 16.h),

                      // OTP-style 4 digit input boxes
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: TextFormField(
                                  controller: _otpControllers[index],
                                  focusNode: _otpFocusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColor.lightGrey.withOpacity(0.5)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColor.kPrimary),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      if (index < 3) {
                                        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
                                      } else {
                                        _otpFocusNodes[index].unfocus();
                                      }
                                    } else if (value.isEmpty) {
                                      if (index > 0) FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
                                    }
                                  },
                                  validator: (val) {
                                    // We'll validate overall before submitting
                                    return null;
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: AppButton(
                          onTap: () async {
                            // validate OTP boxes: all 4 must have 1 digit
                            final code = _otpControllers.map((c) => c.text).join();
                            if (code.length != 4) {
                              // show validation error - enlarged
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (ctx) {
                                  Future.delayed(const Duration(milliseconds: 1200), () {
                                    if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
                                  });
                                  return AlertDialog(
                                    title: Text('Invalid Code', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                                    content: Text('Please enter a 4-digit customer code', style: TextStyle(fontSize: 16.sp)),
                                    contentPadding: EdgeInsets.all(20.w),
                                  );
                                },
                              );
                              return;
                            }
                            // keep dialog open while verifying
                            // show a simple loading indicator by replacing button with CircularProgressIndicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(child: CircularProgressIndicator()),
                            );
                            try {
                              final prefs = SharedPreferencesService();
                              final token = await prefs.getToken();
                              if (token == null) {
                                Navigator.of(context).pop(); // remove loader
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication token missing')));
                                return;
                              }
                              final repo = VisitsRepository();
                              final result = await repo.checkVisit(code, token);
                              Navigator.of(context).pop(); // remove loader
                              result.fold((l) {
                                // error - show an enlarged auto-dismissing dialog saying number is not valid
                                final errorMessage = l.message.isNotEmpty ? l.message : 'This number is not valid';
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (ctx) {
                                      Future.delayed(const Duration(milliseconds: 2000), () {
                                        if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
                                      });
                                    return Dialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      child: Padding(
                                        padding: EdgeInsets.all(24.w),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Close icon at top center
                                            Container(
                                              width: 50.w,
                                              height: 50.w,
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(Icons.close, color: Colors.red, size: 28.sp),
                                              ),
                                            ),
                                            SizedBox(height: 16.h),
                                            // Title
                                            Text('Not Found', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.red)),
                                            SizedBox(height: 12.h),
                                            // Message
                                            Text(errorMessage, style: TextStyle(fontSize: 16.sp, color: Colors.black87), textAlign: TextAlign.center),
                                            SizedBox(height: 20.h),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }, (visitResponse) {
                                // success - show verified popup with data
                                print("✅ VISITCHECK Success: Card ${visitResponse.card?.cardNumber}");
                                log("visitCheck success: ${visitResponse.card?.name}");
                                
                                // Call addVisit API with card number
                                _callAddVisitAPI(code, token);
                                
                                Navigator.of(context).pop(); // close the input dialog
                                Future.delayed(const Duration(milliseconds: 150), () {
                                  _showVerificationSuccessDialogWithData(visitResponse);
                                });
                              });
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          },
                          text: 'Verify Code',
                          buttonColor: AppColor.kPrimary,
                          textColor: Colors.white,
                          height: 48.h,
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // Help Text
                      Center(
                        child: Text(
                          'Ask the customer for their unique code',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.lighterDd,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
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
                  iconSize: 35.sp,
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
