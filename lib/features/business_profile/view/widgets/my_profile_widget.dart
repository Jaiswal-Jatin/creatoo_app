import 'dart:ui';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../core.dart';
import '../../view_model/edit_business_profile_view_model.dart';
import 'build_textfield_widget.dart';

Widget myProfileWidget(BuildContext context) {
  EditBusinessProfileViewModel viewModel = Provider.of<EditBusinessProfileViewModel>(context);
  return ListView(
    physics: const BouncingScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    children: [
      _buildSection(
        title: "Business Information",
        icon: Icons.business_center_rounded,
        children: [
          buildTextField(context, "Business Name", viewModel.businessNameController, readOnly: !viewModel.isEditing),
          buildTextField(context, "Business Area", viewModel.businessAreaController, readOnly: !viewModel.isEditing, maxLines: 2),
          buildTextField(context, "Business Complete Address", viewModel.businessCompleteAddressController, readOnly: !viewModel.isEditing, maxLines: 4),
          buildTextField(isRequired: false, context, "Business Website", viewModel.businessWebsiteController, readOnly: !viewModel.isEditing),
        ],
      ),
      SizedBox(height: 16.h),
      _buildSection(
        title: "Contact Person",
        icon: Icons.person_rounded,
        children: [
          buildTextField(context, "Full Name", viewModel.businessFullNameController, readOnly: !viewModel.isEditing, capitaliseText: TextCapitalization.words),
          buildTextField(context, "Designation", viewModel.businessDesignationController, readOnly: !viewModel.isEditing),
          buildTextField(context, "Mobile Number", viewModel.businessMobileController, readOnly: !viewModel.isEditing),
          buildTextField(context, "Email", viewModel.businessEmailController, readOnly: !viewModel.isEditing),
        ],
      ),
      SizedBox(height: 16.h),
      _buildSection(
        title: "Business Identity",
        icon: Icons.badge_rounded,
        children: [
          buildTextField(context, "GSTIN NO", viewModel.businessGstNoController, readOnly: !viewModel.isEditing, capitaliseText: TextCapitalization.characters, maxLength: 15),
          buildTextField(isRequired: false, context, "UPI ID", viewModel.upiIdController, readOnly: !viewModel.isEditing),
          SizedBox(height: 8.h),
          _buildCategoryDropdown(context, viewModel),
        ],
      ),
      SizedBox(height: 16.h),
      _buildCategorySpecificSection(context, viewModel),
      SizedBox(height: 24.h),
    ],
  );
}

Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.premiumAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColor.premiumAccent, size: 16.sp),
                ),
                SizedBox(width: 10.w),
                Text(title, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ],
            ),
            SizedBox(height: 14.h),
            Divider(color: Colors.white.withValues(alpha: 0.06)),
            SizedBox(height: 6.h),
            ...children,
          ],
        ),
      ),
    ),
  );
}

Widget _buildCategoryDropdown(BuildContext context, EditBusinessProfileViewModel viewModel) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
        child: Text('Business Category', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
      ),
      DropdownSearch<String>(
        popupProps: PopupProps.menu(
          constraints: BoxConstraints(),
          menuProps: MenuProps(
            backgroundColor: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
          ),
          itemBuilder: (context, item, isSelected) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.premiumAccent.withValues(alpha: 0.15) : null,
              ),
              child: Text(item, style: GoogleFonts.montserrat(
                color: isSelected ? AppColor.premiumAccent : Colors.white70,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.sp,
              )),
            );
          },
        ),
        items: viewModel.businessCategories,
        selectedItem: viewModel.selectedBusinessCategory,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: "Select Business Category",
            fillColor: Colors.white.withValues(alpha: 0.03),
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColor.premiumAccent, width: 1)),
            hintStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.25)),
          ),
          baseStyle: GoogleFonts.montserrat(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
        ),
        onChanged: viewModel.isEditing
            ? (String? data) {
                if (data != null && data != viewModel.profileResponse.data?.data?.businessCategory) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF2A2A2A),
                      title: Text("Change Category?", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                      content: Text("Changing category will reset your custom profile details once saved. Do you want to proceed?",
                          style: GoogleFonts.montserrat(color: Colors.white70)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: GoogleFonts.montserrat(color: Colors.white54))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColor.premiumAccent),
                          onPressed: () { Navigator.pop(ctx); viewModel.updateBusinessCategory(data); },
                          child: Text("Proceed", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                } else if (data != null) {
                  viewModel.updateBusinessCategory(data);
                }
              }
            : null,
      ),
    ],
  );
}

