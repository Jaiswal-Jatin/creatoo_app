import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:creatoo/features/home/model/home_screen_response_model.dart';
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
    // Only init and show loading if data is not already loaded
    if (viewModel.homeResponse.status != Status.completed) {
      viewModel.init();
    }
  }

  void clearNewNotificationFlag() {
    hasNewNotification = false;
  }

  Map<String, dynamic> _getBusinessTheme(Business item) {
    final name = item.businessName?.toLowerCase() ?? "";
    if (name.contains("salon") ||
        name.contains("spa") ||
        name.contains("beauty")) {
      return {"icon": Icons.content_cut, "color": Color(0xFFE91E63)};
    }
    if (name.contains("turf") ||
        name.contains("football") ||
        name.contains("cricket")) {
      return {"icon": Icons.sports_soccer, "color": Color(0xFF4CAF50)};
    }
    if (name.contains("cafe") ||
        name.contains("restaurant") ||
        name.contains("food")) {
      return {"icon": Icons.restaurant, "color": Color(0xFFFF5722)};
    }
    if (name.contains("gym") || name.contains("fitness")) {
      return {"icon": Icons.fitness_center, "color": Color(0xFF009688)};
    }

    // Alt fallback logic to show variety
    final id = item.id ?? 0;
    if (id % 3 == 0)
      return {"icon": Icons.restaurant, "color": Color(0xFFFF5722)};
    if (id % 3 == 1)
      return {"icon": Icons.content_cut, "color": Color(0xFFE91E63)};
    return {"icon": Icons.sports_soccer, "color": Color(0xFF4CAF50)};
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<HomeViewModel>(context);
    switch (viewModel.homeResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.homeResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    final w = MediaQuery.of(navigatorKey.currentContext!).size.width;
    final h = MediaQuery.of(navigatorKey.currentContext!).size.height;
    final isSmall = h < 700;
    final bool isBusiness = roleId == Constants.businessUser;

    return AppScaffold(
      useGradient: false,
      backgroundColor: Colors.transparent, // Let parent background show through
      extendBody: true,
      isSafe: false, // Prevents SafeArea from creating a black bar at the bottom
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h),
        // No root margin for edge-to-edge flow

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Restored Original Premium Header
              _buildPremiumHeader(),
              
              SizedBox(height: 12.h),
              
              // 2. Original Carousel
              /*
              (viewModel.homeResponse.data?.data?.banners == null ||
                      viewModel.homeResponse.data!.data!.banners!.isEmpty)
                  ? SizedBox.shrink()
                  : Column(
                      children: [
                        buildCarouselSlider(viewModel),
                        SizedBox(height: isSmall ? h * 0.012 : 10.h),
                        buildDotIndicator(viewModel),
                      ],
                    ),
              */
              
              SizedBox(height: 15.h),
              
              // 3. Restored Original Category Filters (With Icons)
              _buildCategoryFilters(),
              
              SizedBox(height: 15.h),
              
              // 4. Wallet Card & Actions (Original)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 72,
                      child: _buildWalletBalanceCard(),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 28,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSidebarAction(
                            title: isBusiness ? "Show QR" : "Scan",
                            icon: isBusiness ? Icons.qr_code_2 : Icons.qr_code_scanner,
                            color: Color(0xFF9759C4),
                            onTap: () {
                              if (isBusiness) {
                                Navigator.pushNamed(context, RoutesName.businessQrView,
                                    arguments: {
                                      'businessId': userId ?? 0,
                                      'businessName': viewModel.user?.name ?? 'Business'
                                    });
                              } else {
                                Navigator.pushNamed(context, RoutesName.qrScannerView);
                              }
                            },
                          ),
                          SizedBox(height: 12.h),
                          _buildSidebarAction(
                            title: isBusiness ? "Visit" : "Card",
                            icon: isBusiness ? Icons.location_on_outlined : Icons.credit_card,
                            color: Color(0xFF2196F3),
                            onTap: () {
                              if (isBusiness) {
                                if (viewModel.businessSubscription == null) {
                                  AppDialog.showSubscriptionRequiredDialog();
                                } else {
                                  _showVisitDialog();
                                }
                              } else {
                                Provider.of<HomeViewModel>(context, listen: false).changeIndex(2, false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 15.h),
              
              // 5. User Specific Logic & Top Reviewers (Original)
              if (roleId != Constants.businessUser &&
                  viewModel.homeResponse.data!.data!.topReviewers!.isNotEmpty)
                buildReviewers(
                    name: "Top Reviewers",
                    data: viewModel.homeResponse.data!.data!.topReviewers!),

              // SizedBox(height: 10.h),

              // 6. NEW Consolidated Business Section (Match Image UI here)
              if (roleId != Constants.businessUser)
                _buildCombinedBusinessSection(),

              if (viewModel.homeResponse.data!.data!.newCreator!.isNotEmpty)
                buildUser(
                    name: "Recently Joined",
                    data: viewModel.homeResponse.data!.data!.newCreator!),
              
              SizedBox(height: 100.h), 
            ],
          ),
        ),
      
    ));
  }


  Widget _buildModernSearch() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColor.premiumTextSecondary, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: AppTextWidget(
              text: "Search for 'Ek Din'",
              fontSize: 14.sp,
              color: AppColor.premiumTextSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCategoryPills() {
    final categories = ["For you", "Dining", "Events", "Movies", "Stores"];
    return Container(
      height: 40.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 17.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 0; // Defaulting first to isSelected per image
          return Container(
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.premiumAccent.withOpacity(0.8) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: AppTextWidget(
                text: categories[index],
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColor.premiumTextSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white.withOpacity(0.2), thickness: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: AppTextWidget(
              text: title.toUpperCase(),
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.premiumTextSecondary,
              letterSpacing: 2.0,
            ),
          ),
          Expanded(child: Divider(color: Colors.white.withOpacity(0.2), thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildCombinedBusinessSection() {
    // Consolidation: Combine Top and New businesses
    final List<Business> allBusinesses = [
      ...(viewModel.homeResponse.data?.data?.topBusiness ?? <Business>[]),
      ...(viewModel.homeResponse.data?.data?.newBusiness ?? <Business>[]),
    ].where((b) => b.isActive == 1).toList().cast<Business>();


    if (allBusinesses.isEmpty) return SizedBox.shrink();

    return Column(
      children: [
        _buildCustomSectionHeader("Plan Your Visit"),
        SizedBox(height: 8.h),
        Container(
          height: 400.h, // Scaled down from 480
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            itemCount: allBusinesses.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: _buildLargeBusinessCard(allBusinesses[index]),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        // Simple dot indicator for the carousel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            (allBusinesses.length > 5 ? 5 : allBusinesses.length), 
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: index == 0 ? 12.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: index == 0 ? AppColor.white : AppColor.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            )
          ),
        ),
        SizedBox(height: 30.h),
        _buildCustomSectionHeader("Steal of the week"),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildLargeBusinessCard(Business item) {
    int? displayDiscount = item.discount_type == "regular" 
        ? item.set_regular_discount 
        : item.set_first_time_discount;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutesName.businessDescriptionView,
          arguments: item.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Large Image
              Expanded(
                flex: 75,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImageWidget(
                      imageUrl: item.businessImage ?? '',
                      fit: BoxFit.cover,
                    ),
                    // Offers Overlay Bar (The purple bar at bottom of image)
                    if (displayDiscount != null && displayDiscount > 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2E095C), 
                                AppColor.premiumAccent.withOpacity(0.9)
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_offer, size: 16.sp, color: Colors.white),
                              SizedBox(width: 10.w),
                              AppTextWidget(
                                text: "Flat $displayDiscount% OFF • Book Now",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // 2. Business Details
              Expanded(
                flex: 25,
                child: Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextWidget(
                              text: item.businessName ?? '',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              maxLines: 1,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFD700).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Color(0xFFFFD700), size: 12.sp),
                                SizedBox(width: 4.w),
                                AppTextWidget(
                                  text: "4.8", 
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFD700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12.sp, color: AppColor.premiumTextSecondary),
                          SizedBox(width: 4.w),
                          AppTextWidget(
                            text: '${item.businessArea ?? 'Pune'} • ',
                            fontSize: 12.sp,
                            color: AppColor.premiumTextSecondary,
                          ),
                          Icon(Icons.category, size: 12.sp, color: AppColor.premiumAccent),
                          SizedBox(width: 4.w),
                          AppTextWidget(
                            text: "Salon & Spa", // Categories are now visible
                            fontSize: 12.sp,
                            color: AppColor.premiumAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
      cardWidth = w * 0.42; // Increased from 0.38
      imageHeight = h * 0.08;
      cardPadding = 6;
      titleFontSize = 12.sp;
      discountFontSize = 11.sp;
      borderRadius = 12;
    } else if (isSmall) {
      cardWidth = w * 0.45; // Increased from 0.40
      imageHeight = h * 0.09;
      cardPadding = 8;
      titleFontSize = 13.sp;
      discountFontSize = 12.sp;
      borderRadius = 14;
    } else if (isMedium) {
      cardWidth = w * 0.48; // Increased from 0.42
      imageHeight = h * 0.11;
      cardPadding = 9;
      titleFontSize = 14.sp;
      discountFontSize = 13.sp;
      borderRadius = 15;
    } else {
      cardWidth = 200.w; // Increased from 180.w
      imageHeight = 115.h;
      cardPadding = 10;
      titleFontSize = 16.sp;
      discountFontSize = 14.sp;
      borderRadius = 16;
    }
    int? displayDiscount;

    if (item.discount_type == "regular") {
      displayDiscount = item.set_regular_discount;
    } else {
      // Default to first_time if type is first_time or null
      displayDiscount = item.set_first_time_discount;
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: AppColor.premiumCardBg,
          border: Border.all(
            color: AppColor.premiumAccent.withOpacity(0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.premiumAccent.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Subtle Inner Glass Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Top Reflective Line
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with constrained height and Discount Overlay
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius - 4),
                          child: AppImageWidget(
                            height: imageHeight,
                            width: double.infinity,
                            imageUrl: item.businessImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (displayDiscount != null && displayDiscount > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColor
                                    .mangoYellow, // Matching top reviewers rank badge
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_offer,
                                      size: 10.sp, color: Colors.black),
                                  SizedBox(width: 4.w),
                                  AppTextWidget(
                                    text: '${displayDiscount}% OFF',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: cardPadding * 1.0),
                    // Title Row with Category Icon
                    Row(
                      children: [
                        Expanded(
                          child: AppTextWidget(
                            text: '${item.businessName}',
                            textOverflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w700,
                            color: AppColor.premiumTextPrimary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // Category-specific theme icon
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _getBusinessTheme(item)["color"]
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getBusinessTheme(item)["icon"],
                              color: _getBusinessTheme(item)["color"],
                              size: 16.sp // Increased further from 14.sp
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Location as fallback if no discount (with effect color)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 11.sp,
                            color:
                                AppColor.premiumTextSecondary.withOpacity(0.7)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: AppTextWidget(
                            text: item.businessArea ?? 'Pune',
                            fontSize: 10.sp,
                            color:
                                AppColor.premiumTextSecondary.withOpacity(0.7),
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildDotIndicator(HomeViewModel homeViewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          homeViewModel.homeResponse.data!.data!.banners!.asMap().entries.map(
        (entry) {
          bool isActive = homeViewModel.position == entry.key;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 20.w : 6.w,
            height: 6.h,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isActive
                  ? AppColor.premiumAccent
                  : AppColor.premiumTextSecondary.withOpacity(0.2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColor.premiumAccent.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
          );
        },
      ).toList(),
    );
  }

  CarouselSlider buildCarouselSlider(HomeViewModel homeViewModel) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160.0.h,
        autoPlay: true,
        enlargeCenterPage: false,
        enableInfiniteScroll: true,
        aspectRatio: 16 / 9,
        viewportFraction: 1.0,
        autoPlayCurve: Curves.fastOutSlowIn,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) =>
            homeViewModel.updateBannerIndex(index),
      ),
      carouselController: homeViewModel.controller,
      items: homeViewModel.homeResponse.data!.data!.banners!.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                homeViewModel.launchBannerUrl(item.link);
              },
              child: Container(
                width: SizeConfig.screenWidth,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Transform.scale(
                        scale: 1.02, // Subtle zoom as requested
                        child: AppImageWidget(
                          imageUrl: item.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    // Enhanced Glassy Overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: const [0.0, 0.4, 0.6, 1.0],
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.02),
                            Colors.black.withOpacity(0.02),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    // Reflective Gloss Line
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
          color: AppColor.premiumTextPrimary,
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
                    child: Image.asset(
                        height: 120.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        Images.appLogo),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8)),
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
                    AppTextWidget(
                        text: 'Coming Soon...',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.white),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: AppTextWidget(
                  text: name,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.premiumTextPrimary,
                ),
              ),

              SizedBox(
                height: 18.h,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 17.w),
                  itemBuilder: (context, index) {
                    if (data[index].name == null) {
                      return SizedBox.shrink();
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: Utils.getValueBasedOnIndex(index, data.length),
                        ),
                        child: buildReviewersCard(data[index], name, index + 1),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: AppTextWidget(
                  text: name,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.premiumTextPrimary,
                ),
              ),

              SizedBox(
                height: 18.h,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 17.w),
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
      sectionHeight = h * 0.20; // Increased to fix overflow
      cardHeight = h * 0.16; // Increased to fix overflow
      titleSpacing = h * 0.005;
      titleFontSize = 14.sp;
      bottomSpacing = h * 0.005;
    } else if (isSmall) {
      sectionHeight = h * 0.22; // Increased to fix overflow
      cardHeight = h * 0.18; // Increased to fix overflow
      titleSpacing = h * 0.006;
      titleFontSize = 15.sp;
      bottomSpacing = h * 0.008;
    } else if (isMedium) {
      sectionHeight = h * 0.24; // Increased to fix overflow
      cardHeight = h * 0.20; // Increased to fix overflow
      titleSpacing = h * 0.008;
      titleFontSize = 16.sp;
      bottomSpacing = h * 0.01;
    } else {
      sectionHeight = 220.h; // Increased from 190 to fix overflow
      cardHeight = 195.h; // Increased from 165 to fix overflow
      titleSpacing = 8.h;
      titleFontSize = 18.sp;
      bottomSpacing = 10.h;
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
                text: name.toUpperCase(),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.premiumTextPrimary,
                letterSpacing: 0.5,
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

  Widget buildReviewersCard(Reviewer item, String name, int rank) {
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
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColor.premiumAccent.withOpacity(0.3),
                        width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: AppImageWidget(
                      isProfile: true,
                      height: 65.h,
                      width: 65.h,
                      fit: BoxFit.cover,
                      iconSize: 50.sp,
                      imageUrl: item.userImage ?? '',
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColor.mangoYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppTextWidget(
                      text: "#$rank",
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              width: 65.h,
              child: AppTextWidget(
                text: "${item.name}",
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.premiumTextPrimary,
                textAlign: TextAlign.center,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
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
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColor.premiumAccent.withOpacity(0.3), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: AppImageWidget(
                  isProfile: true,
                  height: 65.h,
                  width: 65.h,
                  iconSize: 50.sp,
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
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.premiumTextPrimary,
                textAlign: TextAlign.center,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
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
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  void _showVerificationSuccessDialogWithData(VisitCheckResponse data) {
    final now = DateTime.now();
    final formattedDate = '${now.day} ${_getMonthName(now.month)}, ${now.year}';
    final formattedTime =
        '${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

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
                                image: data.card?.userImage != null &&
                                        data.card!.userImage!.isNotEmpty
                                    ? NetworkImage(data.card!.userImage!)
                                        as ImageProvider
                                    : AssetImage(
                                        'assets/images/default_user.png'),
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 4.h),
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
                                      final raw = (data.tier ?? 'Tier')
                                          .toString()
                                          .toLowerCase();
                                      if (raw == 'gold' ||
                                          raw == 'new' ||
                                          raw == 'premium') return 'PREMIUM';
                                      if (raw == 'silver' || raw == 'elite')
                                        return 'ELITE';
                                      if (raw == 'bronze' || raw == 'core')
                                        return 'CORE';
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

  // Check if customer visited within last 6 hours
  bool _hasRecentVisit(List<VisitHistoryItem>? visitHistory) {
    if (visitHistory == null || visitHistory.isEmpty) return false;

    final now = DateTime.now();
    for (var visit in visitHistory) {
      if (visit.time != null) {
        try {
          final visitTime = DateTime.parse(visit.time!);
          final difference = now.difference(visitTime);
          if (difference.inHours < 1) {
            return true;
          }
        } catch (e) {
          print("❌ Error parsing visit time: ${visit.time}");
        }
      }
    }
    return false;
  }

  // Get next allowed visit time (most recent visit + 6 hours)
  DateTime? _getNextAllowedVisitTime(List<VisitHistoryItem>? visitHistory) {
    if (visitHistory == null || visitHistory.isEmpty) return null;

    DateTime? mostRecentVisit;
    for (var visit in visitHistory) {
      if (visit.time != null) {
        try {
          final visitTime = DateTime.parse(visit.time!);
          if (mostRecentVisit == null || visitTime.isAfter(mostRecentVisit)) {
            mostRecentVisit = visitTime;
          }
        } catch (e) {
          print("❌ Error parsing visit time: ${visit.time}");
        }
      }
    }
    return mostRecentVisit?.add(const Duration(hours: 1));
  }

  // Show dialog when customer has already visited within 6 hours
  void _showAlreadyVisitedDialog(String customerName, DateTime nextVisitTime) {
    final now = DateTime.now();
    final difference = nextVisitTime.difference(now);
    final hoursRemaining = difference.inHours;
    final minutesRemaining = difference.inMinutes % 60;

    // Format next visit time
    final formattedTime =
        '${nextVisitTime.hour}:${nextVisitTime.minute.toString().padLeft(2, '0')} ${nextVisitTime.hour >= 12 ? 'PM' : 'AM'}';
    final formattedDate =
        '${nextVisitTime.day} ${_getMonthName(nextVisitTime.month)}, ${nextVisitTime.year}';

    showDialog(
      context: context,
      barrierDismissible: true,
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
                // Warning Icon
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.access_time_rounded,
                      color: Colors.orange,
                      size: 45.sp,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Title
                Text(
                  'Already Visited',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12.h),

                // Message
                Text(
                  'This customer has already visited recently.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.darkGrey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20.h),

                // Next Visit Time Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Next visit allowed in',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.darkGrey,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${hoursRemaining}h ${minutesRemaining}m',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '$formattedDate at $formattedTime',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColor.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK',
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
            print(
                "✅ addVisit completed successfully - Status: ${success.status}, Message: ${success.message}");
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
    final List<TextEditingController> _otpControllers =
        List.generate(4, (_) => TextEditingController());
    final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Customer Code',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
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
                                  style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w700),
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14.h),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColor.lightGrey
                                              .withOpacity(0.5)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColor.kPrimary),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1)
                                  ],
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      if (index < 3) {
                                        FocusScope.of(context).requestFocus(
                                            _otpFocusNodes[index + 1]);
                                      } else {
                                        _otpFocusNodes[index].unfocus();
                                      }
                                    } else if (value.isEmpty) {
                                      if (index > 0)
                                        FocusScope.of(context).requestFocus(
                                            _otpFocusNodes[index - 1]);
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
                            final code =
                                _otpControllers.map((c) => c.text).join();
                            if (code.length != 4) {
                              // show validation error - enlarged
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (ctx) {
                                  Future.delayed(
                                      const Duration(milliseconds: 1200), () {
                                    if (Navigator.of(ctx).canPop())
                                      Navigator.of(ctx).pop();
                                  });
                                  return AlertDialog(
                                    title: Text('Invalid Code',
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w700)),
                                    content: Text(
                                        'Please enter a 4-digit customer code',
                                        style: TextStyle(fontSize: 16.sp)),
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
                              builder: (ctx) => const Center(
                                  child: CircularProgressIndicator()),
                            );
                            try {
                              final prefs = SharedPreferencesService();
                              final token = await prefs.getToken();
                              if (token == null) {
                                Navigator.of(context).pop(); // remove loader
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Authentication token missing')));
                                return;
                              }
                              final repo = VisitsRepository();
                              final result = await repo.checkVisit(code, token);
                              Navigator.of(context).pop(); // remove loader
                              result.fold((l) {
                                // error - show an enlarged auto-dismissing dialog saying number is not valid
                                final errorMessage = l.message.isNotEmpty
                                    ? l.message
                                    : 'This number is not valid';
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (ctx) {
                                    Future.delayed(
                                        const Duration(milliseconds: 2000), () {
                                      if (Navigator.of(ctx).canPop())
                                        Navigator.of(ctx).pop();
                                    });
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
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
                                                color:
                                                    Colors.red.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(Icons.close,
                                                    color: Colors.red,
                                                    size: 28.sp),
                                              ),
                                            ),
                                            SizedBox(height: 16.h),
                                            // Title
                                            Text('Not Found',
                                                style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.red)),
                                            SizedBox(height: 12.h),
                                            // Message
                                            Text(errorMessage,
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.black87),
                                                textAlign: TextAlign.center),
                                            SizedBox(height: 20.h),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }, (visitResponse) {
                                // success - check if customer visited within 6 hours
                                print(
                                    "✅ VISITCHECK Success: Card ${visitResponse.card?.cardNumber}");
                                log("visitCheck success: ${visitResponse.card?.name}");

                                // Check for 6-hour restriction
                                if (_hasRecentVisit(
                                    visitResponse.visitHistory)) {
                                  // Customer already visited within 6 hours
                                  final nextVisitTime =
                                      _getNextAllowedVisitTime(
                                          visitResponse.visitHistory);
                                  Navigator.of(context)
                                      .pop(); // close the input dialog
                                  Future.delayed(
                                      const Duration(milliseconds: 150), () {
                                    _showAlreadyVisitedDialog(
                                      visitResponse.card?.name ?? 'Customer',
                                      nextVisitTime ??
                                          DateTime.now()
                                              .add(const Duration(hours: 1)),
                                    );
                                  });
                                } else {
                                  // No recent visit - proceed with adding visit
                                  _callAddVisitAPI(code, token);
                                  Navigator.of(context)
                                      .pop(); // close the input dialog
                                  Future.delayed(
                                      const Duration(milliseconds: 150), () {
                                    _showVerificationSuccessDialogWithData(
                                        visitResponse);
                                  });
                                }
                              });
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')));
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

  Widget _buildPremiumHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                child: CircleAvatar(
                  backgroundColor: AppColor.premiumCardBg,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AppImageWidget(
                      height: 46,
                      width: 46,
                      isProfile: true,
                      fit: BoxFit.cover,
                      iconSize: 24.sp,
                      imageUrl: viewModel.user?.image ?? "",
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColor.premiumBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.verified,
                      color: AppColor.premiumAccent, size: 14),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  text: _getGreetingText(),
                  fontSize: 11.sp,
                  color: AppColor.premiumTextSecondary,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Flexible(
                      child: AppTextWidget(
                        text: viewModel.user?.name ?? '',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.premiumTextPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Stylized Premium Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColor.mangoYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColor.mangoYellow.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "👑",
                      style: TextStyle(fontSize: 8.sp),
                    ),
                    SizedBox(width: 4),
                    AppTextWidget(
                      text: "PREMIUM",
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColor.mangoYellow,
                      letterSpacing: 0.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildHeaderIcon(Icons.search, () {
          Provider.of<HomeViewModel>(context, listen: false).changeIndex(1, false);
        }),
        SizedBox(width: 10.w),
        _buildHeaderIcon(Icons.notifications_none_outlined, () {
          Navigator.pushNamed(context, RoutesName.notificationView);
          clearNewNotificationFlag();
        },
            hasBadge:
                viewModel.homeResponse.data?.data?.isPendingReviewFlag != null),
      ],
    ));
  }

  String _getGreetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap,
      {bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppColor.premiumTextPrimary, size: 20.sp),
            if (hasBadge)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.premiumBg, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildWalletBalanceCard() {
    return GestureDetector(
      onTap: () {
        Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: false)
            .changeIndex(3, true);
      },
      child: Container(
        height: 132.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E095C), 
              Color(0xFF1A1A1A), 
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2E095C).withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextWidget(
                              text: "TOTAL POINTS",
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 1.5,
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AppTextWidget(
                            text: "WALLET",
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextWidget(
                              text: "${viewModel.homeResponse.data?.data?.roleSpecificData?.userCreatooPoints ?? 0}",
                              fontSize: 34.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            AppTextWidget(
                              text: "CREATOO PTS",
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.premiumAccent,
                              letterSpacing: 1.2,
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 4.h),
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColor.activeGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.trending_up, color: AppColor.activeGreen, size: 12.sp),
                              SizedBox(width: 4.w),
                              AppTextWidget(
                                text: "2.5%",
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColor.activeGreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarAction(
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 10.w),
            AppTextWidget(
              text: title.toUpperCase(),
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.premiumTextPrimary,
              letterSpacing: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 4,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.premiumCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.premiumBorder, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8.h),
            AppTextWidget(
              text: title,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.premiumTextPrimary,
              textAlign: TextAlign.center,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCategoryFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 17.w),
          child: AppTextWidget(
            text: "EXPLORE CATEGORIES",
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 18.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 17.w), // Flush to edges but starts correctly
          child: Row(
            children: [
              _buildFilterItem("Restaurants", Icons.restaurant_menu, Color(0xFFFF5722)),
              _buildFilterItem("Salon", Icons.content_cut, Color(0xFFE91E63)),
              _buildFilterItem("Turf", Icons.sports_soccer, Color(0xFF4CAF50)),
              _buildFilterItem("Bookings", Icons.event_note, Color(0xFFFFC107)),
              _buildFilterItem("Events", Icons.event_available, Color(0xFF009688)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterItem(String title, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColor.premiumCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(child: Icon(icon, color: color, size: 26.sp)),
          ),
          SizedBox(height: 5.h),
          AppTextWidget(
            text: title,
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.premiumTextSecondary,
          ),
        ],
      ),
    );
  }

  AppBar _buildHomeAppBarWidget() {
    return AppBar();
  }
}
