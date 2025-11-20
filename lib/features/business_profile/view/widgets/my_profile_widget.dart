import '../../../../core.dart';
import '../../view_model/edit_business_profile_view_model.dart';
import 'build_textfield_widget.dart';

Widget myProfileWidget(BuildContext context) {
  EditBusinessProfileViewModel viewModel = Provider.of<EditBusinessProfileViewModel>(context);
  return Column(
    children: [
      buildTextField(
        context,
        "Business Name",
        viewModel.businessNameController,
        readOnly: !viewModel.isEditing,
      ),
      buildTextField(
        context,
        "Business Area",
        viewModel.businessAreaController,
        readOnly: !viewModel.isEditing,
        maxLines: 2,
      ),
      buildTextField(
        context,
        "Business Complete Address",
        viewModel.businessCompleteAddressController,
        readOnly: !viewModel.isEditing,
        maxLines: 4,
      ),
      buildTextField(
        isRequired: false,
        context,
        "Business Website",
        viewModel.businessWebsiteController,
        readOnly: !viewModel.isEditing,
      ),
      buildTextField(context, "Full Name", viewModel.businessFullNameController,
          readOnly: !viewModel.isEditing, capitaliseText: TextCapitalization.words),
      buildTextField(
        context,
        "Designation",
        viewModel.businessDesignationController,
        readOnly: !viewModel.isEditing,
      ),
      buildTextField(
        context,
        "Mobile Number",
        viewModel.businessMobileController,
        readOnly: !viewModel.isEditing,
      ),
      buildTextField(
        context,
        "Email",
        viewModel.businessEmailController,
        readOnly: !viewModel.isEditing,
      ),
      buildTextField(
        context,
        "GSTIN NO",
        viewModel.businessGstNoController,
        readOnly: !viewModel.isEditing,
        capitaliseText: TextCapitalization.characters,
        maxLength: 15,
      ),
    ],
  );
}
