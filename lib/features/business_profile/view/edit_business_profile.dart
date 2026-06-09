import 'dart:ui';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../core.dart';
import '../view_model/edit_business_profile_view_model.dart';
import 'widgets/build_textfield_widget.dart';

class EditBusinessProfile extends StatefulWidget {
  final String initialTab;
  const EditBusinessProfile({super.key, this.initialTab = "My Profile"});

  @override
  State<EditBusinessProfile> createState() => _EditBusinessProfileState();
}

class _EditBusinessProfileState extends State<EditBusinessProfile> {
  late EditBusinessProfileViewModel viewModel;
  List<String> selectedImageNames = [];
  int _currentStep = 1;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    viewModel =
        Provider.of<EditBusinessProfileViewModel>(context, listen: false);
    viewModel.init(widget.initialTab);
  }

  @override
  void dispose() {
    viewModel.isEditing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<EditBusinessProfileViewModel>(context);

    switch (viewModel.profileResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.profileResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    final cat = viewModel.selectedBusinessCategory?.toLowerCase() ?? '';

    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          Positioned(
              top: -100.h,
              right: -50.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(
                    width: 350.w,
                    height: 350.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.premiumAccent.withValues(alpha: 0.15))),
              )),
          Positioned(
              bottom: 50.h,
              left: -80.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                    width: 300.w,
                    height: 300.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withValues(alpha: 0.1))),
              )),

          // App Bar
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      const CustomBackButton(),
                      SizedBox(width: 12.w),
                      Text("Edit Profile",
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _onSave(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: viewModel.isEditing
                                ? AppColor.premiumAccent
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: viewModel.isEditing
                                    ? AppColor.premiumAccent
                                    : Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Text(viewModel.isEditing ? "Save" : "Edit",
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 56.h),
              child: Form(
                key: viewModel.formKey,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildPersistentPhotos()),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StepIndicatorDelegate(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 4.h),
                          child: _buildStepIndicator(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          if (_currentStep == 1) _buildStep2(),
                          if (_currentStep == 2) _buildStep3(cat),
                          if (_currentStep == 3) _buildStep4(),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step Indicator ──

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF151520),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: List.generate(_totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            final idx = i ~/ 2;
            final done = _currentStep > idx + 1;
            final active = _currentStep == idx + 1;
            return Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: done
                      ? AppColor.premiumAccent
                      : active
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.08),
                ),
              ),
            );
          }

          final stepNum = (i ~/ 2) + 1;
          final active = _currentStep == stepNum;
          final done = _currentStep > stepNum;

          String label;
          if (stepNum == 1) {
            label = "Details";
          } else if (stepNum == 2) {
            label = "Shop";
          } else {
            label = "Discount";
          }

          return GestureDetector(
            onTap: () => setState(() => _currentStep = stepNum),
            child: Container(
              width: 52.w,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: active ? 26.w : 22.w,
                    height: active ? 26.w : 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done || active
                          ? AppColor.premiumAccent
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: done
                        ? Icon(Icons.check_rounded, color: Colors.white, size: 12.sp)
                        : Text("$stepNum",
                            style: GoogleFonts.montserrat(
                              color: active ? Colors.white : Colors.white54,
                              fontSize: active ? 11.sp : 10.sp,
                              fontWeight: FontWeight.w800,
                            )),
                  ),
                  SizedBox(height: 3.h),
                  Text(label,
                      style: GoogleFonts.montserrat(
                        color: active ? Colors.white : Colors.white54,
                        fontSize: 8.sp,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Photos ──

  Widget _buildPersistentPhotos() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(children: [
        SizedBox(height: 8.h),
        Row(children: [
          Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColor.premiumAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.image_rounded,
                  color: AppColor.premiumAccent, size: 16.sp)),
          SizedBox(width: 10.w),
          Text("Business Photos",
              style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700)),
        ]),
        SizedBox(height: 16.h),
        _buildImageSection(),
        SizedBox(height: 12.h),
      ]),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Stack(
            children: [
              PageView(physics: const BouncingScrollPhysics(), children: [
                _imageSlot(viewModel.businessImage),
                _imageSlot(viewModel.businessImage1),
                _imageSlot(viewModel.businessImage2),
                _imageSlot(viewModel.businessImage3),
                _imageSlot(viewModel.businessImage4),
                _imageSlot(viewModel.businessImage5),
              ]),
              Positioned(
                  bottom: 16.h,
                  right: 16.w,
                  child: GestureDetector(
                    onTap: viewModel.isEditing
                        ? () => _showImagePicker(false)
                        : () => Utils.toastMessage("Click 'Edit' first"),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColor.premiumAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: AppColor.premiumAccent
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 2)
                          ]),
                      child: Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 20.sp),
                    ),
                  )),
              if (viewModel.numberOfImages(isMenu: false) == 0)
                IgnorePointer(
                    child: Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: Colors.white30, size: 40.sp),
                  SizedBox(height: 8.h),
                  Text("Add Business Images",
                      style: GoogleFonts.montserrat(
                          color: Colors.white30, fontSize: 12.sp)),
                ]))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSlot(BusinessImage? image) {
    if (image == null) return const SizedBox.shrink();
    return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: image.file != null
            ? Image.file(image.file!, fit: BoxFit.cover, width: double.infinity)
            : image.url != null
                ? AppImageWidget(imageUrl: image.url!, fit: BoxFit.cover)
                : const SizedBox.shrink());
  }

  void _showImagePicker(bool isMenuCard) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.05))),
            child: Consumer<EditBusinessProfileViewModel>(
              builder: (context, vm, _) {
                int maxImages = isMenuCard ? 5 : 6;
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2))),
                  SizedBox(height: 24.h),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            isMenuCard ? "Menu Card Images" : "Business Images",
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700)),
                        IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white54),
                            onPressed: () => Navigator.pop(ctx)),
                      ]),
                  SizedBox(height: 20.h),
                  SizedBox(
                    height: 100.w,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: List.generate(maxImages, (index) {
                        BusinessImage? img;
                        if (isMenuCard) {
                          switch (index) {
                            case 0:
                              img = vm.menuImage1;
                              break;
                            case 1:
                              img = vm.menuImage2;
                              break;
                            case 2:
                              img = vm.menuImage3;
                              break;
                            case 3:
                              img = vm.menuImage4;
                              break;
                            case 4:
                              img = vm.menuImage5;
                              break;
                          }
                        } else {
                          switch (index) {
                            case 0:
                              img = vm.businessImage;
                              break;
                            case 1:
                              img = vm.businessImage1;
                              break;
                            case 2:
                              img = vm.businessImage2;
                              break;
                            case 3:
                              img = vm.businessImage3;
                              break;
                            case 4:
                              img = vm.businessImage4;
                              break;
                            case 5:
                              img = vm.businessImage5;
                              break;
                          }
                        }
                        return _imageBox(img, index, isMenuCard);
                      }),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  AppButton(
                      text: "Upload All",
                      onTap: () async {
                        Navigator.pop(ctx);
                        if (isMenuCard) {
                          vm.uploadMenuCardImages();
                        } else {
                          vm.uploadBusinessImages();
                        }
                      }),
                  SizedBox(height: 10.h),
                ]);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _imageBox(BusinessImage? image, int index, bool isMenuCard) {
    return GestureDetector(
      onTap: () async {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final file = File(pickedFile.path);
          void setImg(int i, BusinessImage? img) {
            if (isMenuCard) {
              switch (i) {
                case 0:
                  viewModel.menuImage1 = img;
                  break;
                case 1:
                  viewModel.menuImage2 = img;
                  break;
                case 2:
                  viewModel.menuImage3 = img;
                  break;
                case 3:
                  viewModel.menuImage4 = img;
                  break;
                case 4:
                  viewModel.menuImage5 = img;
                  break;
              }
            } else {
              switch (i) {
                case 0:
                  viewModel.businessImage = img;
                  break;
                case 1:
                  viewModel.businessImage1 = img;
                  break;
                case 2:
                  viewModel.businessImage2 = img;
                  break;
                case 3:
                  viewModel.businessImage3 = img;
                  break;
                case 4:
                  viewModel.businessImage4 = img;
                  break;
                case 5:
                  viewModel.businessImage5 = img;
                  break;
              }
            }
          }

          setImg(index, BusinessImage(file: file));
          viewModel.notify();
        }
      },
      child: Container(
        height: 90.w,
        width: 90.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColor.premiumAccent.withValues(alpha: 0.3))),
        child: image != null
            ? Stack(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: image.file != null
                        ? Image.file(image.file!,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity)
                        : AppImageWidget(
                            imageUrl: image.url ?? '', fit: BoxFit.cover)),
                Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        viewModel.clearImage(index, isMenuCard: isMenuCard);
                        viewModel.notify();
                      },
                      child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 14)),
                    )),
              ])
            : Icon(Icons.add_rounded,
                color: AppColor.premiumAccent, size: 24.sp),
      ),
    );
  }

  // ── Step 1: Details ──

  Widget _buildStep2() {
    return Column(
      children: [
        _buildSectionHeader(
            1, "Details", "Business info & contact", Icons.info_rounded),
        SizedBox(height: 16.h),
        _buildCard("Business Information", Icons.business_center_rounded, [
          buildTextField(
              context, "Business Name", viewModel.businessNameController,
              readOnly: !viewModel.isEditing),
          buildTextField(
              context, "Business Area", viewModel.businessAreaController,
              readOnly: !viewModel.isEditing, maxLines: 2),
          buildTextField(context, "Complete Address",
              viewModel.businessCompleteAddressController,
              readOnly: !viewModel.isEditing, maxLines: 4),
          buildTextField(
              isRequired: false,
              context,
              "Website",
              viewModel.businessWebsiteController,
              readOnly: !viewModel.isEditing),
        ]),
        SizedBox(height: 16.h),
        _buildCard("Contact Person", Icons.person_rounded, [
          buildTextField(
              context, "Full Name", viewModel.businessFullNameController,
              readOnly: !viewModel.isEditing,
              capitaliseText: TextCapitalization.words),
          buildTextField(
              context, "Designation", viewModel.businessDesignationController,
              readOnly: !viewModel.isEditing),
          buildTextField(
              context, "Mobile Number", viewModel.businessMobileController,
              readOnly: !viewModel.isEditing),
          buildTextField(context, "Email", viewModel.businessEmailController,
              readOnly: !viewModel.isEditing),
        ]),
        SizedBox(height: 16.h),
        _buildNavButtons(),
      ],
    );
  }

  // ── Step 2: Shop + Category ──

  Widget _buildStep3(String cat) {
    return Column(children: [
      _buildSectionHeader(2, "Shop & Services",
          "Timings, pricing & category details", Icons.store_rounded),
      SizedBox(height: 16.h),
      _buildCard("Shop Details", Icons.store_rounded, [
        _buildTimeField(context, "Opening Time", viewModel.fromTimeController,
            isFrom: true),
        SizedBox(height: 12.h),
        _buildTimeField(context, "Closing Time", viewModel.toTimeController,
            isFrom: false),
      ]),
      SizedBox(height: 16.h),
      _buildCard("Business Identity", Icons.badge_rounded, [
        buildTextField(context, "GSTIN NO", viewModel.businessGstNoController,
            readOnly: !viewModel.isEditing,
            capitaliseText: TextCapitalization.characters,
            maxLength: 15),
        buildTextField(
            isRequired: false,
            context,
            "UPI ID",
            viewModel.upiIdController,
            readOnly: !viewModel.isEditing),
        _buildCategoryDropdown(),
      ]),
      SizedBox(height: 16.h),
      // if (cat == 'restaurant') _buildRestaurantSection(),
      if (cat == 'salon') _buildSalonSection(),
      if (cat == 'turf') _buildTurfSection(),
      SizedBox(height: 16.h),
      _buildNavButtons(),
    ]);
  }

  // ── Step 3: Discount ──

  Widget _buildStep4() {
    return Column(children: [
      _buildSectionHeader(3, "Discounts", "Set first-time & regular offers",
          Icons.local_offer_rounded),
      SizedBox(height: 16.h),
      _buildCard("Discounts", Icons.local_offer_rounded, [
        _buildDiscountField("First Time Discount (%)",
            viewModel.setFirstTimeDiscountController),
        SizedBox(height: 16.h),
        _buildDiscountField(
            "Regular Discount (%)", viewModel.setRegularDiscountController),
        SizedBox(height: 8.h),
        Text("First Time Discount should be higher than Regular",
            style:
                GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white38)),
      ]),
      SizedBox(height: 24.h),
      AppButton(
        onTap: () => _onSave(),
        text: viewModel.isEditing ? "Save All Changes" : "Enable Editing",
        isIconEnabled: true,
        icon: viewModel.isEditing
            ? Icons.check_circle_rounded
            : Icons.edit_rounded,
      ),
    ]);
  }

  // ── Category Sections ──

  Widget _buildRestaurantSection() {
    final cuisines = [
      "Indian",
      "Chinese",
      "Italian",
      "Continental",
      "Mexican",
      "Fast Food",
      "Thai",
      "Japanese"
    ];
    return _buildCard("Restaurant Details", Icons.restaurant_rounded, [
      buildTextField(
          isRequired: false,
          context,
          "Seating Capacity",
          viewModel.seatingCapacityController,
          readOnly: !viewModel.isEditing,
          keyboardType: TextInputType.number),
      SizedBox(height: 4.h),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("Pure Vegetarian?",
            style: GoogleFonts.montserrat(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white70)),
        Switch(
            value: viewModel.isVegOnly,
            activeTrackColor: AppColor.premiumAccent.withValues(alpha: 0.3),
            activeThumbColor: AppColor.premiumAccent,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
            onChanged: viewModel.isEditing
                ? (val) {
                    viewModel.isVegOnly = val;
                    viewModel.notify();
                  }
                : null),
      ]),
      SizedBox(height: 12.h),
      Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text('Cuisines Offered',
              style: GoogleFonts.montserrat(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.premiumTextSecondary))),
      Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: cuisines.map((cuisine) {
            final isSelected = viewModel.selectedCuisines.contains(cuisine);
            return FilterChip(
              label: Text(cuisine,
                  style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white70)),
              selected: isSelected,
              selectedColor: AppColor.premiumAccent,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.03),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: isSelected
                          ? AppColor.premiumAccent
                          : Colors.white.withValues(alpha: 0.1))),
              onSelected: viewModel.isEditing
                  ? (selected) {
                      if (selected) {
                        viewModel.selectedCuisines.add(cuisine);
                      } else {
                        viewModel.selectedCuisines.remove(cuisine);
                      }
                      viewModel.notify();
                    }
                  : null,
            );
          }).toList()),
    ]);
  }

  Widget _buildSalonSection() {
    return _buildCard("Salon Details", Icons.content_cut_rounded, [
      buildTextField(
          isRequired: false,
          context,
          "Number of Stylists / Chairs",
          viewModel.stylistsCountController,
          readOnly: !viewModel.isEditing,
          keyboardType: TextInputType.number),
      SizedBox(height: 8.h),
      Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text('Gender Specialty',
              style: GoogleFonts.montserrat(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.premiumTextSecondary))),
      Row(
          children: ['men', 'women', 'unisex'].map((gender) {
        final isSelected = viewModel.selectedGenderSupport == gender;
        final label = gender == 'men'
            ? 'Men Only'
            : (gender == 'women' ? 'Women Only' : 'Unisex');
        return Expanded(
            child: GestureDetector(
          onTap: viewModel.isEditing
              ? () {
                  viewModel.selectedGenderSupport = gender;
                  viewModel.notify();
                }
              : null,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.premiumAccent
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected
                      ? AppColor.premiumAccent
                      : Colors.white.withValues(alpha: 0.1)),
            ),
            child: Center(
                child: Text(label,
                    style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white70))),
          ),
        ));
      }).toList()),
    ]);
  }

  Widget _buildTurfSection() {
    return Column(children: [
      _buildCard("Turf Details", Icons.sports_soccer_rounded, [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h, left: 2.w),
                    child: Text(
                      'Court Size',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.premiumTextSecondary,
                      ),
                    ),
                  ),
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      constraints: BoxConstraints(
                        maxHeight: (viewModel.turfCourtSizes.isNotEmpty
                                ? viewModel.turfCourtSizes.length
                                : 4) *
                            42.h,
                      ),
                      menuProps: MenuProps(
                        backgroundColor: const Color(0xFF1E1E2E),
                        borderRadius: BorderRadius.circular(12),
                        elevation: 10,
                      ),
                      itemBuilder: (context, item, isSelected) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColor.premiumAccent.withValues(alpha: 0.15)
                                : null,
                          ),
                          child: Text(
                            item,
                            style: GoogleFonts.montserrat(
                              color: isSelected
                                  ? AppColor.premiumAccent
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    dropdownButtonProps: DropdownButtonProps(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white38,
                        size: 16.sp,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    items: viewModel.turfCourtSizes.isNotEmpty
                        ? viewModel.turfCourtSizes
                        : ["5v5", "7v7", "9v9", "11v11"],
                    selectedItem: viewModel.selectedTurfSize,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        fillColor: Colors.white.withValues(alpha: 0.02),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColor.premiumAccent, width: 1.2),
                        ),
                        hintText: "Court Size",
                        hintStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      baseStyle: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onChanged: viewModel.isEditing
                        ? (val) {
                            viewModel.selectedTurfSize = val ??
                                viewModel.turfCourtSizes.firstOrNull ??
                                '7v7';
                            viewModel.notify();
                          }
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h, left: 2.w),
                    child: Text(
                      'Ground Type',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.premiumTextSecondary,
                      ),
                    ),
                  ),
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      constraints: BoxConstraints(
                        maxHeight: (viewModel.turfGroundTypes.isNotEmpty
                                ? viewModel.turfGroundTypes.length
                                : 4) *
                            42.h,
                      ),
                      menuProps: MenuProps(
                        backgroundColor: const Color(0xFF1E1E2E),
                        borderRadius: BorderRadius.circular(12),
                        elevation: 10,
                      ),
                      itemBuilder: (context, item, isSelected) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColor.premiumAccent.withValues(alpha: 0.15)
                                : null,
                          ),
                          child: Text(
                            item,
                            style: GoogleFonts.montserrat(
                              color: isSelected
                                  ? AppColor.premiumAccent
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    dropdownButtonProps: DropdownButtonProps(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white38,
                        size: 16.sp,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    items: viewModel.turfGroundTypes.isNotEmpty
                        ? viewModel.turfGroundTypes
                        : [
                            "Artificial Grass",
                            "Natural Grass",
                            "Clay Court",
                            "Wooden Floor"
                          ],
                    selectedItem: viewModel.selectedGroundType,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        fillColor: Colors.white.withValues(alpha: 0.02),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColor.premiumAccent, width: 1.2),
                        ),
                        hintText: "Ground Type",
                        hintStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      baseStyle: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onChanged: viewModel.isEditing
                        ? (val) {
                            viewModel.selectedGroundType = val ??
                                viewModel.turfGroundTypes.firstOrNull ??
                                'Artificial Grass';
                            viewModel.notify();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
    ]);
  }

  // ── Shared Widgets ──

  Widget _buildSectionHeader(
      int step, String title, String subtitle, IconData icon) {
    return Row(children: [
      Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              AppColor.premiumAccent,
              AppColor.premiumAccent.withValues(alpha: 0.5),
            ]),
            boxShadow: [BoxShadow(color: AppColor.premiumAccent.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 0)]),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
      SizedBox(width: 14.w),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800)),
        Text(subtitle,
            style:
                GoogleFonts.montserrat(color: Colors.white38, fontSize: 11.sp)),
      ])),
    ]);
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColor.premiumAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child:
                      Icon(icon, color: AppColor.premiumAccent, size: 16.sp)),
              SizedBox(width: 10.w),
              Text(title,
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700)),
            ]),
            SizedBox(height: 14.h),
            Divider(color: Colors.white.withValues(alpha: 0.06)),
            SizedBox(height: 6.h),
            ...children,
          ]),
        ),
      ),
    );
  }

  Widget _buildNavButtons() {
    return Row(children: [
      if (_currentStep > 1)
        Expanded(
            child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
          onPressed: () => setState(() => _currentStep--),
          child: Text("← Previous",
              style: GoogleFonts.montserrat(
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp)),
        )),
      if (_currentStep > 1) SizedBox(width: 12.w),
      if (_currentStep < _totalSteps)
        Expanded(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.premiumAccent,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
          onPressed: () => setState(() => _currentStep++),
          child: Text("Next →",
              style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp)),
        )),
    ]);
  }

  // ── Category Dropdown ──

  Widget _buildCategoryDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text("Business Category",
              style: GoogleFonts.montserrat(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.premiumTextSecondary))),
      DropdownSearch<String>(
        popupProps: PopupProps.menu(
          constraints: BoxConstraints(
            maxHeight: 3 * 42.h,
          ),
          menuProps: MenuProps(
            backgroundColor: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
          ),
          itemBuilder: (context, item, isSelected) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.premiumAccent.withValues(alpha: 0.15) : null,
              ),
              child: Text(item, style: GoogleFonts.montserrat(
                color: isSelected ? AppColor.premiumAccent : Colors.white70,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13.sp,
              )),
            );
          },
        ),
        items: viewModel.businessCategories,
        selectedItem: viewModel.selectedBusinessCategory,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
              hintText: "Select Category",
              fillColor: Colors.white.withValues(alpha: 0.03),
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColor.premiumAccent, width: 1)),
              hintStyle: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.25))),
          baseStyle: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600),
        ),
        onChanged: viewModel.isEditing
            ? (String? data) {
                if (data != null &&
                    data !=
                        viewModel
                            .profileResponse.data?.data?.businessCategory) {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF2A2A2A),
                            title: Text("Change Category?",
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            content: Text(
                                "Changing category will reset custom details once saved.",
                                style: GoogleFonts.montserrat(
                                    color: Colors.white70)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text("Cancel",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.white54))),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.premiumAccent),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    viewModel.updateBusinessCategory(data);
                                  },
                                  child: Text("Proceed",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold))),
                            ],
                          ));
                } else if (data != null) {
                  viewModel.updateBusinessCategory(data);
                }
              }
            : null,
      ),
    ]);
  }

  // ── Time & Pricing ──

  Widget _buildTimeField(
      BuildContext context, String label, TextEditingController? ctrl,
      {required bool isFrom}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.premiumTextSecondary))),
      TextField(
        controller: ctrl,
        readOnly: true,
        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: "Tap to select time",
          hintStyle:
              GoogleFonts.montserrat(color: Colors.white24, fontSize: 14.sp),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.03),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          suffixIcon: Icon(Icons.access_time_rounded,
              color: AppColor.premiumAccent, size: 20.sp),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColor.premiumAccent, width: 1.5)),
        ),
        onTap: () async {
          if (!viewModel.isEditing) {
            Utils.toastMessage("Click 'Edit' first");
            return;
          }
          TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                      primary: AppColor.premiumAccent,
                      onPrimary: Colors.white,
                      surface: const Color(0xFF1A1A1A),
                      onSurface: Colors.white),
                  dialogTheme:
                      const DialogThemeData(backgroundColor: Color(0xFF1A1A1A)),
                ),
                child: child!),
          );
          if (picked != null) {
            final h = picked.hour.toString().padLeft(2, '0');
            final m = picked.minute.toString().padLeft(2, '0');
            ctrl?.text = '$h:$m';
            viewModel.notify();
          }
        },
      ),
    ]);
  }

  // ── Discount ──

  Widget _buildDiscountField(String label, TextEditingController? ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.premiumTextSecondary))),
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        readOnly: !viewModel.isEditing,
        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: "e.g. ${label.contains('First') ? '20' : '10'}",
          hintStyle:
              GoogleFonts.montserrat(color: Colors.white24, fontSize: 14.sp),
          suffixText: "% OFF",
          suffixStyle: GoogleFonts.montserrat(
              color: AppColor.premiumAccent,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.03),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColor.premiumAccent, width: 1.5)),
        ),
      ),
    ]);
  }

  // ── Save Logic ──

  void _onSave() async {
    if (!viewModel.isEditing) {
      viewModel.enableEditing(true);
      return;
    }

    if (_currentStep == 3) {
      final firstDisc = viewModel.setFirstTimeDiscountController?.text ?? '';
      final regDisc = viewModel.setRegularDiscountController?.text ?? '';
      if (firstDisc.isEmpty || regDisc.isEmpty) {
        Utils.toastMessage("Please enter both discount values");
        return;
      }
      if (int.parse(firstDisc) < int.parse(regDisc)) {
        Utils.toastMessage("First Time Discount should be higher than Regular");
        return;
      }
    }

    if (!viewModel.formKey.currentState!.validate()) return;

    await viewModel.updateBusinessProfile();
    await viewModel.updateBusinessDescriptionApiCall();
    await viewModel.updateBusinessDiscountApiCall();
    viewModel.enableEditing(false);
  }
}

class _StepIndicatorDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StepIndicatorDelegate({required this.child});

  @override
  double get minExtent => 68.h;
  @override
  double get maxExtent => 68.h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StepIndicatorDelegate oldDelegate) =>
      child != oldDelegate.child;
}