Widget _buildCategorySpecificSection(BuildContext context, EditBusinessProfileViewModel viewModel) {
  if (viewModel.selectedBusinessCategory == null) return const SizedBox.shrink();

  switch (viewModel.selectedBusinessCategory) {
    case 'restaurant':
      return _buildRestaurantSection(context, viewModel);
    case 'salon':
      return _buildSalonSection(context, viewModel);
    case 'turf':
      return _buildTurfSection(context, viewModel);
    default:
      return const SizedBox.shrink();
  }
}

Widget _buildRestaurantSection(BuildContext context, EditBusinessProfileViewModel viewModel) {
  final cuisines = ["Indian", "Chinese", "Italian", "Continental", "Mexican", "Fast Food", "Thai", "Japanese"];
  return _buildSection(
    title: "Restaurant Specifications",
    icon: Icons.restaurant_rounded,
    children: [
      buildTextField(isRequired: false, context, "Seating Capacity", viewModel.seatingCapacityController, readOnly: !viewModel.isEditing, keyboardType: TextInputType.number),
      SizedBox(height: 4.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Pure Vegetarian?", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white70)),
          Switch(
            value: viewModel.isVegOnly,
            activeTrackColor: AppColor.premiumAccent.withValues(alpha: 0.3),
            activeThumbColor: AppColor.premiumAccent,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
            onChanged: viewModel.isEditing ? (val) { viewModel.isVegOnly = val; viewModel.notify(); } : null,
          ),
        ],
      ),
      SizedBox(height: 12.h),
      Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text('Cuisines Offered', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
      ),
      Wrap(
        spacing: 8.w, runSpacing: 8.h,
        children: cuisines.map((cuisine) {
          final isSelected = viewModel.selectedCuisines.contains(cuisine);
          return FilterChip(
            label: Text(cuisine, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : Colors.white70)),
            selected: isSelected,
            selectedColor: AppColor.premiumAccent,
            checkmarkColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.03),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? AppColor.premiumAccent : Colors.white.withValues(alpha: 0.1))),
            onSelected: viewModel.isEditing ? (selected) {
              if (selected) { viewModel.selectedCuisines.add(cuisine); } else { viewModel.selectedCuisines.remove(cuisine); }
              viewModel.notify();
            } : null,
          );
        }).toList(),
      ),
    ],
  );
}

