import 'dart:ui';
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
      return const AppLoadingWidget();
    }

    return AppScaffold(
      useGradient: true,
      backgroundColor: Colors.transparent,
      isSafe: false,
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -50.h,
            right: -50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 250.w,
                height: 250.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100.h,
            left: -50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6A2D9A).withOpacity(0.15),
                ),
              ),
            ),
          ),

          // Main Content
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20.h),
            child: Column(
              children: [
                _buildPremiumHeader(),
                SizedBox(height: 10.h),
                _buildProfileCard(viewModel),
                SizedBox(height: 10.h),
                Expanded(
                  child: _buildItemList(viewModel),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  text: "SETTINGS",
                  fontSize: 12.sp,
                  color: AppColor.premiumAccent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
                SizedBox(height: 4.h),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0E0E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: AppTextWidget(
                    text: "Preferences",
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
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
                  color: AppColor.premiumLightCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.premiumBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back_ios_rounded,
                    color: AppColor.premiumTextPrimary, size: 20.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(SettingsViewModel viewModel) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.premiumLightCardBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColor.premiumBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColor.premiumAccent.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColor.premiumCardBg, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColor.premiumAccent.withOpacity(0.25),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: AppImageWidget(
                          isProfile: true,
                          height: 75.h,
                          width: 75.h,
                          iconSize: 50.sp,
                          imageUrl: viewModel.userData?.image ?? '',
                          fit: BoxFit.cover,
                          hasBorder: false,
                          borderRadius: 100,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9759C4), Color(0xFF6A2D9A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColor.premiumLightCardBg, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6A2D9A).withOpacity(0.6),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.edit_rounded,
                            color: Colors.white, size: 14.h),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.w),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (roleId == Constants.businessUser &&
                        viewModel.userData?.address != null &&
                        viewModel.userData!.address.toString().isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: AppColor.premiumTextSecondary,
                              size: 13.sp),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              viewModel.userData!.address.toString(),
                              style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColor.premiumTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (roleId == Constants.businessUser &&
                        viewModel.userData?.email != null &&
                        viewModel.userData!.email!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.email_rounded,
                              color: AppColor.premiumTextSecondary,
                              size: 13.sp),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              viewModel.userData!.email!,
                              style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColor.premiumTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.premiumAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColor.premiumAccent.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_iphone_rounded,
                              color: AppColor.premiumAccent, size: 14.sp),
                          SizedBox(width: 6.w),
                          Text(
                            viewModel.userData?.mobile ?? "",
                            style: GoogleFonts.montserrat(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.premiumAccent,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildItemList(SettingsViewModel viewModel) {
    return Container(
      margin: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          bottom: 100.h,
          top: 10.h), // Increased bottom margin
      decoration: BoxDecoration(
        color: AppColor.premiumLightCardBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColor.premiumBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: ListView.separated(
            padding:
                EdgeInsets.only(bottom: 20.h), // Added padding for inner scroll
            itemCount: viewModel.itemList.length,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: AppColor.premiumBorder.withOpacity(0.6),
              indent: 72.w, // Align divider with text
            ),
            itemBuilder: (context, index) {
              final item = viewModel.itemList[index];
              final isLogout =
                  item.name?.toLowerCase().contains("logout") ?? false;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            gradient: isLogout
                                ? LinearGradient(colors: [
                                    Colors.redAccent.withOpacity(0.2),
                                    Colors.red.withOpacity(0.05)
                                  ])
                                : LinearGradient(colors: [
                                    AppColor.premiumAccent.withOpacity(0.2),
                                    AppColor.premiumAccent.withOpacity(0.05)
                                  ]),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLogout
                                  ? Colors.redAccent.withOpacity(0.3)
                                  : AppColor.premiumAccent.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            item.iconData,
                            size: 20.h,
                            color: isLogout
                                ? Colors.redAccent
                                : AppColor.premiumAccent,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            item.name!,
                            style: GoogleFonts.montserrat(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: isLogout
                                  ? Colors.redAccent
                                  : AppColor.premiumTextPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.h,
                          color: isLogout
                              ? Colors.redAccent.withOpacity(0.4)
                              : AppColor.premiumTextSecondary.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
