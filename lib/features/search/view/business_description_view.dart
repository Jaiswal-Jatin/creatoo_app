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

  final PageController _goldTierPageController = PageController();
  final PageController _silverTierPageController = PageController();
  final PageController _bronzeTierPageController = PageController();

  Timer? _goldCarouselTimer;
  Timer? _silverCarouselTimer;
  Timer? _bronzeCarouselTimer;


  int _currentBusinessPage = 0;
  int _currentGoldPage = 0;
  int _currentSilverPage = 0;
  int _currentBronzePage = 0;

  // Placeholder images - replace with actual premium images
  final List<String> goldTierImages = [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop', // Restaurant interior
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop', // Chef's special dish
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop', // Fine dining setup
  ];

  final List<String> silverTierImages = [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop', // Appetizers
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop', // Main course
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop', // Desserts
  ];

  final List<String> bronzeTierImages = [
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop', // Drinks
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop', // Snacks
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop', // Combo offers
  ];
  
  // Offer images with different categories
  final List<Map<String, String>> offerImages = [
    {
      'url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop',
      'title': 'Weekend Special',
      'description': '20% OFF on all main course items'
    },
    {
      'url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop',
      'title': 'Happy Hours',
      'description': 'Buy 1 Get 1 Free on all drinks'
    },
    {
      'url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop',
      'title': 'Family Combo',
      'description': 'Special discount for family of 4'
    },
  ];
  
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
    _goldTierPageController.dispose();
    _silverTierPageController.dispose();
    _bronzeTierPageController.dispose();
    super.dispose();
  }
  
  void _startTierSlidersAutoSlide() {
    _goldSliderTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_goldTierPageController.hasClients) {
        final nextPage = (_goldTierPageController.page!.toInt() + 1) % goldTierImages.length;
        _goldTierPageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    
    _silverSliderTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_silverTierPageController.hasClients) {
        final nextPage = (_silverTierPageController.page!.toInt() + 1) % silverTierImages.length;
        _silverTierPageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    
    _bronzeSliderTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_bronzeTierPageController.hasClients) {
        final nextPage = (_bronzeTierPageController.page!.toInt() + 1) % bronzeTierImages.length;
        _bronzeTierPageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
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

  Timer _startTierAutoScroll(PageController controller, List<String> images) {
    return Timer.periodic(Duration(seconds: 4), (timer) {
      if (controller.hasClients && images.isNotEmpty) {
        int nextPage = controller.page!.round() + 1;

        if (nextPage >= images.length) {
          controller.jumpToPage(0);
        } else {
          controller.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
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

    // Check if both business details and exclusive offers are loaded
    if (viewModel.businessDetailsResponse.status == Status.loading ||
        viewModel.exclusiveOffersApiResponse.status == Status.loading) {
      return AppLoadingWidget();
    }

    if (viewModel.businessDetailsResponse.status == Status.error) {
      return AppErrorWidget(
          message: viewModel.businessDetailsResponse.message.toString());
    }

    if (viewModel.exclusiveOffersApiResponse.status == Status.error &&
        viewModel.exclusiveOffersApiResponse.message !=
            "Exclusive offer not found for this business_id") {
      return AppErrorWidget(
          message: viewModel.exclusiveOffersApiResponse.message.toString());
    }

    if (viewModel.businessDetailsResponse.status == Status.completed) {
      return _buildBody();
    }

    return AppNoDataWidget();
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
                _currentBusinessPage = index;
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
                  radius: _currentBusinessPage == index ? 5.h : 3.h,
                  backgroundColor: _currentBusinessPage == index ? AppColor.primary : Colors.grey,
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
            _buildTierFeatureSection(),
            if (viewModel.businessDescription?.totalReviews != null && viewModel.businessDescription!.totalReviews! > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextWidget(
                        text: "Reviews",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        height: 3,
                        width: 40,
                        color: AppColor.primary,
                      ),
                    ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextWidget(
                text: "Menu",
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
              SizedBox(height: 4.h),
              Container(
                height: 3,
                width: 40,
                color: AppColor.primary,
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        Container(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: (menuImages.length / 2).ceil(),
            itemBuilder: (context, rowIndex) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 250,
                  ),
                  itemCount: (rowIndex * 2 + 2 <= menuImages.length) ? 2 : 1,
                  itemBuilder: (context, colIndex) {
                    final index = rowIndex * 2 + colIndex;
                    if (index >= menuImages.length) return Container();
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
                      child: Container(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0), // Slightly smaller to account for border
                          child: AppImageWidget(
                            imageUrl: menuImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
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
        //       Container(
        //         height: 2,
        //         width: 80,
        //         color: AppColor.primary,
        //       ),
        //       SizedBox(height: 10),
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

Widget _buildTierFeatureSection() {
  // Check if exclusive offers data is available and not empty
  final exclusiveOffers = viewModel.exclusiveOffersData;
  final exclusiveOffersResponse = viewModel.exclusiveOffersApiResponse;

  // If offers are not found by message, or data is null, or all tiers are empty, don't show the section.
  if ((exclusiveOffersResponse.message ==
          "Exclusive offer not found for this business_id") ||
      exclusiveOffers == null ||
      ((exclusiveOffers.premiumOffers?.isEmpty ?? true) &&
          (exclusiveOffers.eliteOffers?.isEmpty ?? true) &&
          (exclusiveOffers.coreOffers?.isEmpty ?? true))) {
    return SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Modern Section Header
      Padding(
        padding: EdgeInsets.fromLTRB(0.w, 24.h, 16.w, 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  text: "Exclusive Offers",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black,
                ),
                SizedBox(height: 4.h),
                Container(
                  height: 3,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Tiers List with consistent spacing
      ListView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          // Show Premium Tier only if business has premium offers
          if (exclusiveOffers.premiumOffers?.isNotEmpty ?? false)
            _buildTierItem(
              title: "Premium Tier",
              gradientColors: AppColor.goldGradient,
              controller: _goldTierPageController,
              images: exclusiveOffers.premiumOffers!,
              currentPage: _currentGoldPage,
              onPageChanged: (index) => setState(() => _currentGoldPage = index),
              iconPath: 'assets/icons/insurance.png',
            ),
          if (exclusiveOffers.premiumOffers?.isNotEmpty ?? false)
            SizedBox(height: 10.h),

          // Show Elite Tier only if business has elite offers
          if (exclusiveOffers.eliteOffers?.isNotEmpty ?? false)
            _buildTierItem(
              title: "Elite Tier",
              gradientColors: AppColor.silverGradient,
              controller: _silverTierPageController,
              images: exclusiveOffers.eliteOffers!,
              currentPage: _currentSilverPage,
              onPageChanged: (index) => setState(() => _currentSilverPage = index),
              iconPath: 'assets/icons/insurance.png',
            ),
          if (exclusiveOffers.eliteOffers?.isNotEmpty ?? false)
            SizedBox(height: 10.h),

          // Show Core Tier only if business has core offers
          if (exclusiveOffers.coreOffers?.isNotEmpty ?? false)
            _buildTierItem(
              title: "Core Tier",
              gradientColors: AppColor.bronzeGradient,
              controller: _bronzeTierPageController,
              images: exclusiveOffers.coreOffers!,
              currentPage: _currentBronzePage,
              onPageChanged: (index) => setState(() => _currentBronzePage = index),
              iconPath: 'assets/icons/insurance.png',
            ),
          if (exclusiveOffers.coreOffers?.isNotEmpty ?? false)
            SizedBox(height: 10.h),
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
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 15,
          offset: Offset(0, 8),
          spreadRadius: 0,
        ),
      ],
    ),
    child: Stack(
      children: [
        // Image Slider with Overlay Badge
        Container(
          height: 150.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: controller,
              itemCount: images.length,
              onPageChanged: (index) {
                onPageChanged(index);
                _stopTierSlidersAutoSlide();
                _startTierSlidersAutoSlide();
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(gradientColors.first),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[100],
                    child: Icon(Icons.broken_image_rounded, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Floating Gradient Badge (Top Left)
        Positioned(
          top: 16.h,
          left: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  iconPath,
                  width: 18.w,
                  height: 18.w,
                  color: Colors.black,
                ),
                SizedBox(width: 6.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Page Indicators (Bottom Center inside image)
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
                  duration: Duration(milliseconds: 300),
                  width: currentPage == index ? 20.w : 6.w,
                  height: 6.h,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: currentPage == index 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      if (currentPage == index)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
}
