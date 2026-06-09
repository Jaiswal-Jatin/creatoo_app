import 'dart:async';
import 'dart:ui';

import 'package:creatoo/widgets/custom_back_button.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core.dart';
import '../../../widgets/app_full_screen_image_view.dart';
import '../../../widgets/app_rating_progress_bar.dart';
import '../../../widgets/app_text_widget.dart';
import '../view_model/search_view_model.dart';
import '../widgets/category_details/restaurant_detail_widget.dart';
import '../widgets/category_details/salon_detail_widget.dart';
import '../widgets/category_details/turf_detail_widget.dart';

class BusinessDescriptionView extends StatefulWidget {
  final int businessId;
  const BusinessDescriptionView({super.key, required this.businessId});

  @override
  State<BusinessDescriptionView> createState() =>
      _BusinessDescriptionViewState();
}

class _BusinessDescriptionViewState extends State<BusinessDescriptionView> {
  late SearchViewModel viewModel;
  final PageController _businessPageController = PageController();
  final PageController _menuPageController = PageController();
  final PageController _goldPC = PageController();
  final PageController _silverPC = PageController();
  final PageController _bronzePC = PageController();

  int rating = 3;
  Timer? _carouselTimer;
  int _currentBusinessPage = 0;
  int _currentGoldPage = 0;
  int _currentSilverPage = 0;
  int _currentBronzePage = 0;

  // Selected details for Salon & Turf checkouts
  final List<Map<String, dynamic>> _selectedServices = [];



