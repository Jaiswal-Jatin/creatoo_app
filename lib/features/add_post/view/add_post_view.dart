import 'package:flutter/services.dart';

import '../../../core.dart';
import '../view_model/add_post_view_model.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({super.key});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  late AddPostViewModel viewModel;

  Future<DateTime?> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      return picked;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<AddPostViewModel>(context, listen: false);
    viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<AddPostViewModel>(context);

    return AppScaffold(
      appBar: AppBarWidget(
        title: "Post Requirement",
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
        child: SingleChildScrollView(
          child: Form(
            key: viewModel.formKey,
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextField("Post Name", viewModel.postNameController),
                buildTextField(
                    "Post Description", viewModel.postDescriptionController,
                    maxLines: 4),
                buildTextField(
                    "Min Insta Followers", viewModel.postMinInstaController,
                    keyboardType: TextInputType.number),
                buildTextField(
                    "Deliverables", viewModel.postDeliverablesController,
                    maxLines: 4),
                Text(
                  'Mode',
                  style: AppTextStyles.formHeaderStyle(),
                ),
                SizedBox(height: 10.h),
                AppValidator(
                  validator: viewModel.radioValue == null,
                  isValidating: viewModel.isValidating,
                  errorMessage: "Please select mode",
                  enableErrorBorder: true,
                  borderRadius: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: viewModel.radioValues.map((status) {
                      return Row(
                        children: [
                          Radio<int>(
                            value: status.index,
                            groupValue: viewModel.radioValue,
                            onChanged: (value) => viewModel.updateMode(value!),
                          ),
                          Text(
                            status.name.capitalizeFirst,
                            style: AppTextStyles.formHeaderStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Tooltip(
                            child: SvgPicture.asset(AppIcon.info),
                            message: status.index == 0
                                ? Constants.onlineMode
                                : Constants.offlineMode,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              border: Border.all(color: AppColor.lightGrey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                              color: AppColor.primary,
                              fontSize: 12.sp,
                            ),
                            enableTapToDismiss: true,
                            showDuration: Duration(seconds: 100),
                            enableFeedback: true,
                            triggerMode: TooltipTriggerMode.tap,
                            preferBelow: true,
                          ),
                          SizedBox(width: 25.w),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Creators Required',
                      style: AppTextStyles.formHeaderStyle(),
                    ),
                    QuantityStepper(
                      onQuantityChanged: (value) =>
                          viewModel.updateCreatorRequired(value),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                buildTextField(
                  "Amount",
                  viewModel.postAmountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+(\.\d{0,2})?$')),
                  ],
                  suffixIcon: Text(
                    'RS',
                    textAlign: TextAlign.center,
                  ),
                ),
                buildTextField(
                  "Days",
                  viewModel.postDurationController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+$')),
                  ],
                ),
                buildTextField(
                  "Post Expiry",
                  viewModel.postExpiryController,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  suffixIcon: Icon(Icons.calendar_month_outlined),
                  onTap: () async {
                    DateTime? date = await selectDate(context);
                    viewModel.postExpiryController.text =
                        DateTimeHelper.dateTimeStringToDateTime(
                            date.toString());
                    setState(() {});
                  },
                ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        child: AppButton(
          text: "Proceed",
          onTap: () async {
            viewModel.setValidatingStatus(true);
            if (!viewModel.formKey.currentState!.validate()) {
              Utils.toastMessage("Please complete the form");
            } else {
              if(viewModel.radioValue == null) return;
              viewModel.model.name = viewModel.postNameController.text;
              viewModel.model.description =
                  viewModel.postDescriptionController.text;
              viewModel.model.followersRequired =
                  int.parse(viewModel.postMinInstaController.text);
              viewModel.model.deliverable =
                  viewModel.postDeliverablesController.text;
              viewModel.model.creatorRequired = viewModel.creatorRequired; //
              viewModel.model.duration =
                  int.parse(viewModel.postDurationController.text);
              viewModel.model.perCreatorAmount =
                  int.parse(viewModel.postAmountController.text);
              viewModel.model.postExpiryDate =
                  viewModel.postExpiryController.text;
              viewModel.model.userId = userId;
              viewModel.model.workMode = viewModel.radioValue;
              Navigator.pushNamed(context, RoutesName.addPostPaymentSummary,
                  arguments: viewModel.model);
            }
          },
        ),
      ),
    );
  }

  Container buildTextField(
    String title,
    controller, {
    int maxLines = 1,
    Function()? onTap,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toLowerCase().contains("amount") ? "$title (per creator)" : "$title",
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
            inputFormatters: inputFormatters,
            hintText: title.toLowerCase().contains("expiry")
                ? "DD/MM/YYYY"
                : "Enter ${title.toLowerCase()}",
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
