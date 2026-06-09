import 'package:creatoo/widgets/custom_back_button.dart';

import '../../../core.dart';
import '../view_model/creator_profile_detail_view_model.dart';

class CreatorProfileDetailView extends StatefulWidget {
  final int id;

  const CreatorProfileDetailView({super.key, this.id = -1});

  @override
  State<CreatorProfileDetailView> createState() =>
      _CreatorProfileDetailViewState();
}

class _CreatorProfileDetailViewState extends State<CreatorProfileDetailView> {
  late CreatorProfileDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      viewModel =
          Provider.of<CreatorProfileDetailViewModel>(context, listen: false);
      viewModel.init(widget.id);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CreatorProfileDetailViewModel>(context);
    switch (viewModel.profileResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.profileResponse.message!);
      case Status.completed:
        var data = viewModel.profileResponse.data?.data;
        return viewModel.isLoading
            ? const AppLoadingWidget()
            : AppScaffold(
                isSafe: false,
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(data),
                      _buildBody(data),
                    ],
                  ),
                ),
              );
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildHeader(dynamic data) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppGradient.profileBg,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.h,
          left: 16.w,
          child: const CustomBackButton(),
        ),
        Positioned(
          top: 155.h,
          child: _buildAvatar(data),
        ),
      ],
    );
  }

  Widget _buildAvatar(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        shape: BoxShape.circle,
        // boxShadow: [
        //   // BoxShadow(
        //   //   color: Colors.black.withOpacity(0.5),
        //   //   blurRadius: 25,
        //   //   spreadRadius: 2,
        //   //   offset: const Offset(0, 12),
        //   // ),
        //   BoxShadow(
        //     color: AppColor.premiumAccent.withOpacity(0.2),
        //     blurRadius: 15,
        //     spreadRadius: 0,
        //     offset: const Offset(0, 0),
        //   ),
        // ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: AppImageWidget(
              height: 120.h,
              width: 120.h,
              imageUrl: data == null ? "" : data.userImage ?? "",
              fit: BoxFit.cover,
              isProfile: true,
              hasBorder: false,
              borderRadius: 100,
            ),
          ),
          if (data?.instagramVerificationStatus == InstagramStatus.approved.index)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColor.premiumCardBg,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(dynamic data) {
    return Padding(
      padding: EdgeInsets.only(top: 70.h, left: 24, right: 24, bottom: 40),
      child: Column(
        children: [
          Text(
            data?.name ?? "",
            style: GoogleFonts.montserrat(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.premiumTextPrimary,
            ),
          ),
          if (data?.instagramUsername != null &&
              data!.instagramVerificationStatus ==
                  InstagramStatus.approved.index) ...[
            SizedBox(height: 6.h),
            Text(
              "@${data.instagramUsername}",
              style: AppTextStyles.body(
                fontSize: 14.sp,
                color: AppColor.premiumAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (data?.bio != null && data!.bio.toString().isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              data.bio ?? "",
              textAlign: TextAlign.center,
              maxLines: 6,
              style: AppTextStyles.body(
                fontSize: 14.sp,
                color: AppColor.premiumTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          SizedBox(height: 24.h),
          if (data?.verificationNote != null &&
              data!.verificationNote.toString().isNotEmpty)
            _buildVerificationNote(data),
          if (data?.instagramVerificationStatus ==
                  InstagramStatus.initial.index ||
              data?.instagramVerificationStatus ==
                  InstagramStatus.rejected.index)
            _buildConnectInstagramButton(),
          if (data?.instagramVerificationStatus ==
              InstagramStatus.approved.index) ...[
            _buildStatsCard(data),
            SizedBox(height: 24.h),
            Text(
              'Note: The provided engagement rate is counted for the recent posts.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                fontSize: 12.sp,
                color: AppColor.premiumTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationNote(dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: getColor(data.instagramVerificationStatus!).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: getColor(data.instagramVerificationStatus!).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: getColor(data.instagramVerificationStatus!),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.verificationNote ?? "",
              style: AppTextStyles.body(
                fontSize: 13.sp,
                color: getColor(data.instagramVerificationStatus!),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectInstagramButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFF56040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFD1D1D).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            await AppDialog.showImageTextDialog(
              onPressed: (String username, String path) async {
                await viewModel.submitInstagramVerification(username, path);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Connect Instagram',
                  style: GoogleFonts.montserrat(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(dynamic data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColor.premiumBorder),
      ),
      child: Column(
        children: [
          // Engagement Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: AppColor.premiumLightCardBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.premiumCardBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.insights,
                          color: AppColor.premiumAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Engagement',
                      style: GoogleFonts.montserrat(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.premiumTextPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${data.engagementRate ?? 0}%',
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.premiumAccent,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColor.premiumBorder),
          // Grid Stats
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildStatItem(
                            "Followers",
                            data.followerCount ?? 0,
                            Icons.people_outline,
                            Colors.blue)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatItem(
                            "Uploads",
                            data.mediaCount ?? 0,
                            Icons.photo_library_outlined,
                            Colors.orange)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _buildStatItem("Avg. Likes", data.avgLikes ?? 0,
                            Icons.favorite_outline, Colors.red)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatItem(
                            "Avg. Comments",
                            data.avgComments ?? 0,
                            Icons.chat_bubble_outline,
                            Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColor.premiumBorder),
          // Avg Activity
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Avg. Activity',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColor.premiumTextSecondary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.premiumAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${data.avgActivity?.toStringAsFixed(2) ?? 0} %',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.premiumAccent,
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

  Widget _buildStatItem(String title, dynamic value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.premiumLightCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.premiumBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.9), size: 24),
          const SizedBox(height: 12),
          Text(
            "$value",
            style: GoogleFonts.montserrat(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.premiumTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.premiumTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color getColor(int index) {
    if (index == InstagramStatus.pending.index) {
      return AppColor.orange;
    } else if (index == InstagramStatus.rejected.index) {
      return AppColor.darkRed;
    } else if (index == InstagramStatus.approved.index) {
      return AppColor.activeGreen;
    }
    return AppColor.premiumTextPrimary;
  }
}