Widget _buildSalonSection(BuildContext context, EditBusinessProfileViewModel viewModel) {
  return _buildSection(
    title: "Salon Specifications",
    icon: Icons.content_cut_rounded,
    children: [
      buildTextField(isRequired: false, context, "Number of Stylists / Chairs", viewModel.stylistsCountController, readOnly: !viewModel.isEditing, keyboardType: TextInputType.number),
      SizedBox(height: 8.h),
      Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text('Gender Specialty', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
      ),
      Row(
        children: ['men', 'women', 'unisex'].map((gender) {
          final isSelected = viewModel.selectedGenderSupport == gender;
          final label = gender == 'men' ? 'Men Only' : (gender == 'women' ? 'Women Only' : 'Unisex');
          return Expanded(
            child: GestureDetector(
              onTap: viewModel.isEditing ? () { viewModel.selectedGenderSupport = gender; viewModel.notify(); } : null,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.premiumAccent : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppColor.premiumAccent : Colors.white.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: Text(label, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : Colors.white70)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

Widget _buildTurfSection(BuildContext context, EditBusinessProfileViewModel viewModel) {
  final sports = viewModel.turfSportOptions.isNotEmpty
      ? viewModel.turfSportOptions
      : ["Football", "Cricket", "Badminton", "Tennis", "Basketball", "Volleyball"];
  final turfSizes = viewModel.turfCourtSizes.isNotEmpty
      ? viewModel.turfCourtSizes
      : ["5v5", "7v7", "9v9", "11v11"];
  final groundTypes = viewModel.turfGroundTypes.isNotEmpty
      ? viewModel.turfGroundTypes
      : ["Artificial Grass", "Natural Grass", "Clay Court", "Wooden Floor"];
  final amenityList = viewModel.turfAmenityOptions.isNotEmpty
      ? viewModel.turfAmenityOptions
      : ["Parking", "Changing Rooms", "Floodlights", "Water", "Cafeteria", "Equipment Rental"];

  return _buildSection(
    title: "Turf Specifications",
    icon: Icons.sports_soccer_rounded,
    children: [
      Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text('Primary Court Size', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
      ),
      DropdownSearch<String>(
        popupProps: PopupProps.menu(
          constraints: BoxConstraints(),
          menuProps: MenuProps(
            backgroundColor: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
          ),
          itemBuilder: (context, item, isSelected) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.premiumAccent.withValues(alpha: 0.15) : null,
              ),
              child: Text(item, style: GoogleFonts.montserrat(
                color: isSelected ? AppColor.premiumAccent : Colors.white70,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13.sp,
              )),
            );
          },
        ),
        items: turfSizes,
        selectedItem: viewModel.selectedTurfSize,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            fillColor: Colors.white.withValues(alpha: 0.03), filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColor.premiumAccent, width: 1.2)),
          ),
          baseStyle: GoogleFonts.montserrat(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        onChanged: viewModel.isEditing ? (val) { viewModel.selectedTurfSize = val!; viewModel.notify(); } : null,
      ),
      SizedBox(height: 14.h),
      Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text('Ground Type', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
      ),
      DropdownSearch<String>(
        popupProps: PopupProps.menu(
          constraints: BoxConstraints(),
          menuProps: MenuProps(
            backgroundColor: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
          ),
          itemBuilder: (context, item, isSelected) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.premiumAccent.withValues(alpha: 0.15) : null,
              ),
              child: Text(item, style: GoogleFonts.montserrat(
                color: isSelected ? AppColor.premiumAccent : Colors.white70,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13.sp,
              )),
            );
          },
        ),
        items: groundTypes,
        selectedItem: viewModel.selectedGroundType,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            fillColor: Colors.white.withValues(alpha: 0.03), filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColor.premiumAccent, width: 1.2)),
          ),
          baseStyle: GoogleFonts.montserrat(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        onChanged: viewModel.isEditing ? (val) { viewModel.selectedGroundType = val!; viewModel.notify(); } : null,
      ),
      SizedBox(height: 16.h),
      Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text('Supported Sports', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
      ),
      Wrap(
        spacing: 8.w, runSpacing: 8.h,
        children: sports.map((sport) {
          final isSelected = viewModel.selectedSports.contains(sport);
          return FilterChip(
            label: Text(sport, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : Colors.white70)),
            selected: isSelected, selectedColor: AppColor.premiumAccent, checkmarkColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.03),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? AppColor.premiumAccent : Colors.white.withValues(alpha: 0.1))),
            onSelected: viewModel.isEditing ? (selected) {
              if (selected) {
                viewModel.selectedSports.add(sport);
                if (!viewModel.services.any((svc) => svc['name'] == sport)) {
                  viewModel.services.add({'name': sport, 'price': 0, 'duration_minutes': 60});
                }
              } else {
                viewModel.selectedSports.remove(sport);
                viewModel.services.removeWhere((svc) => svc['name'] == sport);
              }
              viewModel.notify();
            } : null,
          );
        }).toList(),
      ),
      SizedBox(height: 16.h),
      Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text('Amenities', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
      ),
      Wrap(
        spacing: 8.w, runSpacing: 8.h,
        children: amenityList.map((amenity) {
          final isSelected = viewModel.selectedAmenities.contains(amenity);
          return FilterChip(
            label: Text(amenity, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : Colors.white70)),
            selected: isSelected, selectedColor: AppColor.premiumAccent, checkmarkColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.03),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? AppColor.premiumAccent : Colors.white.withValues(alpha: 0.1))),
            onSelected: viewModel.isEditing ? (selected) {
              if (selected) {
                viewModel.selectedAmenities.add(amenity);
                if (!viewModel.services.any((svc) => svc['name'] == amenity)) {
                  viewModel.services.add({'name': amenity, 'price': 0, 'duration_minutes': 0});
                }
              } else {
                viewModel.selectedAmenities.remove(amenity);
                viewModel.services.removeWhere((svc) => svc['name'] == amenity);
              }
              viewModel.notify();
            } : null,
          );
        }).toList(),
      ),
    ],
  );
}
