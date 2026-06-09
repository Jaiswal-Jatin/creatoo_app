import 'dart:ui';
import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:creatoo/widgets/custom_back_button.dart';

import '../../../core.dart';
import '../model/reviews_response_model.dart';
import '../view_model/reviews_view_model.dart';

class ReviewsView extends StatefulWidget {
  final int creatorId;
  final int business_id;
  const ReviewsView({super.key, required this.creatorId, required this.business_id});

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  late ReviewsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ReviewsViewModel>(context, listen: false);
    viewModel.getReviews(creatorId: widget.creatorId);
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<ReviewsViewModel>(context);
    switch (viewModel.reviewsResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.reviewsResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100.h,
            right: -100.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.05),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      const CustomBackButton(),
                      Expanded(
                        child: AppTextWidget(
                          text: "Reviews",
                          textAlign: TextAlign.center,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer for centering
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: viewModel.reviewList.isEmpty
                        ? Center(
                            child: AppTextWidget(
                              text: "No Reviews Yet",
                              fontSize: 16.sp,
                              color: Colors.white60,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(top: 20.h, bottom: 40.h),
                            physics: const BouncingScrollPhysics(),
                            itemCount: viewModel.reviewList.length,
                            itemBuilder: (context, index) {
                              return _buildReviewTileWidget(review: viewModel.reviewList[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTileWidget({required ReviewsData review}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () {
              if (review.business_id != null) {
                Navigator.pushNamed(context, RoutesName.businessDescriptionView, arguments: review.business_id);
              }
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Logo with Glow
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColor.premiumAccent.withOpacity(0.3), width: 1.5),
                        ),
                        child: ClipOval(
                          child: AppImageWidget(
                            imageUrl: review.businessImage ?? '',
                            width: 45.w,
                            height: 45.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextWidget(
                              text: review.businessName ?? "Unknown Business",
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Row(
                                  children: _buildStarRating(review.experience ?? 0.0),
                                ),
                                SizedBox(width: 6.w),
                                AppTextWidget(
                                  text: '${review.experience?.toStringAsFixed(1) ?? "0.0"}',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.premiumAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (review.daysAgo != null)
                        AppTextWidget(
                          text: (review.daysAgo == 0) ? "Today" : "${review.daysAgo}d ago",
                          fontSize: 11.sp,
                          color: Colors.white38,
                          fontWeight: FontWeight.w500,
                        ),
                    ],
                  ),
                  if (review.reviewText != null && review.reviewText!.trim().isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    AppTextWidget(
                      text: review.reviewText!,
                      fontSize: 13.sp,
                      color: Colors.white70,
                      maxLines: 4,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star_rounded, color: AppColor.premiumAccent, size: 16.sp));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(Icon(Icons.star_half_rounded, color: AppColor.premiumAccent, size: 16.sp));
      } else {
        stars.add(Icon(Icons.star_rounded, color: Colors.white10, size: 16.sp));
      }
    }

    return stars;
  }
}
