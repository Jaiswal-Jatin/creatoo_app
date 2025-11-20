import 'package:creatoo/widgets/app_text_widget.dart';

import '../../../../core.dart';
import '../../../../widgets/app_dottedContainer_widget.dart';
import '../../view_model/edit_business_profile_view_model.dart';
import 'build_textfield_widget.dart';

Widget businessDescriptionWidget(
    BuildContext context, List<String> selectedImageNames, void Function(BuildContext, {required bool isMenuCard}) showBottomSheet) {
  EditBusinessProfileViewModel viewModel = Provider.of<EditBusinessProfileViewModel>(context);
  String _formatTime(TimeOfDay time) {
    int hour = time.hourOfPeriod; // Get the hour in 12-hour format
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  return Column(
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
                  Utils.snackBar("Click the 'Edit' button to make changes.");
                  return;
                }

                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light(),
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
                color: AppColor.primary,
              ),
            ),
          ),
          SizedBox(width: 10.h),
          Expanded(
            child: buildTextField(
              isRequired: true,
              context,
              "Closing Time",
              viewModel.toTimeController,
              readOnly: !viewModel.isEditing, // Matches "Pricing Range" behavior
              onTap: () async {
                if (!viewModel.isEditing) {
                  Utils.snackBar("Click the 'Edit' button to make changes.");
                  return;
                }

                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light(),
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
                color: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
      //Todo: Remove this section if not required

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
          SizedBox(width: 10.h),
          Expanded(
            child: buildTextField(
              isRequired: true,
              context,
              "No. of People",
              viewModel.noOfPeopleController,
              keyboardType: TextInputType.number,
              readOnly: !viewModel.isEditing,
              hintText: "Enter No. of people",
              maxLines: 1,
            ),
          ),
        ],
      ),
      // buildTextField(
      //   isRequired: true,
      //   context,
      //   "Pricing Range",
      //   viewModel.priceRangeController,
      //   readOnly: !viewModel.isEditing,
      //   maxLines: 4,
      // ),
      Align(
        alignment: Alignment.topLeft,
        child: AppTextWidget(
          text: 'Menu Card Upload',
          fontSize: 14.sp,
        ),
      ),
      SizedBox(
        height: 10.h,
      ),
      AppDottedContainer(
        width: double.infinity,
        borderColor: AppColor.moreLighterDd,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 20,
                width: 20,
                child: Image(
                  image: AssetImage(
                    "assets/images/cloud.png",
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Choose a file',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      if (!viewModel.isEditing) {
                        Utils.snackBar("Click the 'Edit' button to make changes.");
                      } else {
                        showBottomSheet(context, isMenuCard: true);
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColor.white,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: AppColor.moreLighterDd, width: 0.5),
                      ),
                    ),
                    child: Text(
                      'Browse File',
                      style: TextStyle(color: AppColor.black),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Display the list of selected file names
                  if (selectedImageNames.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: selectedImageNames
                          .map((name) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(name, style: TextStyle(color: AppColor.kPrimary, fontSize: 14)),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
