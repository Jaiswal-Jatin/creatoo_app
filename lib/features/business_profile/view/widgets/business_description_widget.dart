import 'package:creatoo/widgets/app_text_widget.dart';
import 'dart:ui';
import '../../../../core.dart';
import '../../../../widgets/app_dottedContainer_widget.dart';
import '../../view_model/edit_business_profile_view_model.dart';
import 'build_textfield_widget.dart';

Widget businessDescriptionWidget(
    BuildContext context, List<String> selectedImageNames, void Function(BuildContext, {required bool isMenuCard}) showBottomSheet) {
  EditBusinessProfileViewModel viewModel = Provider.of<EditBusinessProfileViewModel>(context);
  String _formatTime(TimeOfDay time) {
    int hour = time.hourOfPeriod; 
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: buildTextField(
              isRequired: true,
              context,
              "Opening Time",
              viewModel.fromTimeController,
              readOnly: !viewModel.isEditing,
              onTap: () async {
                if (!viewModel.isEditing) {
                  Utils.toastMessage("Click 'Edit Details' first");
                  return;
                }

                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppColor.premiumAccent,
                          onPrimary: Colors.white,
                          surface: const Color(0xFF1A1A1A),
                          onSurface: Colors.white,
                        ),
                        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1A1A1A)),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedTime != null) {
                  viewModel.fromTimeController?.text = _formatTime(pickedTime);
                  viewModel.notify();
                }
              },
              hintText: "From",
              maxLines: 1,
              suffixIcon: Icon(
                Icons.access_time_rounded,
                color: AppColor.premiumAccent,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: buildTextField(
              isRequired: true,
              context,
              "Closing Time",
              viewModel.toTimeController,
              readOnly: !viewModel.isEditing,
              onTap: () async {
                if (!viewModel.isEditing) {
                  Utils.toastMessage("Click 'Edit Details' first");
                  return;
                }

                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppColor.premiumAccent,
                          onPrimary: Colors.white,
                          surface: const Color(0xFF1A1A1A),
                          onSurface: Colors.white,
                        ),
                        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1A1A1A)),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedTime != null) {
                  viewModel.toTimeController?.text = _formatTime(pickedTime);
                  viewModel.notify();
                }
              },
              hintText: "To",
              maxLines: 1,
              suffixIcon: Icon(
                Icons.access_time_rounded,
                color: AppColor.premiumAccent,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: buildTextField(
              isRequired: true,
              context,
              "Amount",
              viewModel.amountController,
              readOnly: !viewModel.isEditing,
              keyboardType: TextInputType.number,
              hintText: "Enter Amount",
              maxLines: 1,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: buildTextField(
              isRequired: true,
              context,
              "No. of People",
              viewModel.noOfPeopleController,
              keyboardType: TextInputType.number,
              readOnly: !viewModel.isEditing,
              hintText: "No. of people",
              maxLines: 1,
            ),
          ),
        ],
      ),

      Padding(
        padding: EdgeInsets.only(left: 4.w, top: 8.h),
        child: Text(
          'Menu Card Upload',
          style: GoogleFonts.montserrat(
            color: AppColor.premiumTextSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      SizedBox(height: 12.h),
      
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AppDottedContainer(
            width: double.infinity,
            borderColor: Colors.white.withValues(alpha: 0.1),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.premiumAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColor.premiumAccent,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Upload Menu Cards',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'PDF, PNG, JPG (Max 5 images)',
                    style: GoogleFonts.montserrat(
                      color: Colors.white38,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  AppButton(
                    onTap: () {
                      if (!viewModel.isEditing) {
                        Utils.toastMessage("Click 'Edit Details' first");
                      } else {
                        showBottomSheet(context, isMenuCard: true);
                      }
                    },
                    text: 'Browse Files',
                    isIconEnabled: true,
                    icon: Icons.folder_open_rounded,
                  ),
                  
                  if (selectedImageNames.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    const Divider(color: Colors.white10),
                    SizedBox(height: 8.h),
                    ...selectedImageNames.map((name) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Icon(Icons.image_outlined, color: AppColor.premiumAccent, size: 14.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.montserrat(
                                color: Colors.white70,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 40.h),
    ],
  );
}
