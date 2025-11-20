import 'package:creatoo/core.dart';
import 'package:creatoo/features/post/view_model/post_view_model.dart';

class PostView extends StatefulWidget {
  const PostView({super.key});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  @override
  void initState() {
    super.initState();
    PostViewModel postViewModel =
        Provider.of<PostViewModel>(context, listen: false);
    postViewModel.init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    PostViewModel viewModel = Provider.of<PostViewModel>(context);
    switch (viewModel.postResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.postResponse.message!);
      case Status.completed:
        return AppScaffold(
          appBar: AppBarWidget(title: "My Posts"),
          body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Visibility(
              visible: viewModel.postResponse.data!.data.isNotEmpty,
              replacement: Container(
                height: SizeConfig.screenHeight,
                width: SizeConfig.screenWidth,
                alignment: Alignment.center,
                child: Text('No post available!'),
              ),
              child: Visibility(
                visible: viewModel.isLoading,
                child: Center(child: CircularProgressIndicator()),
                replacement: ListView.builder(
                  itemCount: viewModel.postResponse.data!.data.length,
                  itemBuilder: (context, index) {
                    var item = viewModel.postResponse.data!.data[index];
                    return Container(
                      // height: 220.h,
                      width: SizeConfig.screenWidth,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.lightGrey),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID:#${item.id}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 100.w),
                                    Text(
                                      '${item.postInterestCount}',
                                      style: TextStyle(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Text(
                                  '${item.description}',
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.duration} Days',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          RoutesName.creatorContactView,
                                          arguments: item.id,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            item.creatorRequired == 1
                                                ? '${item.creatorRequired} Creator'
                                                : '${item.creatorRequired} Creators',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                              width: PostStatus.values[
                                                          int.parse(item
                                                              .postStatus)] ==
                                                      PostStatus.active
                                                  ? 5.h
                                                  : 0),
                                          PostStatus.values[int.parse(
                                                      item.postStatus)] ==
                                                  PostStatus.active
                                              ? Icon(
                                                  size: 20.h,
                                                  Icons.info_outline,
                                                  color: AppColor.primary,
                                                )
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${Utils.formatCurrency(item.budget)}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30.h),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: AppButton(
                                    isIconEnabled: false,
                                    onTap: () async {
                                      PostStatus status = PostStatus
                                          .values[int.parse(item.postStatus)];
                                      if (status == PostStatus.pending) {
                                        if (item.postInterestCount! > 0) {
                                          Navigator.pushNamed(
                                            context,
                                            RoutesName.shortlistView,
                                            arguments: {
                                              'id': item.id,
                                              'minCreatorsRequired':
                                                  item.creatorRequired,
                                            },
                                          );
                                        } else {
                                          Utils.snackBar(
                                              "No interest received yet",
                                              result: Result.general);
                                        }
                                      } else if (status == PostStatus.active) {
                                        bool? yes = await AppDialog
                                            .showConfirmationDialog(
                                          content:
                                              "Are you sure you want to release the payment?",
                                          cancel: "No",
                                          confirm: "Yes",
                                        );
                                        if (yes == null) {
                                          return Utils.toastMessage(
                                              "Something went wrong, Please try again!");
                                        }
                                        if (yes) {
                                          await viewModel
                                              .releasePaymentToCreator(item.id);
                                        }
                                      } else if (PostStatus.values[
                                              int.parse(item.postStatus)] ==
                                          PostStatus.approved) {
                                        await Navigator.pushNamed(
                                          context,
                                          RoutesName.shortlistView,
                                          arguments: {
                                            'id': item.id,
                                            'minCreatorsRequired':
                                                item.creatorRequired,
                                          },
                                        );
                                        await viewModel.viewMyPost();
                                      } else if (status ==
                                          PostStatus.completed) {
                                        Utils.snackBar("Completed",
                                            result: Result.success);
                                      }
                                    },
                                    text: getStatusOption(PostStatus
                                        .values[int.parse(item.postStatus)]),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: getColor(PostStatus
                                    .values[int.parse(item.postStatus)]),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                PostStatus.values[int.parse(item.postStatus)]
                                    .name.capitalizeFirst,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      default:
        return AppNoDataWidget();
    }
  }

  Color getColor(PostStatus status) {
    if (status == PostStatus.pending) {
      return AppColor.orange;
    } else if (status == PostStatus.approved) {
      return AppColor.mangoYellow;
    } else if (status == PostStatus.active) {
      return AppColor.activeGreen;
    } else if (status == PostStatus.completed) {
      return AppColor.primary;
    } else if (status == PostStatus.rejected) {
      return AppColor.darkRed;
    }
    return AppColor.primary;
  }

  String getStatusOption(PostStatus status) {
    if (status == PostStatus.pending || status == PostStatus.approved) {
      return "View Application";
    } else if (status == PostStatus.active) {
      return "Release Payment";
    } else if (status == PostStatus.completed) {
      return "Completed";
    } else if (status == PostStatus.rejected) {
      return "Rejected";
    }
    return "View Application";
  }
}
