import 'package:creatoo/features/post_detail/model/post_detail_response.dart';
import 'package:creatoo/features/post_detail/view_model/post_detail_view_model.dart';

import '../../../core.dart';

class PostDetailView extends StatefulWidget {
  final int postId;

  const PostDetailView({super.key, required this.postId});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  late PostDetailViewModel viewModel;
  List<Widget> textWidgets = [];

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<PostDetailViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      viewModel.init(widget.postId);
    });
  }

  getStatus(int status) {
    if (status == 0) {
      return "Apply";
    } else if (status == 1) {
      return "Already Applied";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<PostDetailViewModel>(context);
    switch (viewModel.opportunityResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.opportunityResponse.message!);
      case Status.completed:
        var item = viewModel.opportunityResponse.data!.data!;
        return AppScaffold(
          appBar: AppBarWidget(
            title: "Post Details",
          ),
          body: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
            child: SingleChildScrollView(
              child: buildPostDetailCard(item),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton:
              (item.postStatus != PostStatus.approved.index.toString() &&
                      item.postStatus != PostStatus.pending.index.toString())
                  ? SizedBox.shrink()
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.h),
                      child: AppButton(
                        text: getStatus(item.applicationUserInterestStatus!),
                        isDisabled: item.applicationUserInterestStatus == 1,
                        isLoading:
                            viewModel.interestResponse.status == Status.loading,
                        onTap: () async =>
                            viewModel.addInterestToPost(widget.postId),
                      ),
                    ),
        );
      default:
        return AppNoDataWidget();
    }
  }

  Widget buildPostDetailCard(Data item) {
    return Container(
      // height: 200.h,
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
              Container(
                width: SizeConfig.screenWidth,
                child: Text(
                  '${item.name}', //'ID:#${item.id}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF343434),
                  ),
                ),
              ),
              Divider()
            ],
          ),
          Container(
            width: SizeConfig.screenWidth,
            child: Text(
              'Post Description: ${item.description}',
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
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
                    text: "Deliverables: ",
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF343434),
                    ),
                  ),
                  TextSpan(
                    text: "${item.deliverable}",
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
                    text:
                        "${WorkMode.values[item.workMode!].name.capitalizeFirst}",
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
                    text:
                        "${DateTimeHelper.formatDateToString(item.postExpiryDate!)}",
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
                item.creatorRequired == 1
                    ? '${item.creatorRequired} Creator'
                    : '${item.creatorRequired} Creators',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF343434),
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
          int.parse(item.postStatus ?? "0") == ApplicationStatus.ongoing.index
              ? buildContactCard(
                  businessName: item.business!.businessName!,
                  name: item.business!.businessFullname!,
                  contact: item.business!.businessMobile!,
                  address: item.business!.businessAddress!,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Container buildTextField(
    String title,
    controller, {
    int maxLines = 1,
    Function()? onTap,
    bool readOnly = true,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.formHeaderStyle(),
          ),
          SizedBox(height: 8.h),
          AppTextField(
            onTap: onTap,
            readOnly: readOnly,
            textInputType: keyboardType,
            controller: controller,
            validator: (value) => Validator.validate(value!, title),
            disableBorder: false,
            maxLines: maxLines,
            suffixIcon: suffixIcon,
            hintText: title.toLowerCase().contains("expiry")
                ? "DD/MM/YYYY"
                : "Enter ${title.toLowerCase()}",
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

Widget buildContactCard({
  required String businessName,
  required String name,
  required String contact,
  required String address,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 10.h),
      Divider(),
      SizedBox(height: 10.h),
      Container(
        alignment: Alignment.center,
        child: Text(
          "Business Details",
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Color(0xFF343434),
          ),
        ),
      ),
      SizedBox(height: 10),
      Row(
        children: [
          Icon(Icons.business, color: Colors.blue),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SizeConfig.screenWidth - 120,
                child: Text(
                  "$businessName",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      SizedBox(height: 10),
      Row(
        children: [
          Icon(Icons.person, color: Colors.black),
          SizedBox(width: 15),
          Text(
            name,
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
      SizedBox(height: 10),
      Row(
        children: [
          Icon(Icons.phone, color: Colors.green),
          SizedBox(width: 15),
          Text(
            contact,
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
      SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: Colors.red),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              address,
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    ],
  );
}
