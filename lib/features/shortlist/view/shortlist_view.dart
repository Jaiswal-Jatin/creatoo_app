import 'package:creatoo/features/shortlist/model/post_application_response.dart';
import 'package:creatoo/features/shortlist/view_model/shortlist_view_model.dart';

import '../../../core.dart';

class ShortlistView extends StatefulWidget {
  final int postId;
  final int minCreatorsRequired;

  const ShortlistView(
      {super.key, required this.postId, required this.minCreatorsRequired});

  @override
  State<ShortlistView> createState() => _ShortlistViewState();
}

class _ShortlistViewState extends State<ShortlistView> {
  late ShortlistViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<ShortlistViewModel>(context, listen: false);
    viewModel.init(widget.postId);
    print(
        "Post id : ${widget.postId} & Min Creator : ${widget.minCreatorsRequired}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<ShortlistViewModel>(context);
    switch (viewModel.shortlistResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
          message: viewModel.shortlistResponse.message.toString(),
        );
      case Status.completed:
        print(viewModel.shortlistResponse.data!.data!
            .where((element) => element.isCart == "1")
            .length);
        return AppScaffold(
          appBar: AppBarWidget(
            title: "Post Applications",
          ),
          body: SafeArea(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.only(bottom: 50),
              child: viewModel.shortlistResponse.data!.data!.isEmpty
                  ? const Center(
                      child: Text('No applicants yet'),
                    )
                  : Visibility(
                      visible: viewModel.cartResponse.status == Status.loading,
                      child: Center(child: CircularProgressIndicator()),
                      replacement: ListView.builder(
                        itemCount:
                            viewModel.shortlistResponse.data!.data!.length,
                        itemBuilder: (context, index) {
                          var item =
                              viewModel.shortlistResponse.data!.data![index];
                          return buildApplicationTile(index, item);
                        },
                      ),
                    ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.h),
            child: AppButton(
              text: "Shortlist",
              isLoading: viewModel.isLoading,
              isDisabled: !(viewModel.shortlistResponse.data!.data!
                      .where((element) => element.isCart == 1)
                      .length ==
                  widget.minCreatorsRequired),
              onTap: () async {
                await viewModel.shortlistCreator();
              },
            ),
          ),
        );
      default:
        return const AppNoDataWidget();
    }
  }

  Widget buildApplicationTile(int index, Datum item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColor.white,
        border: Border.all(color: AppColor.lightGrey),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Transform.scale(
          scale: 1.0, // Adjust the scale if needed
          child: Checkbox(
            visualDensity: VisualDensity.compact,
            onChanged: (value) => handleCartUpdate(index, value),
            value: item.isCart == 1 ? true : false,
            side: BorderSide(
              color: AppColor.darkGrey,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: AppImageWidget(
                height: 50.h,
                width: 50.h,
                imageUrl: item.userImage!,
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  navigatorKey.currentContext!,
                  RoutesName.creatorProfileDetailView,
                  arguments: item.id,
                );
              },
              child: Container(
                width: 145.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      item.instagramUsername ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: Color(0xFF10ABEE)),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    // Text(
                    //   '${item.bio}',
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.w400,
                    //     fontSize: 12.sp,
                    //     color: Color(0xFF6A6A6A),
                    //   ),
                    // ),
                    Row(
                      children: [
                        Text(
                          'Engagement: ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            color: Color(0xFF6A6A6A),
                          ),
                        ),
                        Text(
                          '${item.engagementRate ?? 0.0} %',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.sp,
                            color: Color(0xFF6A6A6A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            Navigator.pushNamed(
              navigatorKey.currentContext!,
              RoutesName.creatorProfileDetailView,
              arguments: item.id,
            );
          },
          icon: Icon(
            Icons.info_outline,
            size: 30,
            color: AppColor.primary,
          ),
        ),
      ),
    );
  }

  void handleCartUpdate(int index, bool? value) {
    var item = viewModel.shortlistResponse.data!.data![index];
    final isCartSelected = viewModel.shortlistResponse.data!.data!
            .where((element) => element.isCart == 1)
            .length ==
        widget.minCreatorsRequired;

    if (isCartSelected) {
      if (item.isCart == 1) {
        viewModel.updateCart(index, value!);
      } else {
        Utils.snackBar("Cannot add more creators", result: Result.error);
      }
    } else {
      viewModel.updateCart(index, value!);
    }
  }
}
