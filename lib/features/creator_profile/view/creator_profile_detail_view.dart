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
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.profileResponse.message!);
      case Status.completed:
        var data = viewModel.profileResponse.data?.data!;
        return viewModel.isLoading
            ? AppLoadingWidget()
            : AppScaffold(
                isSafe: false,
                body: Container(
                  height: SizeConfig.screenHeight,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 220.h,
                          child: Stack(
                            children: [
                              Container(
                                // height: 155,
                                child: SvgPicture.asset(
                                  AppIcon.profileBgShort,
                                  // height: 200.h,
                                  width: SizeConfig.screenWidth,
                                ),
                              ),
                              Platform.isIOS
                                  ? Positioned(
                                      top: 30,
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
                                    )
                                  : SizedBox.shrink(),
                              Positioned(
                                top: SizeConfig.screenWidth / 5,
                                left: SizeConfig.screenWidth / 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    gradient: AppGradient.profileBg,
                                  ),
                                  child: CircleAvatar(
                                    radius: 65.h,
                                    backgroundColor: AppColor.transparent,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: AppImageWidget(
                                        height: 130.h,
                                        width: 130.h,
                                        imageUrl: data == null
                                            ? ""
                                            : data.userImage ?? "",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data?.name ?? "",
                                style: GoogleFonts.montserrat(
                                  textStyle:
                                      Theme.of(navigatorKey.currentContext!)
                                          .textTheme
                                          .displayLarge,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                  height: data?.instagramUsername == null
                                      ? 0
                                      : 4.h),
                              AppConditionalWidget(
                                visibility: data?.instagramVerificationStatus ==
                                    InstagramStatus.approved.index,
                                child: Text(
                                  data?.instagramUsername ?? "",
                                  style: AppTextStyles.body(
                                    fontSize: 14.sp,
                                    color: Color(0xFF838383),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(height: data?.bio == null ? 0 : 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data?.bio ?? "",
                                      maxLines: 6,
                                      style: AppTextStyles.body(
                                        fontSize: 12.sp,
                                        color: Color(0xFF838383),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: data?.instagramLink == null ? 0 : 12.h,
                              ),
                              AppConditionalWidget(
                                visibility: data?.instagramVerificationStatus ==
                                    InstagramStatus.approved.index,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: data?.instagramLink ?? ""),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.link),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    suffixIcon:
                                        data!.instagramVerificationStatus ==
                                                InstagramStatus.approved.index
                                            ? Icon(
                                                Icons.verified,
                                                color: Colors.blue,
                                              )
                                            : null,
                                  ),
                                ),
                              ),
                              AppConditionalWidget(
                                visibility: data.instagramVerificationStatus ==
                                        InstagramStatus.initial.index ||
                                    data.instagramVerificationStatus ==
                                        InstagramStatus.rejected.index,
                                child: SizedBox(height: 20.h),
                              ),
                              AppConditionalWidget(
                                visibility: data.instagramVerificationStatus ==
                                        InstagramStatus.initial.index ||
                                    data.instagramVerificationStatus ==
                                        InstagramStatus.rejected.index,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await AppDialog.showImageTextDialog(
                                        onPressed: (String username,
                                            String path) async {
                                      await viewModel
                                          .submitInstagramVerification(
                                              username, path);
                                    });
                                  },
                                  child: Text('Connect Instagram'),
                                  style: OutlinedButton.styleFrom(
                                    shape: StadiumBorder(
                                      side: BorderSide(
                                        style: BorderStyle.solid,
                                        color: AppColor.black,
                                      ),
                                    ),
                                    minimumSize: Size(
                                      double.infinity,
                                      50.h,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:
                                    data.verificationNote == null ? 0 : 10.h,
                              ),
                              Container(
                                width: SizeConfig.screenWidth,
                                child: Text(
                                  data.verificationNote ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: data.instagramVerificationStatus ==
                                          InstagramStatus.approved.index
                                      ? TextAlign.end
                                      : TextAlign.center,
                                  style: AppTextStyles.body(
                                    fontSize: 12.sp,
                                    color: getColor(
                                      data.instagramVerificationStatus!,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              AppConditionalWidget(
                                visibility: data.instagramVerificationStatus ==
                                    InstagramStatus.approved.index,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColor.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.lightGrey,
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          top: 16,
                                          left: 16,
                                          right: 16,
                                          bottom: 10,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Engagement',
                                              style:
                                                  AppTextStyles.montserratStyle(
                                                color: Color(0xFF1B1B1B),
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                            Text(
                                              '${data.engagementRate ?? 0}%',
                                              style:
                                                  AppTextStyles.montserratStyle(
                                                color: Color(0xFF1B1B1B),
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        thickness: 1,
                                        color: Color(0xFFDADADA),
                                      ),
                                      SizedBox(height: 16.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.h,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildContainer(
                                                  "Followers",
                                                  data.followerCount ?? 0,
                                                ),
                                                SizedBox(width: 10.w),
                                                buildContainer(
                                                  "Uploads",
                                                  data.mediaCount ?? 0,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildContainer(
                                                  "Avg. Likes",
                                                  data.avgLikes ?? 0.0,
                                                ),
                                                SizedBox(width: 10.w),
                                                buildContainer(
                                                  "Avg. Comments",
                                                  data.avgComments ?? 0.0,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Divider(
                                        thickness: 1,
                                        color: Color(0xFFDADADA),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 10,
                                          left: 16,
                                          right: 16,
                                          bottom: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // LinearProgressIndicator(
                                            //   minHeight: 5,
                                            //   borderRadius: BorderRadius.circular(20),
                                            //   backgroundColor: Color(0xFFF0F2F9),
                                            //   valueColor: AlwaysStoppedAnimation<Color>(
                                            //     AppColor.activeGreen,
                                            //   ),
                                            //   value: data
                                            //       ?.calculateAvgActivityPercentage(), //data?.avgActivityProgress,
                                            // ),
                                            // SizedBox(height: 10.h),
                                            Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Avg. Activity',
                                                    style: AppTextStyles.body(
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF6B6B6B),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${data?.avgActivity?.toStringAsFixed(2) ?? 0} %',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: Theme.of(
                                                              navigatorKey
                                                                  .currentContext!)
                                                          .textTheme
                                                          .displayLarge,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: AppColor.primary,
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
                            ],
                          ),
                        ),
                        AppConditionalWidget(
                          visibility: data.instagramVerificationStatus ==
                              InstagramStatus.approved.index,
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.h,
                            ),
                            child: Text(
                              'Note: The provided engagement rate is counted for the recent posts.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: AppColor.black,
                              ),
                            ),
                          ),
                        ),

                        // Column(
                        //   children: [
                        //     ...data!.stats!
                        //         .map(
                        //           (item) => buildStatsListTile(
                        //             title: "${item.title!.capitalizeFirst}",
                        //             subtitle: "${item.subtitle!.capitalizeFirst}",
                        //             value: item.value,
                        //           ),
                        //         )
                        //         .toList(),
                        //   ],
                        // ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              );
      default:
        return AppNoDataWidget();
    }
  }

  Color getColor(int index) {
    if (index == InstagramStatus.pending.index) {
      return AppColor.orange;
    } else if (index == InstagramStatus.rejected.index) {
      return AppColor.darkRed;
    } else if (index == InstagramStatus.approved.index) {
      return AppColor.activeGreen;
    }
    return AppColor.black;
  }

  Widget buildStatsListTile(
      {required String title, required String subtitle, dynamic value}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyles.montserratStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1B1B1B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.body(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B6B6B),
          ),
        ),
        trailing: Text(
          "$value",
          style: AppTextStyles.montserratStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1B1B1B),
          ),
        ),
      ),
    );
  }

  Widget buildContainer(String name, dynamic value) {
    return Container(
      // height: 120.h,
      width: SizeConfig.screenWidth / 2.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFDADADA)),
        color: AppColor.white,
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$value",
            style: AppTextStyles.montserratStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.body(
              fontSize: 13.sp,
              color: Color(0xFF6B6B6B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
