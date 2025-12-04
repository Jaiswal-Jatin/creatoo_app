import 'package:creatoo/core.dart';

import '../view_model/settings_view_model.dart';

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

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              _buildHeader(),
              _buildProfileCard(viewModel),
            ],
          ),
          Expanded(
            child: _buildItemList(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 260.h,
      child: Stack(
        children: [
          SvgPicture.asset(
            AppIcon.profileBg,
            width: SizeConfig.screenWidth,
          ),
          Positioned(
            top: 80.h,
            left: 20.w,
            child: Text(
              'My Profile',
              style: AppTextStyles.appBarTitleTextStyle.copyWith(fontSize: 25.sp),
            ),
          ),
          if (Platform.isIOS && roleId == Constants.creatorUser)
            Positioned(
              top: 30.h,
              left: 0,
              child: IconButton(
                icon: SvgPicture.asset(
                  height: 24.h,
                  width: 24.h,
                  AppIcon.arrowLeft,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemList(SettingsViewModel viewModel) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w),
      itemCount: viewModel.itemList.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final item = viewModel.itemList[index];
        return ListTile(
          onTap: item.onTap,
          leading: Icon(
            item.iconData,
            size: 24.h,
          ),
          title: Text(
            item.name!,
            style: GoogleFonts.montserrat(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 12.h,
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(SettingsViewModel viewModel) {
    return Positioned(
      top: 150.h,
      left: 20.w,
      right: 20.w,
      child: Container(
        height: 100.h,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryDark,
              offset: Offset(0, 0.2),
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
                  CircleAvatar(
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 25.h,
                      width: 25.h,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcon.editOutlined,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.userData?.name ?? "",
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (roleId == Constants.businessUser)
                  Text(
                    viewModel.userData?.gst != null ? 'GSTIN : ${viewModel.userData?.gst}' : 'GSTIN : NA',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                Text(
                  viewModel.userData?.mobile ?? "",
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
