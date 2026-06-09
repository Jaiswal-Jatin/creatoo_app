import 'package:creatoo/widgets/app_text_widget.dart';
import '../../../../core.dart';
import '../../view_model/edit_business_profile_view_model.dart';

Widget buildTextField(
  BuildContext context,
  String title,
  controller, {
  int minLines = 1,
  int maxLines = 1,
  Function()? onTap,
  bool readOnly = false,
  TextInputType keyboardType = TextInputType.text,
  Widget? suffixIcon,
  TextCapitalization capitaliseText = TextCapitalization.sentences,
  int? maxLength,
  String? hintText,
  bool? isTime,
  bool? isRequired = true,
}) {
  EditBusinessProfileViewModel viewModel = Provider.of<EditBusinessProfileViewModel>(context);
  return Padding(
    padding: EdgeInsets.only(bottom: 20.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                color: AppColor.premiumTextSecondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        AppTextField(
          onTap: readOnly
              ? () {
                  if (!viewModel.isEditing) {
                    Utils.toastMessage("Click 'Edit Details' to make changes");
                  }
                }
              : onTap,
          readOnly: readOnly || (title == "Opening Time" || title == "Closing Time"),
          textInputType: keyboardType,
          controller: controller,
          validator: (value) {
            if (isRequired != null && isRequired) return Validator.validate(value!, title);
            return null;
          },
          disableBorder: false,
          minLines: minLines,
          maxLines: maxLines,
          suffixIcon: suffixIcon,
          maxLength: maxLength,
          capitaliseText: capitaliseText,
          hintText: hintText ?? (title.isNotEmpty ? "Enter ${title.toLowerCase()}" : ""),
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          textColor: Colors.white,
          cursorColor: AppColor.premiumAccent,
          borderColor: Colors.white.withValues(alpha: 0.1),
          focusedBorderColor: AppColor.premiumAccent,
          borderRadius: 16,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          textStyle: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: GoogleFonts.montserrat(
            color: Colors.white24,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
