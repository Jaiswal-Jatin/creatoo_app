import '../../../../core.dart';
import '../../../../widgets/app_custome_drop_down.dart';
import '../../view_model/edit_business_profile_view_model.dart';
import 'build_textfield_widget.dart';

Widget setDiscountWidget(BuildContext context) {
  EditBusinessProfileViewModel viewModel = Provider.of<EditBusinessProfileViewModel>(context);
  return Column(
    children: [
      //TODO: Add validataion first time discount should be greater than regular
      buildTextField(
        context,
        "Set First Time Discount %",
        viewModel.setFirstTimeDiscountController,
        readOnly: !viewModel.isEditing,
        keyboardType: TextInputType.number,
        maxLines: 1,
      ),
      buildTextField(
        context,
        "Set Regular Discount %",
        viewModel.setRegularDiscountController,
        readOnly: !viewModel.isEditing,
        keyboardType: TextInputType.number,
        maxLines: 1,
      ),
      buildTextField(
        context,
        "Min Order Value",
        viewModel.minOrderValueController,
        readOnly: !viewModel.isEditing,
        keyboardType: TextInputType.number,
        maxLines: 1,
      ),
      AppCustomDropdown(
        textController: TextEditingController(),
        items: ["15", "30", "365", "Other"],
        readOnly: !viewModel.isEditing,
        label: "Complete Expiry (in Days)",
        selectedItem: (viewModel.selectedExpiryDays != null && ["15", "30", "365", "Other"].contains(viewModel.selectedExpiryDays))
            ? viewModel.selectedExpiryDays
            : null,
        dropdownHint: "Select complete expiry days",
        hintText: "Select complete expiry days",
        // validator: (value) {
        //   if (viewModel.isEditing) {
        //     if (value == null || value.isEmpty) return Validator.validate("", "expiry");
        //   }
        //   return null;
        // },
        validator: (value) {
          if (viewModel.isEditing && !viewModel.showOtherField) {
            if (value == null || value.isEmpty) {
              return "Please select expiry days";
            }
          }
          return null;
        },
        onChanged: (value) {
          if (value == 'Other') {
            if (!viewModel.showOtherField) {
              viewModel.selectedExpiryDays = "Other";
              viewModel.showOtherField = true;
              viewModel.expiryInDaysController?.clear();
            }
          } else {
            viewModel.selectedExpiryDays = value;
            viewModel.showOtherField = false;
          }
          viewModel.notify();
          print("Selected: $value");
        },
      ),

      if (viewModel.showOtherField)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: buildTextField(
            context,
            "Enter Expiry in Days",
            viewModel.expiryInDaysController,
            readOnly: !viewModel.isEditing,
            keyboardType: TextInputType.number,
            isRequired: viewModel.showOtherField,
            maxLines: 1,
            hintText: "Enter expiry in days",
          ),
        ),
    ],
  );
}