  Timer? _goldSliderTimer;
  Timer? _silverSliderTimer;
  Timer? _bronzeSliderTimer;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<SearchViewModel>(context, listen: false);
    viewModel.getBusinessDetailsApi(id: widget.businessId);
    viewModel.getExclusiveOffersApi(businessId: widget.businessId);
    _startAutoScroll();
    // Start auto-slide for all tier sliders
    _startTierSlidersAutoSlide();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _stopTierSlidersAutoSlide();
    _businessPageController.dispose();
    _menuPageController.dispose();
    _goldPC.dispose();
    _silverPC.dispose();
    _bronzePC.dispose();
    super.dispose();
  }

  void _startTierSlidersAutoSlide() {
    _goldSliderTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (!_goldPC.hasClients) return;
      final offers = viewModel.exclusiveOffersData;
      final count = 1 + (offers?.premiumOffers?.length ?? 0);
      final nextPage = ((_goldPC.page?.toInt() ?? 0) + 1) % count;
      _goldPC.animateToPage(nextPage, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    });

    _silverSliderTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (!_silverPC.hasClients) return;
      final offers = viewModel.exclusiveOffersData;
      final count = 1 + (offers?.eliteOffers?.length ?? 0);
      final nextPage = ((_silverPC.page?.toInt() ?? 0) + 1) % count;
      _silverPC.animateToPage(nextPage, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    });

    _bronzeSliderTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (!_bronzePC.hasClients) return;
      final offers = viewModel.exclusiveOffersData;
      final count = 1 + (offers?.coreOffers?.length ?? 0);
      final nextPage = ((_bronzePC.page?.toInt() ?? 0) + 1) % count;
      _bronzePC.animateToPage(nextPage, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  void _stopTierSlidersAutoSlide() {
    _goldSliderTimer?.cancel();
    _silverSliderTimer?.cancel();
    _bronzeSliderTimer?.cancel();
  }

  List<String> get businessImages {
    final List<String> images = [];
    final description = viewModel.businessDescription;

    if (description?.businessImage != null) {
      images.add(description!.businessImage!);
    }

    for (int i = 1; i <= 5; i++) {
      final url = description?.toJson()['business_image_$i'];
      if (url != null) images.add(url);
    }

    return images;
  }

  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_businessPageController.hasClients && businessImages.isNotEmpty) {
        int nextPage = _businessPageController.page!.round() + 1;

        if (nextPage >= businessImages.length) {
          _businessPageController.jumpToPage(0);
        } else {
          _businessPageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  String getBusinessStatus() {
    if (viewModel.businessDescription?.timeFrom != null &&
        viewModel.businessDescription?.timeTo != null) {
      TimeOfDay timeFrom = _parseTime(viewModel.businessDescription!.timeFrom!);
      TimeOfDay timeTo = _parseTime(viewModel.businessDescription!.timeTo!);
      TimeOfDay now = TimeOfDay.now();

      bool isOpen = _isWithinOperatingHours(now, timeFrom, timeTo);
      return isOpen ? "Open Now" : "Closed";
    }
    return "Closed";
  }

  bool _showPayBill() {
    final regularDiscount =
        viewModel.businessDescription?.setRegularDiscount ?? 0;
    final firstTimeDiscount =
        viewModel.businessDescription?.setFirstTimeDiscount ?? 0;

    debugPrint(
        "Checking Pay Bill: Regular=$regularDiscount, FirstTime=$firstTimeDiscount");

    return true; // Forced to true to ensure it shows for Goldfarm and all other businesses
  }

  bool _isWithinOperatingHours(TimeOfDay now, TimeOfDay from, TimeOfDay to) {
    int nowMinutes = now.hour * 60 + now.minute;
    int fromMinutes = from.hour * 60 + from.minute;
    int toMinutes = to.hour * 60 + to.minute;

    if (fromMinutes < toMinutes) {
      return nowMinutes >= fromMinutes && nowMinutes < toMinutes;
    } else {
      return nowMinutes >= fromMinutes || nowMinutes < toMinutes;
    }
  }

  TimeOfDay _parseTime(String time) {
    try {
      // First, try parsing as 24-hour format (HH:mm)
      if (!time.toLowerCase().contains('am') &&
          !time.toLowerCase().contains('pm')) {
        final parts = time.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null &&
              minute != null &&
              hour >= 0 &&
              hour < 24 &&
              minute >= 0 &&
              minute < 60) {
            return TimeOfDay(hour: hour, minute: minute);
          }
        }
      }

      // If that fails, try parsing as 12-hour format (hh:mm a)
      final DateFormat format = DateFormat("hh:mm a");
      final DateTime dateTime = format.parse(time);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      print("Error parsing time: $time - $e");
      return TimeOfDay(hour: 0, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<SearchViewModel>(context);

    if (viewModel.businessDetailsResponse.status == Status.loading ||
        viewModel.exclusiveOffersApiResponse.status == Status.loading) {
      return AppLoadingWidget();
    }

    if (viewModel.businessDetailsResponse.status == Status.error) {
      return AppErrorWidget(
          message: viewModel.businessDetailsResponse.message.toString());
    }

    if (viewModel.businessDetailsResponse.status == Status.completed) {
      return _buildBody();
    }

    return AppNoDataWidget();
  }

  Widget _buildBody() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: AppScaffold(
        isSafe: false,
        useGradient: true,
        backgroundColor: AppColor.premiumBg,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildImageWidget(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    child: _buildDescriptionWidget(),
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
            
            // Premium Back Button Overlay
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 16.w,
              child: CustomBackButton(
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildImageWidget() {
    return Stack(
      children: [
        SizedBox(
          height: 380.h,
          width: double.infinity,
          child: PageView.builder(
            controller: _businessPageController,
            itemCount: businessImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentBusinessPage = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageCarouselView(
                        imageUrls: businessImages,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: AppImageWidget(
                  imageUrl: businessImages[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),

        // Bottom Gradient Overlay for readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColor.premiumBg.withOpacity(0.8),
                  AppColor.premiumBg,
                ],
              ),
            ),
          ),
        ),

        // Slider Dots Overlay
        if (businessImages.length > 1)
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: _buildSliderDotsWidget(),
          ),
      ],
    );
  }

  Widget _buildSliderDotsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(businessImages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 6.h,
          width: _currentBusinessPage == index ? 24.w : 6.w,
          decoration: BoxDecoration(
            color: _currentBusinessPage == index
                ? AppColor.premiumAccent
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              if (_currentBusinessPage == index)
                BoxShadow(
                  color: AppColor.premiumAccent.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDescriptionWidget() {
    double avgExperience = double.tryParse(
            viewModel.businessDescription?.averageRatings?.avgExperience ??
                "0") ??
        0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Glassmorphic Info Card
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppTextWidget(
                          text: viewModel.businessDescription?.businessName ?? '',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      // Rating Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColor.mangoYellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColor.mangoYellow.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: AppColor.mangoYellow, size: 16.sp),
                            SizedBox(width: 4.w),
                            AppTextWidget(
                              text: avgExperience.toStringAsFixed(1),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.mangoYellow,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  
                  // Address
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppColor.premiumAccent, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: AppTextWidget(
                          text: viewModel.businessDescription?.businessAddress ?? '',
                          fontSize: 13.sp,
                          color: AppColor.premiumTextSecondary,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // Status and Pricing
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: getBusinessStatus() == "Open Now" 
                              ? AppColor.activeGreen.withOpacity(0.15) 
                              : Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: getBusinessStatus() == "Open Now" 
                                    ? AppColor.activeGreen 
                                    : Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            AppTextWidget(
                              text: getBusinessStatus().toUpperCase(),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: getBusinessStatus() == "Open Now" 
                                  ? AppColor.activeGreen 
                                  : Colors.redAccent,
                              letterSpacing: 0.5,
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(width: 12.w),
                      // // Pricing Range
                      // if (viewModel.businessDescription?.pricingRangeText != null)
                      //   AppTextWidget(
                      //     text: viewModel.businessDescription!.pricingRangeText!,
                      //     fontSize: 13.sp,
                      //     fontWeight: FontWeight.w600,
                      //     color: AppColor.premiumAccent,
                      //   ),
                    ],
                  ),
                  
                  if (viewModel.businessDescription?.timeFrom != null &&
                      viewModel.businessDescription?.timeTo != null)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: AppTextWidget(
                        text: "Timing: ${viewModel.businessDescription?.timeFrom} - ${viewModel.businessDescription?.timeTo}",
                        fontSize: 12.sp,
                        color: AppColor.premiumTextSecondary.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        _buildAssociatesSection(),
        _buildCategorySpecificDetails(),
        _buildTierFeatureSection(),
        
        if (viewModel.businessDescription?.totalReviews != null &&
            viewModel.businessDescription!.totalReviews! > 0)
          _buildRatingSummaryCard(),
      ],
    );
  }

  Widget _buildRatingSummaryCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.h),
        _buildSectionHeader("Customer Reviews"),
        SizedBox(height: 20.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: _buildRatingWidget(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextWidget(
          text: title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        SizedBox(height: 6.h),
        Container(
          height: 3,
          width: 40,
          decoration: BoxDecoration(
            color: AppColor.premiumAccent,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }



  Widget _buildRatingWidget() {
    final averageRatings = viewModel.businessDescription?.averageRatings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // First Column: Text Labels
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppTextWidget(
                  text: "Overall Experience",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                // SizedBox(height: 15),
                // AppTextWidget(
                //   text: "Expectation Match",
                //   fontSize: 14,
                //   fontWeight: FontWeight.w500,
                //   color: Colors.white,
                // ),
                // SizedBox(height: 15),
                // AppTextWidget(
                //   text: "Future Engagement",
                //   fontSize: 14,
                //   fontWeight: FontWeight.w500,
                //   color: Colors.white,
                // ),
              ],
            ),
            // Second Column: Star Ratings
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStarRating(
                    double.tryParse(averageRatings?.avgExperience ?? "0") ?? 0),
                // const SizedBox(height: 15),
                // _buildStarRating(
                //     double.tryParse(averageRatings?.avgExpectation ?? "0") ??
                //         0),
                // const SizedBox(height: 15),
                // _buildStarRating(
                //     double.tryParse(averageRatings?.avgInteraction ?? "0") ??
                //         0),
              ],
            ),

            // Third Column: Rating Numbers
            Column(
              children: [
                AppTextWidget(
                  text: "${averageRatings?.avgExperience ?? "0"}/5",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.premiumAccent,
                ),
                // SizedBox(height: 15),
                // AppTextWidget(
                //   text: "${averageRatings?.avgExpectation ?? "0"}/5",
                //   fontSize: 14,
                //   fontWeight: FontWeight.w600,
                //   color: AppColor.premiumAccent,
                // ),
                // SizedBox(height: 15),
                // AppTextWidget(
                //   text: "${averageRatings?.avgInteraction ?? "0"}/5",
                //   fontSize: 14,
                //   fontWeight: FontWeight.w600,
                //   color: AppColor.premiumAccent,
                // ),
              ],
            ),
          ],
        ),
        // SizedBox(height: 24.h),
        // AppTextWidget(
        //   text: "Recommendation Factor",
        //   fontWeight: FontWeight.w600,
        //   fontSize: 15,
        //   color: Colors.white,
        // ),
        // SizedBox(height: 12.h),
        // RatingProgressBar(
        //   percentage: double.tryParse(
        //           averageRatings?.avgRecommend?.replaceAll('%', '') ?? "0") ??
        //       0.0,
        // ),
        // SizedBox(height: 20.h),
        // AppTextWidget(
        //   text: "Value For Money",
        //   fontWeight: FontWeight.w600,
        //   fontSize: 15,
        //   color: Colors.white,
        // ),
        // SizedBox(height: 12.h),
        // RatingProgressBar(
        //   percentage: double.tryParse(
        //           averageRatings?.avgFairMoney?.replaceAll('%', '') ?? "0") ??
        //       0.0,
        // ),
      ],
    );
  }

// Helper function to generate stars
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star_rounded, color: AppColor.mangoYellow, size: 20);
        } else if (index < rating) {
          return const Icon(Icons.star_half_rounded, color: AppColor.mangoYellow, size: 20);
        } else {
          return const Icon(Icons.star_border_rounded,
              color: Colors.white24, size: 20);
        }
      }),
    );
  }

  Widget _buildAssociatesSection() {
    final associates = viewModel.businessDescription?.associates;
    if (associates == null || associates.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.h),
        _buildSectionHeader("Our Associates"),
        SizedBox(height: 20.h),
        SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: associates.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final associate = associates[index];
              return InkWell(
                onTap: () {
                  if (associate.id != null) {
                    Navigator.pushReplacementNamed(
                      context,
                      RoutesName.businessDescriptionView,
                      arguments: associate.id,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 140.w,
                  margin: EdgeInsets.only(right: 16.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AppImageWidget(
                          height: 100.h,
                          width: double.infinity,
                          imageUrl: associate.businessImage ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      AppTextWidget(
                        text: associate.businessName ?? "N/A",
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTierFeatureSection() {
    final exclusiveOffers = viewModel.exclusiveOffersData;

    final premiumOffers = [
      'assets/images/offers/premium.png',
      ...?exclusiveOffers?.premiumOffers
    ];
    final eliteOffers = [
      'assets/images/offers/elite.png',
      ...?exclusiveOffers?.eliteOffers
    ];
    final coreOffers = [
      'assets/images/offers/core.png',
      ...?exclusiveOffers?.coreOffers
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.h),
        _buildSectionHeader("Exclusive Offers"),
        SizedBox(height: 20.h),
        ListView(
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _buildTierItem(
              title: "Premium",
              gradientColors: AppColor.goldGradient,
              controller: _goldPC,
              images: premiumOffers,
              currentPage: _currentGoldPage,
              onPageChanged: (index) =>
                  setState(() => _currentGoldPage = index),
              iconPath: 'assets/icons/insurance.png',
            ),
            SizedBox(height: 16.h),

            _buildTierItem(
              title: "Elite",
              gradientColors: AppColor.silverGradient,
              controller: _silverPC,
              images: eliteOffers,
              currentPage: _currentSilverPage,
              onPageChanged: (index) =>
                  setState(() => _currentSilverPage = index),
              iconPath: 'assets/icons/insurance.png',
            ),
            SizedBox(height: 16.h),

            _buildTierItem(
              title: "Core",
              gradientColors: AppColor.bronzeGradient,
              controller: _bronzePC,
              images: coreOffers,
              currentPage: _currentBronzePage,
              onPageChanged: (index) =>
                  setState(() => _currentBronzePage = index),
              iconPath: 'assets/icons/insurance.png',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTierItem({
    required String title,
    required List<Color> gradientColors,
    required PageController controller,
    required List<String> images,
    required int currentPage,
    required Function(int) onPageChanged,
    required String iconPath,
  }) {
    if (images.isEmpty) return SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.0,
        ),
      ),
      child: Stack(
        children: [
          // Image Slider
          SizedBox(
            height: 160.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: PageView.builder(
                controller: controller,
                itemCount: images.length,
                onPageChanged: (index) {
                  onPageChanged(index);
                  _stopTierSlidersAutoSlide();
                  _startTierSlidersAutoSlide();
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageCarouselView(
                            imageUrls: images,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: images[index].startsWith('assets/')
                        ? Image.asset(
                            images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.white.withOpacity(0.05),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      gradientColors.first),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.white.withOpacity(0.05),
                              child: Icon(Icons.broken_image_rounded,
                                  color: Colors.white24),
                            ),
                          ),
                  );
                },
              ),
            ),
          ),

          // Glassmorphic Badge
          Positioned(
            top: 12.h,
            left: 12.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColors.first.withOpacity(0.8),
                        gradientColors.last.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        iconPath,
                        width: 16.w,
                        height: 16.w,
                        color: Colors.black,
                      ),
                      SizedBox(width: 6.w),
                      AppTextWidget(
                        text: title,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Dots indicator inside image
          if (images.length > 1)
            Positioned(
              bottom: 12.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: currentPage == index ? 16.w : 6.w,
                    height: 4.h,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!_showPayBill()) return null;

    final business = viewModel.businessDescription;
    final category = business?.businessCategory?.toLowerCase() ?? 'restaurant';
    final businessId = business?.id ?? 0;
    final businessName = business?.businessName ?? 'Business';
    final businessImage = business?.businessImage;

    void navigateToPayment({double? prefilled}) {
      Navigator.pushNamed(
        context,
        RoutesName.userPaymentSubmitView,
        arguments: {
          'businessId': businessId,
          'businessName': businessName,
          'businessImage': businessImage,
          'prefilledAmount': prefilled,
        },
      );
    }

    final rawServices = business?.categoryAttributes?['services'] as List?;
    final rawAmenities = business?.categoryAttributes?['amenities'] as List?;
    final rawSports = business?.categoryAttributes?['sport_types'] as List?;
    final List<dynamic>? filteredServices = (category == 'turf' && rawServices != null)
        ? rawServices.where((s) {
            final name = (s as Map)['name']?.toString().toLowerCase().trim() ?? '';
            
            // 1. Must NOT be an amenity
            final isAmenity = rawAmenities != null && rawAmenities.any((a) => a.toString().toLowerCase().trim() == name);
            if (isAmenity) return false;

            // 2. Must match supported sportTypes if specified
            if (rawSports != null && rawSports.isNotEmpty) {
              return rawSports.any((sport) {
                final sportLower = sport.toString().toLowerCase().trim();
                return name == sportLower || name.contains(sportLower);
              });
            }
            return true;
          }).toList()
        : rawServices;

    void navigateToBookingRequest() {
      Navigator.pushNamed(
        context,
        RoutesName.bookingRequestView,
        arguments: {
          'businessId': businessId,
          'businessName': businessName,
          'businessImage': businessImage,
          'businessCategory': category,
          'services': filteredServices,
        },
      );
    }

    if (category == 'salon') {
      final total = _selectedServices.fold<double>(0.0, (sum, item) => sum + (item['price'] as num).toDouble());
      final hasSelection = _selectedServices.isNotEmpty;
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: hasSelection
            ? AppButton(
                onTap: () {
                  final selectedNames = _selectedServices
                      .map((e) => e['name'] ?? e['title'] ?? '')
                      .where((n) => n.isNotEmpty)
                      .join(', ');
                  Navigator.pushNamed(
                    context,
                    RoutesName.bookingRequestView,
                    arguments: {
                      'businessId': businessId,
                      'businessName': businessName,
                      'businessImage': businessImage,
                      'businessCategory': category,
                      'prefilledService': selectedNames,
                      'services': filteredServices,
                    },
                  );
                },
                text: "Book Selected · ₹${total.toInt()}",
                icon: Icons.calendar_month_rounded,
                buttonColor: AppColor.premiumAccent,
              )
            : AppButton(
                onTap: () => navigateToPayment(),
                text: "Pay",
                icon: Icons.payments_rounded,
                buttonColor: const Color(0xFF27AA1A), // Vibrant Green theme
              ),
      );
    } else if (category == 'turf') {
      final total = _selectedServices.fold<double>(0.0, (sum, item) => sum + (item['price'] as num).toDouble());
      final hasSelection = _selectedServices.isNotEmpty;
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: hasSelection
            ? AppButton(
                onTap: () {
                  final selectedNames = _selectedServices
                      .map((e) => e['name'] ?? e['title'] ?? '')
                      .where((n) => n.isNotEmpty)
                      .join(', ');
                  Navigator.pushNamed(
                    context,
                    RoutesName.bookingRequestView,
                    arguments: {
                      'businessId': businessId,
                      'businessName': businessName,
                      'businessImage': businessImage,
                      'businessCategory': category,
                      'prefilledSport': selectedNames,
                      'services': filteredServices,
                    },
                  );
                },
                text: "Book Selected · ₹${total.toInt()}",
                icon: Icons.calendar_month_rounded,
                buttonColor: AppColor.premiumAccent,
              )
            : AppButton(
                onTap: () => navigateToPayment(),
                text: "Pay",
                icon: Icons.payments_rounded,
                buttonColor: const Color(0xFF27AA1A), // Vibrant Green theme
              ),
      );
    } else {
      // Restaurant Flow (Always 2 separate styled buttons)
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                onTap: () => navigateToPayment(),
                text: "Pay Now",
                icon: Icons.payments_rounded,
                buttonColor: const Color(0xFF27AA1A), // Vibrant Green theme
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AppButton(
                onTap: navigateToBookingRequest,
                text: "Book Request",
                icon: Icons.calendar_month_rounded,
                buttonColor: AppColor.premiumAccent, // Vibrant Neon Accent
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCategorySpecificDetails() {
    final business = viewModel.businessDescription;
    if (business == null) return const SizedBox.shrink();

    final category = business.businessCategory?.toLowerCase() ?? 'restaurant';
    switch (category) {
      case 'salon':
        return SalonDetailWidget(
          business: business,
          selectedServices: _selectedServices,
          onSelectionChanged: (updated) {
            setState(() {
              _selectedServices
                ..clear()
                ..addAll(updated);
            });
          },
        );
      case 'turf':
        return TurfDetailWidget(
          business: business,
          selectedServices: _selectedServices,
          onSelectionChanged: (updated) {
            setState(() {
              _selectedServices
                ..clear()
                ..addAll(updated);
            });
          },
        );
      case 'restaurant':
      default:
        return RestaurantDetailWidget(business: business);
    }
  }
}

