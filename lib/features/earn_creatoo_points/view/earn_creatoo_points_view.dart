import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';

import '../../../core.dart';
import '../model/business_list_response.dart';
import '../view_model/earn_creatoo_points_view_model.dart';

class EarnCreatooPointsView extends StatefulWidget {
  const EarnCreatooPointsView({super.key});

  @override
  State<EarnCreatooPointsView> createState() => _EarnCreatooPointsViewState();
}

class _EarnCreatooPointsViewState extends State<EarnCreatooPointsView> {
  late EarnCreatooPointsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<EarnCreatooPointsViewModel>(context, listen: false);
    viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<EarnCreatooPointsViewModel>(context);
    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Earn Creatoo Points',
      ),
      body: Container(
        child: Form(
          key: viewModel.formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  // height: SizeConfig.screenHeight / 1.4,
                  margin: EdgeInsets.all(24.h),
                  padding: EdgeInsets.all(24.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.white.withOpacity(0.6),
                    border: Border.all(color: AppColor.lightGrey),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Earn Creatoo Points",
                        style: AppTextStyles.body(),
                      ),
                      SizedBox(height: 16.h),
                      SvgPicture.asset(
                        AppIcon.creatooPoints,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Earn Creatoo Points effortlessly!"
                        "Simply snap a photo of yourself and the bill, select "
                        "the business you visited,upload it on instagram "
                        "stories and tag our creatoo instagram handle and watch your points pile up. "
                        "Enjoy exciting rewards and cashback's for sharing your experiences. "
                        "It's your adventure, your points, your rewards.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(),
                      ),
                      SizedBox(height: 16.h),
                      DropdownSearch<Business>(
                        autoValidateMode: AutovalidateMode.disabled,
                        asyncItems: (String filter) async => await viewModel.fetchBusinessList(filter),
                        validator: (business) {
                          if (business == null) {
                            return "Please select Business";
                          }
                          return null;
                        },
                        dropdownButtonProps: DropdownButtonProps(
                          icon: Icon(Icons.keyboard_arrow_down),
                          autofocus: true,
                        ),
                        itemAsString: (Business u) => u.businessName!,
                        onChanged: (Business? data) async {
                          viewModel.model.businessId = data!.id;
                          if (data.id != null) {
                            viewModel.businessSelected = true;
                            await viewModel.fetchBusinessSettings(businessId: data.id!);
                          }
                          viewModel.notify();
                        },
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: "Select Business",
                            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          isFilterOnline: true,
                          fit: FlexFit.loose,
                          menuProps: MenuProps(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          searchFieldProps: TextFieldProps(
                            padding: EdgeInsets.all(20),
                            decoration: InputDecoration(
                              hintText: 'Enter Business Name',
                            ),
                          ),
                          emptyBuilder: (context, data) {
                            return viewModel.isLoading && data.isEmpty
                                ? SizedBox.shrink()
                                : data.length < 3
                                    ? Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Type at least 3 characters',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15.sp),
                                        ),
                                      )
                                    : Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Business not found',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15.sp),
                                        ),
                                      );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Media Upload",
                        style: AppTextStyles.header,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Points will get credited once it got approved.",
                        style: AppTextStyles.body(color: AppColor.darkGrey.withOpacity(0.5)),
                      ),
                      SizedBox(height: 16),
                      AppDottedBorderContainer(
                        width: SizeConfig.screenWidth,
                        height: (viewModel.model.image != null && viewModel.model.image!.isNotEmpty) ? 200.h : 160.h,
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: (viewModel.model.image != null && viewModel.model.image!.isNotEmpty),
                              child: Image.file(
                                // color: Colors.orange,
                                File(viewModel.model.image ?? ""),
                                height: 100.h,
                                width: 100.h,
                                fit: BoxFit.contain,
                              ),
                              replacement: Column(
                                children: [
                                  SvgPicture.asset(AppIcon.folder),
                                  SizedBox(height: 10.h),
                                  Text(
                                    'Upload Screenshot',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => viewModel.getImageAttachment(),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.primary),
                                  borderRadius: BorderRadius.circular(8),
                                  color: (viewModel.model.image != null && viewModel.model.image!.isNotEmpty)
                                      ? AppColor.primary
                                      : AppColor.white,
                                ),
                                child: Text(
                                  'Browse',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w400,
                                    color: (viewModel.model.image != null && viewModel.model.image!.isNotEmpty)
                                        ? AppColor.white
                                        : AppColor.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                //Enter Bill Amount Field
                if (viewModel.model.businessId != null && viewModel.businessSelected)
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(horizontal: 23),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Total Bill Amount',
                          style: TextStyle(fontSize: 16, color: AppColor.black, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppTextField(
                            disableBorder: true,
                            controller: viewModel.amountController,
                            hintText: "Total Bill Amount",
                            textInputType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                viewModel.model.billAmount = double.tryParse(value) ?? 0;
                                double amount = double.tryParse(value) ?? 0;
                                double percentageDecimal = (viewModel.discount ?? 0) / 100;
                                viewModel.percentageAmount = amount * percentageDecimal;
                                viewModel.pointsController.text =
                                    (viewModel.percentageAmount == 0) ? '0' : viewModel.percentageAmount.toStringAsFixed(0);
                                viewModel.model.points = viewModel.roundToTwoDecimalPlaces(viewModel.percentageAmount);
                                viewModel.notify();
                              } else {
                                viewModel.percentageAmount = 0;
                                viewModel.notify();
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 100.h,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.h),
        child: AppButton(
          text: "Submit",
          isLoading: viewModel.apiResponse.status == Status.loading,
          onTap: () async {
            if (!viewModel.formKey.currentState!.validate()) {
              return;
            }
            if (viewModel.model.image == null || viewModel.model.image!.isEmpty) {
              return Utils.toastMessage("Please upload screenshot");
            }
            if (viewModel.amountController.text.isEmpty) {
              return Utils.toastMessage("Bill Amount is required");
            }
            if (viewModel.amountController.text.isNotEmpty && (double.parse(viewModel.amountController.text) < viewModel.minAmount!)) {
              return Utils.toastMessage("Minimum Bill Amount should be ${viewModel.minAmount}");
            }
            await viewModel.requestCreatooPoints();
          },
        ),
      ),
    );
  }
}
