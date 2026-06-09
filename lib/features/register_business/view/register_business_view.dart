import 'dart:io';
import 'dart:ui';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/register_business/view_model/register_business_view_model.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import 'package:dropdown_search/dropdown_search.dart';
class RegisterBusinessView extends StatefulWidget {
  final String phone;

  const RegisterBusinessView({super.key, required this.phone});

  @override
  State<RegisterBusinessView> createState() => _RegisterBusinessViewState();
}

class _RegisterBusinessViewState extends State<RegisterBusinessView> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    final RegisterBusinessViewModel registerBusinessViewModel =
        Provider.of<RegisterBusinessViewModel>(context, listen: false);
    registerBusinessViewModel.init(widget.phone);
  }

  void _nextStep(RegisterBusinessViewModel viewModel) {
    if (_validateCurrentStep(viewModel)) {
      setState(() {
        if (_currentStep < _totalSteps - 1) {
          _currentStep++;
        }
      });
    }
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  bool _validateCurrentStep(RegisterBusinessViewModel viewModel) {
    if (_currentStep == 0) {
      if (viewModel.model.businessCategory == null) {
        Utils.toastMessage("Please select a business category");
        return false;
      }
      if (viewModel.model.businessImage == null) {
        Utils.toastMessage("Please attach a profile logo image");
        return false;
      }
      if (viewModel.businessNameController.text.trim().isEmpty) {
        Utils.toastMessage("Please enter Business Name");
        return false;
      }
      if (viewModel.businessAreaController.text.trim().isEmpty) {
        Utils.toastMessage("Please enter Area / Locality");
        return false;
      }
      if (viewModel.businessAddressController.text.trim().isEmpty) {
        Utils.toastMessage("Please enter Complete Address");
        return false;
      }
      return true;
    }

    if (_currentStep == 1) {
      if (viewModel.businessFullnameController.text.trim().isEmpty) {
        Utils.toastMessage("Please enter Representative Full Name");
        return false;
      }
      if (viewModel.businessDesignationController.text.trim().isEmpty) {
        Utils.toastMessage("Please enter Representative Designation");
        return false;
      }
      final email = viewModel.businessEmailController.text.trim();
      if (email.isEmpty) {
        Utils.toastMessage("Please enter Business Mail");
        return false;
      }
      final bool emailValid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email);
      if (!emailValid) {
        Utils.toastMessage("Please enter a valid Business Email");
        return false;
      }
      return true;
    }

    if (_currentStep == 2) {
      final gst = viewModel.gstNumberController.text.trim();
      if (gst.isNotEmpty && gst.length != 15) {
        Utils.toastMessage("GSTIN must be exactly 15 characters");
        return false;
      }
      return true;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final RegisterBusinessViewModel viewModel =
        Provider.of<RegisterBusinessViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          _previousStep();
          return false;
        }
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesName.startupView, (route) => false);
        return true;
      },
      child: AppScaffold(
        useGradient: true,
        backgroundColor: AppColor.premiumBg,
        isSafe: false,
        body: Stack(
          children: [
            // Background Ambient Glows
            Positioned(
              top: -100.h,
              right: -100.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  width: 300.w,
                  height: 300.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.premiumAccent.withOpacity(0.12),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100.h,
              left: -50.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.premiumAccent.withOpacity(0.08),
                  ),
                ),
              ),
            ),

            // Scrollable Content
            SafeArea(
              child: Column(
                children: [
                  // Step Progress Header Widget
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 50.h, 24.w, 0),
                    child: _buildProgressHeader(),
                  ),

                  // Dynamic Step form container
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      physics: const BouncingScrollPhysics(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 1.2,
                              ),
                            ),
                            child: Form(
                              key: viewModel.formKey,
                              child: _buildStepContent(viewModel),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 70.h), // Safe spacing for navigation panel
                ],
              ),
            ),

            // Premium Navigation Top Overlay
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 16.w,
              child: CustomBackButton(
                onTap: () {
                  if (_currentStep > 0) {
                    _previousStep();
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RoutesName.startupView, (route) => false);
                  }
                },
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 15.h,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    "Register Business",
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Wizard Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomWizardBar(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final steps = ["Identity", "Representative", "Documents"];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isCompleted = _currentStep > index;
          final isActive = _currentStep == index;
          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28.h,
                  height: 28.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: (isActive || isCompleted)
                        ? LinearGradient(
                            colors: [AppColor.premiumAccent, AppColor.premiumAccent.withOpacity(0.8)],
                          )
                        : null,
                    color: !(isActive || isCompleted) ? Colors.white.withOpacity(0.05) : null,
                    border: Border.all(
                      color: isActive
                          ? AppColor.premiumAccent
                          : (isCompleted ? Colors.transparent : Colors.white24),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                        : Text(
                            (index + 1).toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: (isActive || isCompleted) ? Colors.white : Colors.white30,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 8.w),
                if (isActive)
                  Expanded(
                    child: Text(
                      steps[index],
                      style: GoogleFonts.montserrat(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (index < steps.length - 1 && !isActive)
                  Expanded(
                    child: Container(
                      height: 1.5,
                      color: isCompleted ? AppColor.premiumAccent : Colors.white12,
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(RegisterBusinessViewModel viewModel) {
    switch (_currentStep) {
      case 0:
        return _buildIdentityStep(viewModel);
      case 1:
        return _buildRepresentativeStep(viewModel);
      default:
        return _buildDocumentsStep(viewModel);
    }
  }

  Widget _buildIdentityStep(RegisterBusinessViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Identity & Branding",
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Select your business category, upload a logo, and provide business and location details.",
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            color: AppColor.premiumTextSecondary,
          ),
        ),
        SizedBox(height: 24.h),

        // Business Category selector
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            'Business Category',
            style: GoogleFonts.montserrat(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
        DropdownSearch<String>(
          popupProps: PopupProps.menu(
            constraints: BoxConstraints(
              maxHeight: 3 * 54.h,
            ),
            menuProps: MenuProps(
              backgroundColor: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context, item, isSelected) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                child: Text(
                  item.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: isSelected ? AppColor.premiumAccent : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
              );
            },
          ),
          items: viewModel.businessCategories,
          selectedItem: viewModel.model.businessCategory,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: "Select Business Category",
              fillColor: Colors.white.withOpacity(0.02),
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColor.premiumAccent, width: 1.5),
              ),
            ),
            baseStyle: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          onChanged: (String? data) => viewModel.updateBusinessCategory(data!),
        ),
        SizedBox(height: 24.h),

        // Business Logo / Image Picker
        Center(
          child: GestureDetector(
            onTap: () async => await viewModel.getImageAttachment(),
            child: AppValidator(
              validator: (viewModel.model.businessImage == null),
              isValidating: viewModel.isValidating,
              errorMessage: "Please upload a business logo",
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.premiumAccent.withOpacity(0.5),
                        width: 2.2,
                      ),
                    ),
                    child: viewModel.model.businessImage == null
                        ? Container(
                            height: 110.h,
                            width: 110.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.04),
                            ),
                            child: Icon(
                              Icons.add_a_photo_outlined,
                              size: 32.h,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          )
                        : ClipOval(
                            child: Image.file(
                              File(viewModel.model.businessImage!),
                              height: 110.h,
                              width: 110.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 4.h,
                    right: 4.h,
                    child: Container(
                      height: 30.h,
                      width: 30.h,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColor.premiumAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.premiumBg,
                          width: 2.0,
                        ),
                      ),
                      child: SvgPicture.asset(
                        AppIcon.edit,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: Text(
            viewModel.model.businessImage == null ? "Tap to upload Business Logo" : "Logo Uploaded Successfully",
            style: GoogleFonts.montserrat(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: viewModel.model.businessImage == null ? Colors.white30 : AppColor.activeGreen,
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Business Name
        _buildStepInputField(
          controller: viewModel.businessNameController,
          label: "Business Name",
          hint: "e.g. Fine Dine Cafe",
        ),
        SizedBox(height: 16.h),

        // Area
        _buildStepInputField(
          controller: viewModel.businessAreaController,
          label: "Area / Locality",
          hint: "e.g. Koregaon Park",
        ),
        SizedBox(height: 16.h),

        // Complete Address
        _buildStepInputField(
          controller: viewModel.businessAddressController,
          label: "Complete Address",
          hint: "e.g. Row House 5, Lane 7, Pune",
          maxLines: 2,
        ),
        SizedBox(height: 16.h),

        // Website URL
        _buildStepInputField(
          controller: viewModel.businessSiteUrlController,
          label: "Website URL (Optional)",
          hint: "e.g. www.finedinecafe.com",
        ),
      ],
    );
  }

  Widget _buildRepresentativeStep(RegisterBusinessViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Business Representative",
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Provide representative details and direct contact coordinates.",
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            color: AppColor.premiumTextSecondary,
          ),
        ),
        SizedBox(height: 24.h),

        // Representative Full Name
        _buildStepInputField(
          controller: viewModel.businessFullnameController,
          label: "Representative Full Name",
          hint: "e.g. Rohan Sharma",
        ),
        SizedBox(height: 16.h),

        // Designation
        _buildStepInputField(
          controller: viewModel.businessDesignationController,
          label: "Designation",
          hint: "e.g. Managing Director",
        ),
        SizedBox(height: 16.h),

        // Business Mail
        _buildStepInputField(
          controller: viewModel.businessEmailController,
          label: "Representative Business Mail",
          hint: "e.g. contact@finedine.com",
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),

        // Phone (Read-Only)
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            'Mobile Number',
            style: GoogleFonts.montserrat(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.premiumTextSecondary,
            ),
          ),
        ),
        AppTextField(
          controller: TextEditingController(text: widget.phone),
          backgroundColor: Colors.white.withOpacity(0.02),
          textColor: Colors.white38,
          readOnly: true,
          borderRadius: 16,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          disableBorder: false,
        ),
      ],
    );
  }

  Widget _buildDocumentsStep(RegisterBusinessViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Documentation & Billing",
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Provide tax identifiers, digital payment details, and dynamic government licenses.",
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            color: AppColor.premiumTextSecondary,
          ),
        ),
        SizedBox(height: 24.h),

        // GST Number
        _buildStepInputField(
          controller: viewModel.gstNumberController,
          label: "GSTIN (Optional)",
          hint: "15-digit GST Number",
          capitalization: TextCapitalization.characters,
          maxLength: 15,
        ),
        SizedBox(height: 16.h),

        // UPI ID
        _buildStepInputField(
          controller: viewModel.upiIdController,
          label: "UPI ID (Optional)",
          hint: "e.g. business@okaxis",
        ),
      ],
    );
  }

  Widget _buildStepInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.sentences,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.premiumTextSecondary,
            ),
          ),
        ),
        AppTextField(
          controller: controller,
          hintText: hint,
          textInputType: keyboardType,
          backgroundColor: Colors.white.withOpacity(0.03),
          textColor: Colors.white,
          cursorColor: AppColor.premiumAccent,
          borderColor: Colors.white.withOpacity(0.1),
          focusedBorderColor: AppColor.premiumAccent,
          borderRadius: 16,
          maxLines: maxLines,
          maxLength: maxLength,
          capitaliseText: capitalization,
          textStyle: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: GoogleFonts.montserrat(
            color: Colors.white.withOpacity(0.2),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          disableBorder: false,
        ),
      ],
    );
  }

  Widget _buildBottomWizardBar(RegisterBusinessViewModel viewModel) {
    final isLastStep = _currentStep >= _totalSteps - 1;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, MediaQuery.of(context).padding.bottom + 16.h),
          // decoration: BoxDecoration(
          //   color: AppColor.premiumBg.withOpacity(0.85),
          //   border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.0),
          //   borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          // ),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: AppButton(
                      text: "Back",
                      buttonColor: Colors.white.withOpacity(0.06),
                      isIconEnabled: false,
                      textColor: Colors.white70,
                      onTap: _previousStep,
                    ),
                  ),
                ),
              Expanded(
                flex: 3,
                child: AppButton(
                  text: isLastStep ? "Complete Registration" : "Next Step",
                  isLoading: viewModel.businessResponse.status == Status.loading,
                  onTap: isLastStep
                      ? () async {
                          viewModel.setValidatingStatus(true);
                          if (viewModel.formKey.currentState!.validate()) {
                            if (_validateCurrentStep(viewModel)) {
                              await viewModel.registerBusiness();
                            }
                          }
                        }
                      : () => _nextStep(viewModel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
