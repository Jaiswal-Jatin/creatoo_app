import 'dart:async';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core.dart';
import '../../../widgets/app_full_screen_image_view.dart';
import '../../../widgets/app_rating_progress_bar.dart';
import '../../../widgets/app_text_widget.dart';
import '../view_model/search_view_model.dart';

class BusinessDescriptionView extends StatefulWidget {
  final int businessId;
  const BusinessDescriptionView({super.key, required this.businessId});

  @override
  State<BusinessDescriptionView> createState() => _BusinessDescriptionViewState();
}

class _BusinessDescriptionViewState extends State<BusinessDescriptionView> {
  late SearchViewModel viewModel;
  int rating = 3;
  Timer? _carouselTimer;
  final PageController _businessPageController = PageController();
  final PageController _menuPageController = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<SearchViewModel>(context, listen: false);
    viewModel.getBusinessDetailsApi(id: widget.businessId);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _businessPageController.dispose();
    _menuPageController.dispose();
    super.dispose();
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
    if (viewModel.businessDescription?.timeFrom != null && viewModel.businessDescription?.timeTo != null) {
      TimeOfDay timeFrom = _parseTime(viewModel.businessDescription!.timeFrom!);
      TimeOfDay timeTo = _parseTime(viewModel.businessDescription!.timeTo!);
      TimeOfDay now = TimeOfDay.now();

      bool isOpen = _isWithinOperatingHours(now, timeFrom, timeTo);
      return isOpen ? "Open Now" : "Closed";
    }
    return "Closed";
  }

  bool _showPayBill() {
    if (viewModel.businessDescription?.setRegularDiscount == null ||
        viewModel.businessDescription?.setFirstTimeDiscount == null ||
        viewModel.businessDescription!.setRegularDiscount! <= 0 ||
        viewModel.businessDescription!.setFirstTimeDiscount! <= 0) {
      return false;
    } else {
      return true;
    }
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

    switch (viewModel.businessDetailsResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.businessDetailsResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: AppScaffold(
        isSafe: false,
        useGradient: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Stack(
                  fit: StackFit.loose,
                  clipBehavior: Clip.none,
                  children: [
                    _buildImageWidget(),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -0.5,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          border: Border.all(color: AppColor.white),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: _buildSliderDotsWidget(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: _buildDescriptionWidget(),
              ),
              SizedBox(
                height: 80.h,
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: (_showPayBill()) ? FloatingActionButtonLocation.centerFloat : null,
        floatingActionButton: (_showPayBill())
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppButton(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RoutesName.proceedToCart,
                      arguments: viewModel.businessDescription?.id ?? 0,
                    );
                  },
                  text: "Pay Bill",
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildImageWidget() {
    return Stack(
      children: [
        SizedBox(
          height: 400.h,
          width: double.infinity,
          child: PageView.builder(
            controller: _businessPageController,
            itemCount: businessImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return AppImageWidget(
                imageUrl: businessImages[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        // Back Button
        Positioned(
          top: 40,
          left: 23,
          child: Container(
            height: 37.h,
            width: 37.w,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 37.h,
                  width: 37.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.white,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderDotsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(businessImages.length, (index) {
            return GestureDetector(
              onTap: () {
                _businessPageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: CircleAvatar(
                  radius: _currentPage == index ? 5.h : 3.h,
                  backgroundColor: _currentPage == index ? AppColor.primary : Colors.grey,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDescriptionWidget() {
    double avgExperience = double.tryParse(viewModel.businessDescription?.averageRatings?.avgExperience ?? "0") ?? 0.0;
    List<String> businessImages = [];
    var description = viewModel.businessDescription;

    // Populate business images list
    if (description?.businessImage != null) {
      businessImages.add(description!.businessImage!);
    }
    for (int i = 1; i <= 5; i++) {
      var imageUrl = description?.toJson()['business_image_$i'];
      if (imageUrl != null) {
        businessImages.add(imageUrl);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 5.h),
            AppTextWidget(
              text: viewModel.businessDescription?.businessName ?? '',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(
              height: 15.h,
            ),
            AppTextWidget(
              text: viewModel.businessDescription?.businessAddress ?? '',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
            if (viewModel.businessDescription?.pricingRangeText != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextWidget(
                        text: viewModel.businessDescription?.pricingRangeText ?? '',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      )
                    ],
                  ),
                ],
              ),
            if (viewModel.businessDescription?.timeFrom != null && viewModel.businessDescription?.timeTo != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: AppColor.openNow,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.done,
                            color: AppColor.white,
                            size: 12,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Row(
                        children: [
                          AppTextWidget(
                            text:
                                "${getBusinessStatus()} | ${viewModel.businessDescription?.timeFrom ?? ''} to ${viewModel.businessDescription?.timeTo ?? ''}",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: getBusinessStatus() == "Closed" ? AppColor.darkRed : AppColor.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            if (viewModel.businessDescription?.totalReviews != null && viewModel.businessDescription!.totalReviews! > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15.h,
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 125.w),
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColor.openNow),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          AppTextWidget(
                            text: avgExperience.toStringAsFixed(1),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(width: 10.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (index) {
                                  if (index < avgExperience.floor()) {
                                    return Icon(Icons.star, size: 12, color: AppColor.orange);
                                  } else if (index == avgExperience.floor() && avgExperience % 1 >= 0.5) {
                                    return Icon(Icons.star_half, size: 12, color: AppColor.orange);
                                  } else {
                                    return Icon(Icons.star_border, size: 12, color: AppColor.moreLighterDd);
                                  }
                                }),
                              ),
                              Flexible(
                                child: AppTextWidget(
                                  text: " ${viewModel.businessDescription?.totalReviews ?? 0} Reviews",
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            _buildMenuCarousel(),
            if (viewModel.businessDescription?.totalReviews != null && viewModel.businessDescription!.totalReviews! > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
                  AppTextWidget(
                    text: "Reviews",
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  _buildRatingWidget(),
                ],
              ),
            SizedBox(
              height: 100.h,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCarousel() {
    List<String> menuImages = [];
    var description = viewModel.businessDescription;

    // Populate menu images list
    for (int i = 1; i <= 5; i++) {
      var imageUrl = description?.toJson()['menu_card_$i'];
      if (imageUrl != null) {
        menuImages.add(imageUrl); // Store only the relative or absolute URL as given
      }
    }

    if (menuImages.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 30.h),
        Align(
          alignment: Alignment.centerLeft,
          child: AppTextWidget(
            text: "Menu",
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 15.h),
        Container(
          width: double.infinity,
          height: 200,
          child: PageView.builder(
            controller: _menuPageController,
            itemCount: menuImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageCarouselView(
                        imageUrls: menuImages,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AppImageWidget(
                    imageUrl: menuImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
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
                ),
                SizedBox(height: 15), // Spacing
                AppTextWidget(
                  text: "Expectation Match",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 15),
                AppTextWidget(
                  text: "Future Engagement",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            // Second Column: Star Ratings
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStarRating(double.tryParse(averageRatings?.avgExperience ?? "0") ?? 0),
                const SizedBox(height: 15),
                _buildStarRating(double.tryParse(averageRatings?.avgExpectation ?? "0") ?? 0),
                const SizedBox(height: 15),
                _buildStarRating(double.tryParse(averageRatings?.avgInteraction ?? "0") ?? 0),
              ],
            ),

            // Third Column: Rating Numbers
            Column(
              children: [
                AppTextWidget(
                  text: "${averageRatings?.avgExperience ?? "0"}/5",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 15), // Spacing
                AppTextWidget(
                  text: "${averageRatings?.avgExpectation ?? "0"}/5",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 15), // Spacing
                AppTextWidget(
                  text: "${averageRatings?.avgInteraction ?? "0"}/5",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 15.h,
        ),
        AppTextWidget(
          text: "Recommendation Factor",
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        SizedBox(
          height: 10,
        ),
        RatingProgressBar(
          percentage: double.tryParse(averageRatings?.avgRecommend?.replaceAll('%', '') ?? "0") ?? 0.0,
        ),
        SizedBox(
          height: 10,
        ),
        AppTextWidget(
          text: "Value For Money",
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        SizedBox(
          height: 10,
        ),
        RatingProgressBar(
          percentage: double.tryParse(averageRatings?.avgFairMoney?.replaceAll('%', '') ?? "0") ?? 0.0,
        ),
        SizedBox(
          height: 10,
        ),
        //Comments Section
        // if (viewModel.businessDescription?.reviewText != null && viewModel.businessDescription!.reviewText!.isNotEmpty)
        //   Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       AppTextWidget(
        //         text: "Customer Reviews",
        //         fontWeight: FontWeight.w600,
        //         fontSize: 16,
        //       ),
        //       const SizedBox(height: 10),
        //       ...viewModel.businessDescription!.reviewText!.map(
        //         (review) => Container(
        //           margin: const EdgeInsets.only(bottom: 8),
        //           padding: const EdgeInsets.all(12),
        //           decoration: BoxDecoration(
        //             color: Colors.grey.shade100,
        //             borderRadius: BorderRadius.circular(12),
        //             boxShadow: [
        //               BoxShadow(
        //                 color: Colors.black12,
        //                 blurRadius: 4,
        //                 offset: Offset(0, 2),
        //               ),
        //             ],
        //           ),
        //           child: Row(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Icon(Icons.format_quote, color: Colors.grey),
        //               const SizedBox(width: 8),
        //               Expanded(
        //                 child: Text(
        //                   review,
        //                   style: TextStyle(
        //                     fontSize: 14,
        //                     fontStyle: FontStyle.italic,
        //                     color: Colors.black87,
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
      ],
    );
  }

// Helper function to generate stars
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: AppColor.orange, size: 20);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: AppColor.orange, size: 20);
        } else {
          return const Icon(Icons.star_border, color: AppColor.moreLighterDd, size: 20);
        }
      }),
    );
  }
}
