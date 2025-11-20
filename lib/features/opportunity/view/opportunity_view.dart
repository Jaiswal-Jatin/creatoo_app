import 'package:creatoo/features/opportunity/model/opportunity_response_model.dart';
import 'package:creatoo/features/opportunity/view_model/opportunity_view_model.dart';

import '../../../core.dart';

class OpportunityView extends StatefulWidget {
  final String searchKey;

  const OpportunityView({super.key, required this.searchKey});

  @override
  State<OpportunityView> createState() => _OpportunityViewState();
}

class _OpportunityViewState extends State<OpportunityView> {
  late OpportunityViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<OpportunityViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      viewModel.searchKey = widget.searchKey;
      viewModel.getOpportunities(filter: widget.searchKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<OpportunityViewModel>(context);

    switch (viewModel.apiResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.apiResponse.message!);
      case Status.completed:
        return viewModel.isLoading
            ? AppLoadingWidget()
            : AppScaffold(
                appBar: AppBarWidget(
                  title: widget.searchKey == ApplicationStatus.all.name ? "Opportunities" : widget.searchKey.capitalizeFirst,
                ),
                body: Container(
                  width: SizeConfig.screenWidth,
                  margin: EdgeInsets.symmetric(horizontal: viewModel.apiResponse.data!.data!.isEmpty ? 0 : 16),
                  child: viewModel.apiResponse.data!.data!.isEmpty
                      ? AppNoDataWidget(
                          message: "No data found!",
                        )
                      : ListView.builder(
                          itemCount: viewModel.apiResponse.data!.data!.length,
                          itemBuilder: (context, index) {
                            Opportunity item = viewModel.apiResponse.data!.data![index];
                            return buildOpportunityCard(item);
                          },
                        ),
                ),
              );
      default:
        return AppNoDataWidget();
    }
  }

  GestureDetector buildOpportunityCard(Opportunity item) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          navigatorKey.currentContext!,
          RoutesName.postDetailView,
          arguments: item.id,
        );
        await viewModel.getOpportunities(filter: widget.searchKey);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColor.white,
          border: Border.all(color: AppColor.lightGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID:#${item.id}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                    Text(
                      DateTimeHelper.timeAgo(item.createdAt.toString()),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.green,
                      ),
                    ),
                    Row(
                      children: [
                        item.flagReported == 1
                            ? Tooltip(
                                child: Icon(Icons.flag, color: AppColor.darkRed),
                                message: "This is a reported post.",
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  border: Border.all(color: AppColor.lightGrey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: TextStyle(
                                  color: AppColor.darkRed,
                                  fontSize: 12.sp,
                                ),
                                enableTapToDismiss: true,
                                showDuration: Duration(seconds: 5),
                                enableFeedback: true,
                                triggerMode: TooltipTriggerMode.tap,
                                preferBelow: true,
                              )
                            : SizedBox.shrink(),
                        item.flagReported == 1 ? SizedBox(width: 20.w) : SizedBox.shrink(),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == Constants.report) {
                              viewModel.reportController.text = "";
                              showReportDialog(
                                controller: viewModel.reportController,
                                onConfirm: () async {
                                  Navigator.pop(navigatorKey.currentContext!);
                                  await viewModel.reportPost(item.id!);
                                },
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: Constants.report,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.report_outlined,
                                      color: AppColor.darkRed,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      Constants.report,
                                      style: TextStyle(
                                        color: AppColor.darkRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          },
                          child: Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider()
              ],
            ),
            Container(
              width: SizeConfig.screenWidth,
              child: Text(
                '${item.name}',
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF343434),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: SizeConfig.screenWidth,
              child: Text(
                '${item.description}',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF343434),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: SizeConfig.screenWidth,
              child: Text(
                '${item.deliverable}',
                textAlign: TextAlign.left,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF343434),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: SizeConfig.screenWidth,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Min Insta followers: ",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF343434),
                      ),
                    ),
                    TextSpan(
                      text: "${item.followersRequired}",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF343434),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: SizeConfig.screenWidth,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Work Mode: ",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF343434),
                      ),
                    ),
                    TextSpan(
                      text: "${WorkMode.values[item.workMode!].name.capitalizeFirst}",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF343434),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: SizeConfig.screenWidth,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Post expiry: ",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF343434),
                      ),
                    ),
                    TextSpan(
                      text: "${DateTimeHelper.formatDateToString(item.postExpiryDate!)}",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF343434),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.duration} Days',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF343434),
                  ),
                ),
                Text(
                  item.creatorRequired == 1 ? '${item.creatorRequired} Creator' : '${item.creatorRequired} Creators',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Utils.formatCurrency(item.budget!),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF343434),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void showReportDialog({
    required TextEditingController controller,
    required VoidCallback onConfirm,
  }) async {
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<OpportunityViewModel>(
          builder: (context, viewModel, _) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Report Post',
                        textAlign: TextAlign.left,
                        style: AppTextStyles.appBarTitleTextStyle.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColor.darkRed,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: AppTextField(
                          controller: controller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Comment cannot be empty";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            viewModel.notify();
                          },
                          disableBorder: false,
                          hintText: "Comment...",
                          minLines: 7,
                          maxLines: 10,
                          maxLength: 300,
                          textInputType: TextInputType.text,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              elevation: 1,
                            ),
                            // Disable the button if the comment field is empty
                            onPressed: controller.text.trim().isEmpty
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      onConfirm();
                                    }
                                  },
                            child: Text('Submit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
