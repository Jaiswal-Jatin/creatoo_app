import 'package:creatoo/features/home/view_model/home_view_model.dart';

import '../model/search_business_model.dart';
import '../../../core.dart';
import '../../../widgets/app_text_widget.dart';
import '../view_model/search_view_model.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late SearchViewModel viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print("SearchView: initState called");
    viewModel = Provider.of<SearchViewModel>(context, listen: false);
    viewModel.init(Constants.businessUser);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        viewModel.loadMoreBusinessUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<SearchViewModel>(context);
    
    // Instead of full screen loading, we show the structure with skeletons in list
    return _buildBody();
  }

  Widget _buildBody() {
    bool isLoading = viewModel.searchResponse.status == Status.loading;
    bool isError = viewModel.searchResponse.status == Status.error;
    bool isEmpty = viewModel.businessSearchList == null || viewModel.businessSearchList!.isEmpty;
    bool showEmptyInsteadOfError = isError && isEmpty;

    return AppScaffold(
      useGradient: false,
      backgroundColor: Colors.transparent, 
      isSafe: false,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h),
        child: Column(
          children: [
            _buildPremiumHeader(),
            SizedBox(height: 15.h),
            _buildCategoryFilters(),
            SizedBox(height: 20.h),
            _buildSearchSection(),
            SizedBox(height: 10.h),
            // if (!isLoading && !isEmpty && !isError)
            //   _buildResultsHeader(),
            Expanded(
              child: (isError && !showEmptyInsteadOfError)
                ? AppErrorWidget(message: viewModel.searchResponse.message.toString())
                : (isLoading ? _buildSkeletonList() : _buildBusinessList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  text: "CREATOO",
                  fontSize: 11.sp,
                  color: AppColor.premiumAccent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
                AppTextWidget(
                  text: "Search Businesses",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.premiumTextPrimary,
                ),
              ],
            ),
          ),
          // _buildHeaderIcon(Icons.tune, () {
          //   // Placeholder for filters
          // }),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      {"key": null, "label": "All", "icon": Icons.grid_view_rounded, "color": const Color(0xFF7C4DFF)},
      {"key": "restaurant", "label": "Restaurants", "icon": Icons.restaurant_menu, "color": const Color(0xFFFF5722)},
      {"key": "salon", "label": "Salon", "icon": Icons.content_cut, "color": const Color(0xFFE91E63)},
      {"key": "turf", "label": "Turf", "icon": Icons.sports_soccer, "color": const Color(0xFF4CAF50)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 17.w),
          child: Row(
            children: categories.map((cat) {
              final isSelected = viewModel.selectedCategory == cat["key"];
              return _buildFilterItem(
                cat["label"] as String,
                cat["icon"] as IconData,
                cat["color"] as Color,
                isSelected: isSelected,
                onTap: () => viewModel.setCategoryFilter(cat["key"] as String?),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterItem(String title, IconData icon, Color color, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.only(right: 10.w),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : AppColor.premiumCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.2),
                  width: isSelected ? 2.0 : 1.2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 14,
                      spreadRadius: 1,
                    )
                  else
                    BoxShadow(
                      color: color.withOpacity(0.06),
                      blurRadius: 10,
                    ),
                ],
              ),
              child: Center(child: Icon(icon, color: isSelected ? color : color.withOpacity(0.7), size: 24.sp)),
            ),
            SizedBox(height: 8.h),
            AppTextWidget(
              text: title,
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? color : AppColor.premiumTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getBusinessTheme(BusinessSearchData item) {
    final category = item.businessCategory?.toLowerCase() ?? "";
    if (category == "salon") {
      return {"icon": Icons.content_cut, "color": Color(0xFFE91E63)};
    }
    if (category == "turf") {
      return {"icon": Icons.sports_soccer, "color": Color(0xFF4CAF50)};
    }
    if (category == "restaurant") {
      return {"icon": Icons.restaurant, "color": Color(0xFFFF5722)};
    }

    // Default fallback for businesses without a category set
    return {"icon": Icons.store_rounded, "color": Color(0xFF7C4DFF)};
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: AppColor.premiumTextPrimary, size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17.w),
      child: buildSearchField(viewModel),
    );
  }

  Widget _buildResultsHeader() {
    final count = viewModel.businessSearchList?.length ?? 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColor.premiumAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppTextWidget(
                  text: count.toString(),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.premiumAccent,
                ),
              ),
              SizedBox(width: 10.w),
              AppTextWidget(
                text: "Matches found",
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.premiumTextPrimary.withOpacity(0.9),
              ),
            ],
          ),
          InkWell(
            onTap: () {}, // Sorting logic
            child: Row(
              children: [
                AppTextWidget(
                  text: "Popularity",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.premiumTextSecondary,
                ),
                SizedBox(width: 5.w),
                Icon(Icons.keyboard_arrow_down_rounded, 
                     color: AppColor.premiumTextSecondary, size: 18.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      height: 280.h,
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16.h,
                    width: 160.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 12.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessList() {
    if (viewModel.businessSearchList == null || viewModel.businessSearchList!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80.sp, color: AppColor.premiumTextSecondary.withOpacity(0.4)),
            SizedBox(height: 10.h),
            AppTextWidget(
              text: "No Businesses to show",
              color: AppColor.premiumTextSecondary,
              fontSize: 15.sp,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
      itemCount: viewModel.businessSearchList!.length + (viewModel.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.businessSearchList!.length) {
          return viewModel.isLoadingMore
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(15.h),
                    child: CircularProgressIndicator(color: AppColor.premiumAccent),
                  ),
                )
              : SizedBox.shrink();
        }
        
        final business = viewModel.businessSearchList![index];
        
        // Staggered Entrance Animation
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildBusinessDetailsCard(
            businessId: business.id ?? 0,
            businessName: business.businessName,
            imageUrl: business.businessImage,
            address: business.businessArea,
            ratings: business.avgExperience,
            discount: (business.set_first_time_discount as num?)?.toInt(),
            business: business,
          ),
        );
      },
    );
  }

  Widget buildSearchField(SearchViewModel viewModel) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: viewModel.searchController,
        style: TextStyle(
          color: AppColor.premiumTextPrimary,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
        onFieldSubmitted: (value) {
          viewModel.searchUser(searchQuery: value);
        },
        decoration: InputDecoration(
          hintText: "Search by business name...",
          hintStyle: TextStyle(
            color: AppColor.premiumTextSecondary.withOpacity(0.5),
            fontSize: 14.sp,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12),
            child: SvgPicture.asset(
              AppIcon.search,
              colorFilter: ColorFilter.mode(AppColor.premiumAccent, BlendMode.srcIn),
            ),
          ),
          suffixIcon: viewModel.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColor.premiumTextSecondary, size: 20.sp),
                  onPressed: () {
                    viewModel.searchController.clear();
                    viewModel.restoreOriginalList();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        ),
      ),
    );
  }

  Widget _buildBusinessDetailsCard({
    required int businessId,
    required String? imageUrl,
    required String? businessName,
    required String? address,
    required String? ratings,
    required int? discount,
    dynamic business,
  }) {
    final String? categoryKey = (business is BusinessSearchData) ? business.businessCategory : null;
    final String categoryLabel = categoryKey != null ? categoryKey[0].toUpperCase() + categoryKey.substring(1) : 'Business';

    // Determine the discount to show
    int? displayDiscount = (business is BusinessSearchData) 
        ? (business.set_regular_discount != null && business.set_regular_discount! > 0 
            ? business.set_regular_discount 
            : business.set_first_time_discount)
        : discount;

    // Determine theme for icon and color
    final theme = (business is BusinessSearchData) 
        ? _getBusinessTheme(business) 
        : {"icon": Icons.category, "color": AppColor.premiumAccent};

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RoutesName.businessDescriptionView,
            arguments: businessId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (theme["color"] as Color).withOpacity(0.12),
            width: 1.0,
          ),
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
              // 1. Large Image with Offer Overlay
              Stack(
                children: [
                   Container(
                     height: 200.h,
                     width: double.infinity,
                     child: AppImageWidget(
                      imageUrl: imageUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                   ),
                  // Offers Overlay Bar
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
                              (theme["color"] as Color).withOpacity(0.9), 
                              (theme["color"] as Color).withOpacity(0.4), 
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
                  
                  // Top Reflective Line
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1.2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // 2. Business Details
              Padding(
                padding: EdgeInsets.all(18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextWidget(
                            text: businessName ?? '',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Golden Rating Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFD700).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Color(0xFFFFD700), size: 12.sp),
                              SizedBox(width: 4.w),
                              AppTextWidget(
                                text: ratings ?? "4.5", 
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFD700),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.chevron_right, color: AppColor.premiumTextSecondary, size: 22.sp),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: (theme["color"] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(theme["icon"] as IconData, color: theme["color"] as Color, size: 13.sp),
                        ),
                        SizedBox(width: 6.w),
                        AppTextWidget(
                          text: categoryLabel,
                          fontSize: 12.sp,
                          color: theme["color"] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(width: 10.w),
                        Icon(Icons.location_on, size: 13.sp, color: AppColor.premiumTextSecondary),
                        SizedBox(width: 5.w),
                        AppTextWidget(
                          text: address ?? 'Pune',
                          fontSize: 12.sp,
                          color: AppColor.premiumTextSecondary,
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
}
