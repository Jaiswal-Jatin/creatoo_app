import 'dart:ui';
import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
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
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100.h,
            right: -50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.1),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Form(
              key: viewModel.formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60.h), // Space for back button

                    // Hero Section - Glassmorphic Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.premiumAccent.withOpacity(0.1),
                                ),
                                child: SvgPicture.asset(
                                  AppIcon.creatooPoints,
                                  height: 60.h,
                                  width: 60.w,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              AppTextWidget(
                                text: "Earn Creatoo Points",
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              SizedBox(height: 12.h),
                              AppTextWidget(
                                text: "Snap a photo of yourself and the bill, select the business, upload on Instagram stories, and tag us to earn points effortlessly!",
                                textAlign: TextAlign.center,
                                fontSize: 13.sp,
                                color: AppColor.premiumTextSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Selection Section
                    _buildLabel("Select Business"),
                    SizedBox(height: 12.h),
                    _buildBusinessDropdown(viewModel),

                    SizedBox(height: 24.h),

                    // Media Section
                    _buildLabel("Media Upload"),
                    SizedBox(height: 4.h),
                    AppTextWidget(
                      text: "Points will get credited once it got approved.",
                      fontSize: 12.sp,
                      color: AppColor.premiumTextSecondary.withOpacity(0.7),
                    ),
                    SizedBox(height: 16.h),
                    _buildMediaUpload(viewModel),

                    // Bill Amount Section
                    if (viewModel.model.businessId != null && viewModel.businessSelected) ...[
                      SizedBox(height: 24.h),
                      _buildLabel("Total Bill Amount"),
                      SizedBox(height: 12.h),
                      _buildAmountField(viewModel),
                    ],

                    SizedBox(height: 120.h), // Bottom spacing for FAB
                  ],
                ),
              ),
            ),
          ),

          // Custom Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 16.w,
            child: CustomBackButton(
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        child: AppButton(
          text: "Submit Verification",
          isLoading: viewModel.apiResponse.status == Status.loading,
          onTap: () => _handleSubmit(viewModel),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return AppTextWidget(
      text: text,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
  }

  Widget _buildBusinessDropdown(EarnCreatooPointsViewModel viewModel) {
    return DropdownSearch<Business>(
      autoValidateMode: AutovalidateMode.disabled,
      asyncItems: (String filter) async => await viewModel.fetchBusinessList(filter),
      validator: (business) => business == null ? "Please select Business" : null,
      dropdownButtonProps: DropdownButtonProps(
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
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
          hintStyle: TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColor.premiumAccent.withOpacity(0.5)),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        isFilterOnline: true,
        fit: FlexFit.loose,
        containerBuilder: (context, child) => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: child,
            ),
          ),
        ),
        searchFieldProps: TextFieldProps(
          padding: EdgeInsets.all(16),
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search Business...',
            hintStyle: TextStyle(color: Colors.white38),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        emptyBuilder: (context, data) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: AppTextWidget(
                text: data.length < 3 ? 'Type at least 3 characters' : 'Business not found',
                color: Colors.white54,
                fontSize: 14.sp,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaUpload(EarnCreatooPointsViewModel viewModel) {
    bool hasImage = viewModel.model.image != null && viewModel.model.image!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          height: hasImage ? 240.h : 180.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: AppDottedBorderContainer(
            width: double.infinity,
            height: double.infinity,
            color: hasImage ? Colors.transparent : Colors.white24,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(viewModel.model.image!),
                      height: 120.h,
                      width: 120.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16.h),
                ] else ...[
                  Icon(Icons.cloud_upload_outlined, size: 48, color: AppColor.premiumAccent.withOpacity(0.5)),
                  SizedBox(height: 12.h),
                  AppTextWidget(
                    text: 'Upload Screenshot',
                    fontSize: 14.sp,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16.h),
                ],
                InkWell(
                  onTap: () => viewModel.getImageAttachment(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 32.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasImage 
                          ? [Colors.white24, Colors.white12]
                          : [AppColor.premiumAccent.withOpacity(0.8), AppColor.premiumAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppTextWidget(
                      text: hasImage ? 'Change Photo' : 'Browse Files',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: hasImage ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField(EarnCreatooPointsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: AppTextField(
        disableBorder: true,
        controller: viewModel.amountController,
        hintText: "0.00",
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
        ),
        textInputType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    );
  }

  Future<void> _handleSubmit(EarnCreatooPointsViewModel viewModel) async {
    if (!viewModel.formKey.currentState!.validate()) return;
    
    if (viewModel.model.image == null || viewModel.model.image!.isEmpty) {
      return Utils.toastMessage("Please upload screenshot");
    }
    
    if (viewModel.amountController.text.isEmpty) {
      return Utils.toastMessage("Bill Amount is required");
    }
    
    if (viewModel.amountController.text.isNotEmpty && 
        (double.parse(viewModel.amountController.text) < viewModel.minAmount!)) {
      return Utils.toastMessage("Minimum Bill Amount should be ${viewModel.minAmount}");
    }
    
    await viewModel.requestCreatooPoints();
  }
}
