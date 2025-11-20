import '../../../core.dart';
import '../../../widgets/app_chip_choice_widget.dart';
import '../../../widgets/app_text_widget.dart';
import '../view_model/edit_business_profile_view_model.dart';
import 'widgets/business_description_widget.dart';
import 'widgets/my_profile_widget.dart';
import 'widgets/set_discount_widget.dart';

class EditBusinessProfile extends StatefulWidget {
  final String initialTab;
  const EditBusinessProfile({super.key, this.initialTab = "My Profile"});

  @override
  State<EditBusinessProfile> createState() => _EditBusinessProfileState();
}

class _EditBusinessProfileState extends State<EditBusinessProfile> {
  late EditBusinessProfileViewModel viewModel;
  List<String> selectedImageNames = [];

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<EditBusinessProfileViewModel>(context, listen: false);
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
        return AppErrorWidget(message: viewModel.profileResponse.message.toString());
      case Status.completed:
        final List<String> options = ['My Profile', 'Details', 'Set Discount'];

        return AppScaffold(
          appBar: AppBarWidget(title: viewModel.selectedTab ?? ""),
          body: Form(
            key: viewModel.formKey,
            child: Container(
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Column(
                      children: [
                        Center(
                          child: (viewModel.model.businessImage == null || viewModel.model.businessImage!.isEmpty)
                              ? _buildImageWidget()
                              : Image.file(
                                  File(viewModel.model.businessImage!),
                                  width: double.maxFinite,
                                  height: 200.h,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 14.w),
                    child: AppChipChoiceWidget(
                      options: options,
                      selectedItems: [viewModel.selectedTab!],
                      onSelectionChanged: (option, isSelected) {
                        viewModel.updateFields();
                        viewModel.selectTab(option);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
                    child: Column(
                      children: [
                        SizedBox(height: 15.h),
                        _buildTabContent(
                          selectedTabMain: viewModel.selectedTab,
                        ),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.h),
            child: AppButton(
              isIconEnabled: true,
              onTap: () async {
                if (viewModel.isEditing) {
                  if (viewModel.selectedTab == 'My Profile') {
                    if (viewModel.formKey.currentState!.validate()) {
                      await viewModel.updateBusinessProfile();
                      viewModel.enableEditing(false);
                    }
                  } else if (viewModel.selectedTab == 'Details') {
                    if (viewModel.formKey.currentState!.validate()) {
                      await viewModel.updateBusinessDescriptionApiCall();

                      viewModel.selectTab("Set Discount");
                      viewModel.enableEditing(false);
                    }
                  } else {
                    print(viewModel.formKey.currentState!.validate());
                    if (viewModel.setFirstTimeDiscountController!.text.isNotEmpty &&
                        viewModel.setRegularDiscountController!.text.isNotEmpty &&
                        (int.parse(viewModel.setFirstTimeDiscountController!.text) <
                            (int.parse(viewModel.setRegularDiscountController!.text)))) {
                      Utils.toastMessage("First Time Discount should be Greater than Regular Discount");
                      return;
                    } else if (viewModel.selectedExpiryDays == null || viewModel.selectedExpiryDays!.isEmpty) {
                      viewModel.setErrorText("Please select expiry days");
                      return;
                    }
                    if (viewModel.formKey.currentState!.validate()) {
                      await viewModel.updateBusinessDiscountApiCall();
                    }
                  }
                } else {
                  if (!viewModel.isEditing) {
                    viewModel.enableEditing(true);
                  }
                }
              },
              text: viewModel.isEditing ? "Save & Next" : "Edit",
            ),
          ),
        );
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildImageWidget() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: PageView(
              children: [
                if (viewModel.businessImage?.url != null)
                  AppImageWidget(imageUrl: viewModel.businessImage!.url!, fit: BoxFit.cover)
                else if (viewModel.businessImage?.file != null)
                  Image.file(viewModel.businessImage!.file!, fit: BoxFit.cover),
                if (viewModel.businessImage1?.url != null)
                  AppImageWidget(imageUrl: viewModel.businessImage1!.url!, fit: BoxFit.cover)
                else if (viewModel.businessImage1?.file != null)
                  Image.file(viewModel.businessImage1!.file!, fit: BoxFit.cover),
                if (viewModel.businessImage2?.url != null)
                  AppImageWidget(imageUrl: viewModel.businessImage2!.url!, fit: BoxFit.cover)
                else if (viewModel.businessImage2?.file != null)
                  Image.file(viewModel.businessImage2!.file!, fit: BoxFit.cover),
                if (viewModel.businessImage3?.url != null)
                  AppImageWidget(imageUrl: viewModel.businessImage3!.url!, fit: BoxFit.cover)
                else if (viewModel.businessImage3?.file != null)
                  Image.file(viewModel.businessImage3!.file!, fit: BoxFit.cover),
                if (viewModel.businessImage4?.url != null)
                  AppImageWidget(imageUrl: viewModel.businessImage4!.url!, fit: BoxFit.cover)
                else if (viewModel.businessImage4?.file != null)
                  Image.file(viewModel.businessImage4!.file!, fit: BoxFit.cover),
                if (viewModel.businessImage5?.url != null)
                  AppImageWidget(imageUrl: viewModel.businessImage5!.url!, fit: BoxFit.cover)
                else if (viewModel.businessImage5?.file != null)
                  Image.file(viewModel.businessImage5!.file!, fit: BoxFit.cover),
              ],
            ),
          ),
        ),

        //Edit Icon
        Positioned(
          bottom: 30,
          right: 23,
          child: Container(
            height: 40.h,
            width: 40.h,
            decoration: BoxDecoration(
              color: AppColor.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: InkWell(
                onTap: () {
                  if (viewModel.isEditing) {
                    _showBottomSheet(context, isMenuCard: false);
                    viewModel.notify();
                  } else {
                    Utils.snackBar("Click the 'Edit' button to make changes.");
                  }
                },
                child: SvgPicture.asset(
                  AppIcon.editOutlined,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context, {required bool isMenuCard}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return Consumer<EditBusinessProfileViewModel>(
          builder: (context, viewModel, _) {
            int maxImages = isMenuCard ? 5 : 6;
            int minImages = isMenuCard ? 0 : 4;

            Future<void> pickImage({required int index}) async {
              try {
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final file = File(pickedFile.path);

                  if (isMenuCard) {
                    switch (index) {
                      case 0:
                        viewModel.menuImage1 = BusinessImage(file: file);
                        break;
                      case 1:
                        viewModel.menuImage2 = BusinessImage(file: file);
                        break;
                      case 2:
                        viewModel.menuImage3 = BusinessImage(file: file);
                        break;
                      case 3:
                        viewModel.menuImage4 = BusinessImage(file: file);
                        break;
                      case 4:
                        viewModel.menuImage5 = BusinessImage(file: file);
                        break;
                    }
                  } else {
                    switch (index) {
                      case 0:
                        viewModel.businessImage = BusinessImage(file: file);
                        break;
                      case 1:
                        viewModel.businessImage1 = BusinessImage(file: file);
                        break;
                      case 2:
                        viewModel.businessImage2 = BusinessImage(file: file);
                        break;
                      case 3:
                        viewModel.businessImage3 = BusinessImage(file: file);
                        break;
                      case 4:
                        viewModel.businessImage4 = BusinessImage(file: file);
                        break;
                      case 5:
                        viewModel.businessImage5 = BusinessImage(file: file);
                        break;
                    }
                  }

                  viewModel.notify();
                }
              } catch (e) {
                Utils.snackBar("Failed to pick image: $e");
              }
            }

            Widget imageBox({required BusinessImage? image, required int index}) {
              return GestureDetector(
                onTap: () => pickImage(index: index),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.primary, width: 1.4),
                  ),
                  child: image != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: image.file != null
                                  ? Image.file(
                                      image.file!,
                                      height: double.maxFinite,
                                      width: double.maxFinite,
                                      fit: BoxFit.cover,
                                    )
                                  : AppImageWidget(
                                      imageUrl: image.url ?? '',
                                      height: double.maxFinite,
                                      width: double.maxFinite,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (isMenuCard) {
                                    switch (index) {
                                      case 0:
                                        viewModel.menuImage1 = null;
                                        break;
                                      case 1:
                                        viewModel.menuImage2 = null;
                                        break;
                                      case 2:
                                        viewModel.menuImage3 = null;
                                        break;
                                      case 3:
                                        viewModel.menuImage4 = null;
                                        break;
                                      case 4:
                                        viewModel.menuImage5 = null;
                                        break;
                                    }
                                  } else {
                                    switch (index) {
                                      case 0:
                                        viewModel.businessImage = null;
                                        break;
                                      case 1:
                                        viewModel.businessImage1 = null;
                                        break;
                                      case 2:
                                        viewModel.businessImage2 = null;
                                        break;
                                      case 3:
                                        viewModel.businessImage3 = null;
                                        break;
                                      case 4:
                                        viewModel.businessImage4 = null;
                                        break;
                                      case 5:
                                        viewModel.businessImage5 = null;
                                        break;
                                    }
                                  }

                                  viewModel.notify();
                                },
                                child: Icon(Icons.delete, color: Colors.red, size: 24.0),
                              ),
                            ),
                          ],
                        )
                      : Center(child: Icon(Icons.add, color: AppColor.primary)),
                ),
              );
            }

            return SafeArea(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppTextWidget(
                          text: isMenuCard ? "Upload Menu Card Images" : "Upload Business Images",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Image selection
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(maxImages, (index) {
                          BusinessImage? image;
                          if (isMenuCard) {
                            switch (index) {
                              case 0:
                                image = viewModel.menuImage1;
                                break;
                              case 1:
                                image = viewModel.menuImage2;
                                break;
                              case 2:
                                image = viewModel.menuImage3;
                                break;
                              case 3:
                                image = viewModel.menuImage4;
                                break;
                              case 4:
                                image = viewModel.menuImage5;
                                break;
                            }
                          } else {
                            switch (index) {
                              case 0:
                                image = viewModel.businessImage;
                                break;
                              case 1:
                                image = viewModel.businessImage1;
                                break;
                              case 2:
                                image = viewModel.businessImage2;
                                break;
                              case 3:
                                image = viewModel.businessImage3;
                                break;
                              case 4:
                                image = viewModel.businessImage4;
                                break;
                              case 5:
                                image = viewModel.businessImage5;
                                break;
                            }
                          }

                          return Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: imageBox(image: image, index: index),
                          );
                        }),
                      ),
                    ),

                    SizedBox(height: 15),

                    if (!isMenuCard && (viewModel.numberOfImages(isMenu: false) < 4))
                      Center(
                        child: AppTextWidget(
                          text: '* Minimum $minImages images required',
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),

                    SizedBox(height: 15),

                    AppButton(
                      text: "Upload",
                      onTap: () async {
                        if (!isMenuCard && (viewModel.numberOfImages(isMenu: false) < 4)) {
                          Utils.toastMessage("Please upload at least $minImages images.");
                          return;
                        }
                        // if (!isMenuCard && viewModel.numberOfImages(isMenu: false) == 0) {
                        //   Utils.toastMessage("Please upload at least 1 business image.");
                        //   return;
                        // }

                        Navigator.pop(context);
                        if (isMenuCard) {
                          viewModel.uploadMenuCardImages();
                        } else {
                          viewModel.uploadBusinessImages();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabContent({
    required String? selectedTabMain,
  }) {
    final selectedTab = selectedTabMain;
    switch (selectedTab) {
      case 'My Profile':
        return myProfileWidget(context);
      case 'Details':
        return businessDescriptionWidget(context, selectedImageNames, _showBottomSheet);
      case 'Set Discount':
        return setDiscountWidget(context);
      default:
        SizedBox();
    }
    return SizedBox();
  }
}
