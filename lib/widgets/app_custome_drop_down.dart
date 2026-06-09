import 'dart:ui';
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
    this.hintText = "Select an option",
    this.dropdownHint = "Select an option",
    this.readOnly = false,
    this.disableBorder = false,
    this.borderRadius = 16,
    this.height = 56,
    this.dropdownMaxHeight = 200,
    this.fontSize = 14,
    this.selectedTextColor = Colors.white,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditBusinessProfileViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                color: AppColor.premiumTextSecondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: () {
            if (!viewModel.isEditing) {
              Utils.toastMessage("Click 'Edit Details' to make changes");
            } else {
              viewModel.toggleDropdown();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: AbsorbPointer(
            absorbing: true,
            child: Container(
              height: height.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: viewModel.errorText != null 
                    ? Colors.redAccent.withOpacity(0.5) 
                    : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedItem?.isNotEmpty == true ? selectedItem! : dropdownHint,
                    style: GoogleFonts.montserrat(
                      fontSize: fontSize.sp,
                      fontWeight: selectedItem?.isNotEmpty == true ? FontWeight.w600 : FontWeight.w500,
                      color: selectedItem?.isNotEmpty == true ? Colors.white : Colors.white24,
                    ),
                  ),
                  Icon(
                    viewModel.isDropdownOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white54,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        if (viewModel.isDropdownOpen)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  constraints: BoxConstraints(maxHeight: dropdownMaxHeight.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == selectedItem;
                      return InkWell(
                        onTap: () {
                          textController.text = item;
                          onChanged(item);
                          String? validationMessage = validator?.call(item);
                          viewModel.setErrorText(validationMessage);
                          viewModel.toggleDropdown();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
                          child: Text(
                            item,
                            style: GoogleFonts.montserrat(
                              fontSize: fontSize.sp,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColor.premiumAccent : Colors.white70,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

        if (viewModel.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 4.w),
            child: Text(
              viewModel.errorText!,
              style: GoogleFonts.montserrat(
                fontSize: 11.sp,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
