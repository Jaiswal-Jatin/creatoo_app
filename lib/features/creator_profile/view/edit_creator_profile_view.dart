import 'package:creatoo/core.dart';
import 'package:creatoo/features/creator_profile/view_model/edit_creator_profile_view_model.dart';

class EditCreatorProfileView extends StatefulWidget {
  const EditCreatorProfileView({super.key});

  @override
  State<EditCreatorProfileView> createState() => _EditCreatorProfileViewState();
}

class _EditCreatorProfileViewState extends State<EditCreatorProfileView> {
  late EditCreatorProfileViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<EditCreatorProfileViewModel>(context, listen: false);
    viewModel.init();
  }

  @override
  void dispose() {
    viewModel.isEditing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<EditCreatorProfileViewModel>(context);
    switch (viewModel.profileResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.profileResponse.message.toString());
      case Status.completed:
        var data = viewModel.profileResponse.data!.data!;
        return AppScaffold(
          appBar: AppBarWidget(
            title: "My Profile",
          ),
          body: SafeArea(
            child: Container(
              height: SizeConfig.screenHeight,
              width: SizeConfig.screenWidth,
              margin: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: InkWell(
                          onTap: () {
                            if (viewModel.isEditing) {
                              viewModel.getImageAttachment();
                            } else {
                              Utils.snackBar("Click the 'Edit' button to make changes.");
                            }
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60.h,
                                backgroundColor: AppColor.transparent,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: (viewModel.model.userImage == null || viewModel.model.userImage!.isEmpty)
                                      ? AppImageWidget(
                                          iconSize: 120.sp,
                                          isProfile: true,
                                          height: 120.h,
                                          width: 120.h,
                                          imageUrl: viewModel.profileResponse.data?.data?.userImage ?? '',
                                        )
                                      : Image.file(
                                          File(viewModel.model.userImage!),
                                          height: 120.h,
                                          width: 120.h,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 40.h,
                                  width: 40.h,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColor.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    AppIcon.editOutlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [],
                        ),
                      ),
                      buildTextField(
                        "Name",
                        viewModel.nameController,
                        readOnly: !viewModel.isEditing,
                      ),
                      buildTextField("City", viewModel.addressController, readOnly: !viewModel.isEditing, maxLines: 4),
                      buildTextField("Mobile No", viewModel.phoneController, readOnly: true),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.h),
            child: AppButton(
              isIconEnabled: false,
              onTap: () async {
                if (viewModel.isEditing) {
                  print(viewModel.formKey.currentState!.validate());
                  if (viewModel.formKey.currentState!.validate()) {
                    await viewModel.updateProfile();
                  }
                } else {
                  if (!viewModel.isEditing) {
                    viewModel.enableEditing(true);
                  }
                }
              },
              text: viewModel.isEditing ? "Update" : "Edit",
            ),
          ),
        );
      default:
        return const AppNoDataWidget();
    }
  }

  Container buildTextField(
    String title,
    controller, {
    int maxLines = 1,
    int minLines = 1,
    Function()? onTap,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool capitaliseText = false,
    int? maxLength,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.formHeaderStyle(),
          ),
          SizedBox(height: 8.h),
          AppTextField(
            onTap: readOnly
                ? () {
                    if (title.toLowerCase().contains("mobile")) {
                      return Utils.snackBar("Mobile number is not editable.");
                    }
                    Utils.snackBar("Click the 'Edit' button to make changes.");
                  }
                : onTap,
            readOnly: readOnly,
            textInputType: keyboardType,
            controller: controller,
            validator: (value) => Validator.validate(value!, title),
            disableBorder: false,
            minLines: minLines,
            maxLines: maxLines,
            suffixIcon: suffixIcon,
            maxLength: maxLength,
            // capitaliseText: capitaliseText,
            hintText: title.toLowerCase().contains("expiry") ? "DD/MM/YYYY" : "Enter ${title.toLowerCase()}",
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
