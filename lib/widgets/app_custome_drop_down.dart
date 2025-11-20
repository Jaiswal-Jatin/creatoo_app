import '../core.dart';
import '../features/business_profile/view_model/edit_business_profile_view_model.dart';
import 'app_text_widget.dart';

class AppCustomDropdown extends StatelessWidget {
  final TextEditingController textController;
  final List<String> items;
  final String label;
  final String hintText;
  final String? selectedItem;
  final String dropdownHint;
  final Function(String?) onChanged;
  final bool readOnly;
  final bool disableBorder;
  final double borderRadius;
  final double height;
  final double dropdownMaxHeight;
  final double fontSize;
  final Color selectedTextColor;
  final String? Function(String?)? validator;

  const AppCustomDropdown({
    Key? key,
    required this.textController,
    required this.items,
    required this.onChanged,
    this.selectedItem,
    this.label = "Select Option",
    this.hintText = "Enter complete expiry (in days)",
    this.dropdownHint = "Select an option",
    this.readOnly = false,
    this.disableBorder = false,
    this.borderRadius = 30,
    this.height = 60,
    this.dropdownMaxHeight = 150,
    this.fontSize = 15,
    this.selectedTextColor = AppColor.black,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditBusinessProfileViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          AppTextWidget(
            text: label,
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTap: () {
            if (!viewModel.isEditing) {
              Utils.snackBar("Click the 'Edit' button to make changes.");
            } else {
              viewModel.toggleDropdown(); // Open/Close dropdown
            }
          },
          behavior: HitTestBehavior.opaque,
          child: AbsorbPointer(
            absorbing: !viewModel.isEditing,
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(borderRadius),
                border: disableBorder ? null : Border.all(color: viewModel.errorText != null ? AppColor.darkRed : const Color(0xFFDADADA)),
              ),
              alignment: Alignment.centerLeft,
              child: AppTextWidget(
                text: selectedItem?.isNotEmpty == true ? selectedItem! : dropdownHint,
                fontSize: fontSize,
                color: selectedItem?.isNotEmpty == true ? selectedTextColor : Colors.grey,
              ),
            ),
          ),
        ),
        Consumer<EditBusinessProfileViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                viewModel.isDropdownOpen
                    ? Container(
                        constraints: BoxConstraints(
                          maxHeight: dropdownMaxHeight,
                        ),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return InkWell(
                              onTap: () {
                                textController.text = item;
                                onChanged(item);

                                // Perform validation
                                String? validationMessage = validator?.call(item);
                                viewModel.setErrorText(validationMessage);

                                viewModel.toggleDropdown();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w400,
                                    color: item == selectedItem ? AppColor.primary : AppColor.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox.shrink(),

                // Validation error message
                if (viewModel.errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      viewModel.errorText!,
                      style: TextStyle(
                        fontSize: fontSize - 2,
                        color: AppColor.darkRed,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
