import 'package:creatoo/widgets/app_text_widget.dart';
import '../../../core.dart';
import '../../search/view_model/search_view_model.dart';
import '../../search/model/search_business_model.dart';

class CategoryBusinessListView extends StatefulWidget {
  final String categoryKey;
  const CategoryBusinessListView({super.key, required this.categoryKey});

  @override
  State<CategoryBusinessListView> createState() => _CategoryBusinessListViewState();
}

class _CategoryBusinessListViewState extends State<CategoryBusinessListView> {
  late SearchViewModel viewModel;
  List<BusinessSearchData>? _businesses;
  bool _isLoading = true;

  String get _title {
    switch (widget.categoryKey) {
      case 'restaurant': return 'Restaurants';
      case 'salon': return 'Salon';
      case 'turf': return 'Turf';
      default: return 'Businesses';
    }
  }

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<SearchViewModel>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    final cached = await viewModel.getCachedCategoryData(widget.categoryKey);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _businesses = cached;
          _isLoading = false;
        });
      }
      return;
    }
    await viewModel.init(Constants.businessUser, category: widget.categoryKey);
    if (mounted) {
      setState(() {
        _businesses = viewModel.businessSearchList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppTextWidget(
          text: _title,
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColor.premiumAccent));
    }
    final businesses = _businesses ?? [];
    if (businesses.isEmpty) {
      return Center(
        child: AppTextWidget(
          text: 'No $_title found',
          fontSize: 14.sp,
          color: AppColor.premiumTextSecondary,
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
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
          child: _buildBusinessCard(businesses[index]),
        );
      },
    );
  }

  Map<String, dynamic> _getBusinessTheme(BusinessSearchData item) {
    final category = item.businessCategory?.toLowerCase() ?? widget.categoryKey.toLowerCase();
    if (category == "salon") {
      return {"icon": Icons.content_cut, "color": Color(0xFFE91E63)};
    }
    if (category == "turf") {
      return {"icon": Icons.sports_soccer, "color": Color(0xFF4CAF50)};
    }
    if (category == "restaurant") {
      return {"icon": Icons.restaurant, "color": Color(0xFFFF5722)};
    }
    return {"icon": Icons.store_rounded, "color": Color(0xFF7C4DFF)};
  }

  Widget _buildBusinessCard(BusinessSearchData item) {
    final avgRating = item.avgExperience != null ? double.tryParse(item.avgExperience!) : null;
    final int? displayDiscount = (item.set_regular_discount != null && item.set_regular_discount! > 0
        ? item.set_regular_discount
        : item.set_first_time_discount);
    final theme = _getBusinessTheme(item);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RoutesName.businessDescriptionView, arguments: item.id);
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
              Stack(
                children: [
                  Container(
                    height: 200.h,
                    width: double.infinity,
                    child: AppImageWidget(
                      imageUrl: item.businessImage ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
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
              Padding(
                padding: EdgeInsets.all(18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        if (avgRating != null && avgRating > 0)
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
                                  text: avgRating.toStringAsFixed(1),
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
                        Icon(Icons.location_on, size: 13.sp, color: AppColor.premiumTextSecondary),
                        SizedBox(width: 5.w),
                        AppTextWidget(
                          text: item.businessArea ?? "Pune",
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
