import 'package:creatoo/widgets/app_text_widget.dart';

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
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.reviewsResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Reviews',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: viewModel.formKey,
          child: viewModel.reviewList.isEmpty
              ? Center(child: AppTextWidget(text: "No Reviews Found", fontSize: 16))
              : ListView.builder(
                  itemCount: viewModel.reviewList.length,
                  itemBuilder: (context, index) {
                    return _buildReviewTileWidget(review: viewModel.reviewList[index]);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildReviewTileWidget({required ReviewsData review}) {
    return InkWell(
      onTap: () {
        if (review.business_id != null) {
          Navigator.pushNamed(context, RoutesName.businessDescriptionView, arguments: review.business_id);
        }
      },
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.grey),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppImageWidget(
                        imageUrl: review.businessImage ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextWidget(
                            text: review.businessName ?? "Unknown",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Row(
                                children: _buildStarRating(review.experience ?? 0.0),
                              ),
                              const SizedBox(width: 4),
                              AppTextWidget(
                                text: '${review.experience?.toStringAsFixed(1) ?? "0.0"}/5',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (review.daysAgo != null)
                      AppTextWidget(
                        text: (review.daysAgo == 0) ? "Today" : "${review.daysAgo} days ago",
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                  ],
                ),
                if (review.reviewText != null && review.reviewText!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AppTextWidget(
                    text: review.reviewText!,
                    fontSize: 12.sp,
                    color: Colors.black87,
                  ),
                ],
              ],
            ),
          )),
    );
  }

  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.orange, size: 18));
    }

    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.orange, size: 18));
    }

    for (int i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.orange, size: 18));
    }

    return stars;
  }
}
