import 'package:creatoo/core.dart';
import '../view_model/settings_view_model.dart';
import '../../../widgets/app_text_widget.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<SettingsViewModel>(context, listen: false);
    viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context);

    if (viewModel.isLoading || viewModel.apiResponse.status == Status.loading) {
      return AppLoadingWidget();
    }

    return AppScaffold(
      useGradient: false,
      backgroundColor: Colors.transparent, // Inherit from HomePage
      isSafe: false,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h),
        child: Column(
          children: [
            _buildPremiumHeader(),
            SizedBox(height: 20.h),
            _buildProfileCard(viewModel),
            SizedBox(height: 20.h),
            Expanded(
              child: _buildItemList(viewModel),
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
                SizedBox(height: 2.h),
                AppTextWidget(
                  text: "My Profile",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.premiumTextPrimary,
                ),
              ],
            ),
          ),
          if (Platform.isIOS && roleId == Constants.creatorUser)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.premiumCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.2),
                ),
                child: Icon(Icons.arrow_back_ios_rounded, color: AppColor.premiumTextPrimary, size: 20.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(SettingsViewModel viewModel) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              if (roleId == Constants.businessUser) {
                await Navigator.pushNamed(
                  navigatorKey.currentContext!,
                  RoutesName.editBusinessProfile,
                );
                await viewModel.fetchUserProfileDetails();
              } else {
                await Navigator.pushNamed(
                  navigatorKey.currentContext!,
                  RoutesName.editCreatorProfileView,
                );
                await viewModel.fetchCreatorProfileDetails();
              }
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.premiumAccent.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 35.h,
                    backgroundColor: AppColor.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: AppImageWidget(
                        isProfile: true,
                        height: 70,
                        width: 70,
                        iconSize: 60,
                        imageUrl: viewModel.userData?.image ?? '',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColor.premiumAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.premiumCardBg, width: 2),
                    ),
                    child: Icon(Icons.edit_rounded, color: Colors.white, size: 12.h),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.userData?.name ?? "",
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.premiumTextPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                if (roleId == Constants.businessUser)
                  Text(
                    viewModel.userData?.gst != null ? 'GSTIN : ${viewModel.userData?.gst}' : 'GSTIN : NA',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.premiumTextSecondary,
                    ),
                  ),
                SizedBox(height: 4.h),
                Text(
                  viewModel.userData?.mobile ?? "",
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.premiumTextSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(SettingsViewModel viewModel) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w, bottom: 100.h),
      itemCount: viewModel.itemList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = viewModel.itemList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: AppColor.premiumCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: ListTile(
            onTap: item.onTap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.premiumAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.iconData,
                size: 20.h,
                color: AppColor.premiumAccent,
              ),
            ),
            title: Text(
              item.name!,
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.premiumTextPrimary,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.h,
              color: AppColor.premiumTextSecondary.withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }
}

