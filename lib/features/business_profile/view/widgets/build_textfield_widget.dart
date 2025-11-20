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
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          AppTextWidget(
            text: title,
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
          ),
          SizedBox(height: 8.h),
        ],
        AppTextField(
          // onTap: readOnly
          //     ? () {
          //         if (hintText != null &&
          //             viewModel.isEditing &&
          //             (hintText.toLowerCase().contains("from") || hintText.toLowerCase().contains("to"))) {
          //           return Utils.snackBar("Mobile number is not editable.");
          //         } else if (title.toLowerCase().contains("mobile")) {
          //           if (onTap != null) {
          //             onTap();
          //           }
          //         } else {
          //           Utils.snackBar("Click the 'Edit' button to make changes.");
          //         }
          //       }
          //     : onTap,
          onTap: readOnly
              ? () {
                  if (!viewModel.isEditing) {
                    Utils.snackBar("Click the 'Edit' button to make changes.");
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
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        SizedBox(height: 10.h),
      ],
    ),
  );
}
