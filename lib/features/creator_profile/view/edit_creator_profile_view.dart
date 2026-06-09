import 'package:creatoo/core.dart';
import 'package:creatoo/features/creator_profile/view_model/edit_creator_profile_view_model.dart';
import 'package:creatoo/widgets/custom_back_button.dart';

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
    viewModel =
        Provider.of<EditCreatorProfileViewModel>(context, listen: false);
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
        return AppErrorWidget(
            message: viewModel.profileResponse.message.toString());
      case Status.completed:
        return AppScaffold(
          isSafe: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "My Profile",
              style: GoogleFonts.montserrat(
                color: AppColor.premiumTextPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Center(
                child: CustomBackButton(),
              ),
            ),
          ),
          body: Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    _buildProfilePicture(),
                    SizedBox(height: 30.h),
                    _buildFormCard(),
                    SizedBox(height: 100.h), // padding for floating button
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.h),
            width: double.infinity,
            height: 55.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: viewModel.isEditing
                  ? const LinearGradient(
                      colors: [Color(0xFF9759C4), Color(0xFF6A2D9A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: viewModel.isEditing ? null : AppColor.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () async {
                  if (viewModel.isEditing) {
                    if (viewModel.formKey.currentState!.validate()) {
                      await viewModel.updateProfile();
                    }
                  } else {
                    viewModel.enableEditing(true);
                  }
                },
                child: Center(
                  child: Text(
                    viewModel.isEditing ? "Save Changes" : "Edit Profile",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildProfilePicture() {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          if (viewModel.isEditing) {
            viewModel.getImageAttachment();
          } else {
            Utils.snackBar("Click the 'Edit Profile' button to make changes.");
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // boxShadow: [
                //   // BoxShadow(
                //   //   color: Colors.black.withOpacity(0.5),
                //   //   blurRadius: 25,
                //   //   spreadRadius: 2,
                //   //   offset: const Offset(0, 12),
                //   // ),
                //   BoxShadow(
                //     color: AppColor.premiumAccent.withOpacity(0.2),
                //     blurRadius: 15,
                //     spreadRadius: 0,
                //     offset: const Offset(0, 0),
                //   ),
                // ],
                border: Border.all(color: AppColor.premiumCardBg, width: 4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: (viewModel.model.userImage == null ||
                        viewModel.model.userImage!.isEmpty)
                    ? AppImageWidget(
                        iconSize: 120.sp,
                        isProfile: true,
                        height: 120.h,
                        width: 120.h,
                        imageUrl: viewModel.profileResponse.data?.data?.userImage ?? '',
                        fit: BoxFit.cover,
                        hasBorder: false,
                        borderRadius: 100,
                      )
                    : Image.file(
                        File(viewModel.model.userImage!),
                        height: 120.h,
                        width: 120.h,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            if (viewModel.isEditing)
              Container(
                height: 120.h,
                width: 120.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            if (!viewModel.isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 36.h,
                  width: 36.h,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.premiumCardBg, width: 3),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColor.premiumBorder),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Information",
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.premiumTextPrimary,
            ),
          ),
          const SizedBox(height: 20),
          buildTextField(
            "Name",
            viewModel.nameController,
            readOnly: !viewModel.isEditing,
            icon: Icons.person_outline,
          ),
          buildTextField(
            "City",
            viewModel.addressController,
            readOnly: !viewModel.isEditing,
            maxLines: 3,
            icon: Icons.location_city_outlined,
          ),
          buildTextField(
            "Mobile No",
            viewModel.phoneController,
            readOnly: true,
            icon: Icons.phone_outlined,
            isMobile: true,
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    String title,
    dynamic controller, {
    int maxLines = 1,
    int minLines = 1,
    Function()? onTap,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    int? maxLength,
    IconData? icon,
    bool isMobile = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.premiumTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: readOnly ? AppColor.premiumBg : AppColor.premiumLightCardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: readOnly ? Colors.transparent : AppColor.premiumBorder,
              ),
            ),
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              maxLines: maxLines,
              minLines: minLines,
              maxLength: maxLength,
              keyboardType: keyboardType,
              style: AppTextStyles.body(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: readOnly ? AppColor.premiumTextSecondary : AppColor.premiumTextPrimary,
              ),
              validator: (value) => Validator.validate(value!, title),
              onTap: readOnly
                  ? () {
                      if (isMobile) {
                        Utils.snackBar("Mobile number is not editable.");
                      } else {
                        Utils.snackBar("Click the 'Edit Profile' button to make changes.");
                      }
                    }
                  : onTap,
              decoration: InputDecoration(
                counterText: "",
                prefixIcon: icon != null
                    ? Icon(
                        icon,
                        color: readOnly ? AppColor.premiumTextSecondary : AppColor.primary,
                        size: 20,
                      )
                    : null,
                suffixIcon: suffixIcon,
                hintText: "Enter ${title.toLowerCase()}",
                hintStyle: AppTextStyles.body(
                  fontSize: 14.sp,
                  color: AppColor.premiumTextSecondary,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
