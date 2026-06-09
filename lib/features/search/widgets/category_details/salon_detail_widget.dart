import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:creatoo/core.dart';

import '../../../../resources/color.dart';
import '../../../../widgets/app_text_widget.dart';
import '../../model/business_details_response_model.dart';

/// Salon-specific detail widget showing services list with select/deselect
class SalonDetailWidget extends StatelessWidget {
  final BusinessDescription business;
  final List<Map<String, dynamic>> selectedServices;
  final ValueChanged<List<Map<String, dynamic>>> onSelectionChanged;

  const SalonDetailWidget({
    super.key,
    required this.business,
    required this.selectedServices,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("🔍 [SALON_DEBUG] businessName: ${business.businessName}");
    debugPrint("🔍 [SALON_DEBUG] businessCategory: ${business.businessCategory}");
    debugPrint("🔍 [SALON_DEBUG] categoryAttributes raw: ${business.categoryAttributes}");
    final attrs = business.categoryAttributes ?? {};
    debugPrint("🔍 [SALON_DEBUG] attrs: $attrs");
    final rawServices = attrs['services'] as List?;
    debugPrint("🔍 [SALON_DEBUG] rawServices: $rawServices");
    final List<Map<String, dynamic>> services = rawServices != null
        ? rawServices.map((s) => Map<String, dynamic>.from(s)).toList()
        : [];
    debugPrint("🔍 [SALON_DEBUG] services length: ${services.length}");

    final genderSupport = attrs['gender_support']?.toString();
    final stylistsCount = attrs['stylists_count']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Info Badges
        if (genderSupport != null || stylistsCount != null) ...[
          SizedBox(height: 32.h),
          _buildSalonInfoRow(genderSupport, stylistsCount),
        ],

        // Services & Packages
        SizedBox(height: 32.h),
        _buildSectionHeader(
          "Services & Packages",
          subtitle: "Tap to select services for booking request",
        ),
        SizedBox(height: 20.h),
        services.isNotEmpty
            ? _buildServicesList(services)
            : _buildEmptySection("No services added yet"),
      ],
    );
  }

  Widget _buildSalonInfoRow(String? genderSupport, String? stylistsCount) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              if (genderSupport != null) ...[
                _buildInfoBadge(
                  icon: genderSupport == 'men'
                      ? Icons.male_rounded
                      : genderSupport == 'women'
                          ? Icons.female_rounded
                          : Icons.wc_rounded,
                  label: genderSupport == 'men'
                      ? 'Men Only'
                      : genderSupport == 'women'
                          ? 'Women Only'
                          : 'Unisex',
                  color: const Color(0xFFE91E63),
                ),
                SizedBox(width: 16.w),
              ],
              if (stylistsCount != null)
                _buildInfoBadge(
                  icon: Icons.person_rounded,
                  label: '$stylistsCount Stylists',
                  color: const Color(0xFFE91E63),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 18.sp),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(List<Map<String, dynamic>> services) {
    return Column(
      children: [
        if (selectedServices.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColor.premiumAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.premiumAccent.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.checklist_rounded, color: AppColor.premiumAccent, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(
                        "${selectedServices.length} Service${selectedServices.length > 1 ? 's' : ''} Selected",
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.premiumAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final serviceName = service['name']?.toString() ?? 'Service';
            final price = (service['price'] as num?)?.toDouble() ?? 0.0;
            final duration = service['duration_minutes']?.toString() ?? '30';
            final description = service['description']?.toString() ?? '';
            final addOns = service['add_ons'] as List<dynamic>? ?? [];
            final isSelected = selectedServices.any((item) => item['name'] == serviceName);

            return GestureDetector(
              onTap: () {
                final updated = List<Map<String, dynamic>>.from(selectedServices);
                if (isSelected) {
                  updated.removeWhere((item) => item['name'] == serviceName);
                } else {
                  updated.add(service);
                }
                onSelectionChanged(updated);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(bottom: 12.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.premiumAccent.withOpacity(0.08)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.premiumAccent.withOpacity(0.5)
                              : Colors.white.withOpacity(0.08),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColor.premiumAccent.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.build_rounded,
                              color: isSelected ? AppColor.premiumAccent : Colors.white38,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        serviceName,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "₹${price.toInt()}",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColor.premiumAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Icon(Icons.schedule_outlined, size: 12.sp, color: Colors.white38),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "$duration mins",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11.sp,
                                        color: Colors.white38,
                                      ),
                                    ),
                                    if (addOns.isNotEmpty) ...[
                                      SizedBox(width: 12.w),
                                      Icon(Icons.extension_rounded, size: 12.sp, color: Colors.white38),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "${addOns.length} add-on${addOns.length > 1 ? 's' : ''}",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11.sp,
                                          color: Colors.white38,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (description.isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  Text(
                                    description,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.sp,
                                      color: Colors.white54,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (addOns.isNotEmpty) ...[
                                  SizedBox(height: 10.h),
                                  Wrap(
                                    spacing: 6.w,
                                    runSpacing: 4.h,
                                    children: addOns.map((addOn) {
                                      final aName = addOn['name']?.toString() ?? '';
                                      final aPrice = (addOn['price'] as num?)?.toDouble() ?? 0;
                                      if (aName.isEmpty) return SizedBox.shrink();
                                      return Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.04),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                                        ),
                                        child: Text(
                                          "$aName +₹${aPrice.toInt()}",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 9.sp,
                                            color: Colors.white54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextWidget(
          text: title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 11.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        SizedBox(height: 6.h),
        Container(
          height: 3,
          width: 40,
          decoration: BoxDecoration(
            color: AppColor.premiumAccent,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 32.sp, color: AppColor.premiumTextSecondary.withOpacity(0.5)),
          SizedBox(height: 8.h),
          AppTextWidget(
            text: message,
            fontSize: 13.sp,
            color: AppColor.premiumTextSecondary,
          ),
        ],
      ),
    );
  }
}
