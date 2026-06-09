import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:creatoo/core.dart';

import '../../../../resources/color.dart';
import '../../../../widgets/app_text_widget.dart';
import '../../model/business_details_response_model.dart';

class TurfDetailWidget extends StatelessWidget {
  final BusinessDescription business;
  final List<Map<String, dynamic>> selectedServices;
  final ValueChanged<List<Map<String, dynamic>>> onSelectionChanged;

  const TurfDetailWidget({
    super.key,
    required this.business,
    this.selectedServices = const [],
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final attrs = business.categoryAttributes ?? {};
    final turfSize = attrs['turf_size']?.toString() ?? '7v7';
    final groundType = attrs['ground_type']?.toString() ?? 'Artificial Grass';
    final rawServices = attrs['services'] as List?;
    final amenities = attrs['amenities'] != null
        ? List<String>.from(attrs['amenities'])
        : <String>[];

    final sportTypes = attrs['sport_types'] != null
        ? List<String>.from(attrs['sport_types'])
        : <String>[];

    final List<Map<String, dynamic>> services = rawServices != null
        ? rawServices.map((s) => Map<String, dynamic>.from(s)).where((s) {
            final serviceName = s['name']?.toString().toLowerCase().trim() ?? '';
            
            // 1. Filter out amenities
            final isAmenity = amenities.any((amenity) {
              final amenityLower = amenity.toLowerCase().trim();
              return serviceName == amenityLower || serviceName.contains(amenityLower);
            });
            if (isAmenity) return false;

            // 2. Filter sports to only show ones matching supported sportTypes (if not empty)
            if (sportTypes.isNotEmpty) {
              return sportTypes.any((sport) {
                final sportLower = sport.toLowerCase().trim();
                return serviceName == sportLower || serviceName.contains(sportLower);
              });
            }
            return true;
          }).toList()
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.h),
        _buildGroundInfoCard(turfSize, groundType),

        SizedBox(height: 32.h),
        _buildSectionHeader("Amenities"),
        SizedBox(height: 16.h),
        amenities.isNotEmpty
            ? _buildAmenitiesGrid(amenities, rawServices)
            : _buildEmptySection("No amenities listed yet"),
        SizedBox(height: 32.h),
        _buildSectionHeader(
          "Sports",
          subtitle: "Tap to select sports for booking request",
        ),
        SizedBox(height: 16.h),
        services.isNotEmpty
            ? _buildSportsList(services, sportTypes)
            : _buildEmptySection("No sports added yet"),

 
      ],
    );
  }

  IconData _getSportIcon(String sportName) {
    final name = sportName.toLowerCase();
    if (name.contains('football') || name.contains('soccer')) return Icons.sports_soccer_rounded;
    if (name.contains('cricket')) return Icons.sports_cricket_rounded;
    if (name.contains('volleyball')) return Icons.sports_volleyball_rounded;
    if (name.contains('badminton') || name.contains('tennis') || name.contains('racket') || name.contains('pickle')) return Icons.sports_tennis_rounded;
    if (name.contains('basketball')) return Icons.sports_basketball_rounded;
    if (name.contains('hockey')) return Icons.sports_hockey_rounded;
    if (name.contains('golf')) return Icons.sports_golf_rounded;
    if (name.contains('kabaddi') || name.contains('wrestling')) return Icons.sports_kabaddi_rounded;
    return Icons.sports_handball_rounded;
  }

  IconData _getAmenityIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('parking')) return Icons.local_parking_rounded;
    if (n.contains('washroom') || n.contains('toilet') || n.contains('restroom') || n.contains('bathroom')) return Icons.wc_rounded;
    if (n.contains('floodlight') || n.contains('light')) return Icons.lightbulb_rounded;
    if (n.contains('changing') || n.contains('locker') || n.contains('room')) return Icons.door_sliding_rounded;
    if (n.contains('water') || n.contains('drinking')) return Icons.water_drop_rounded;
    if (n.contains('first aid') || n.contains('medical') || n.contains('kit')) return Icons.medical_services_rounded;
    if (n.contains('shower')) return Icons.shower_rounded;
    if (n.contains('wifi') || n.contains('internet')) return Icons.wifi_rounded;
    if (n.contains('canteen') || n.contains('cafe') || n.contains('food') || n.contains('snacks')) return Icons.restaurant_rounded;
    return Icons.check_circle_outline_rounded;
  }

  Widget _buildSportsList(List<Map<String, dynamic>> services, List<String> sportTypes) {
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
                        "${selectedServices.length} Sport${selectedServices.length > 1 ? 's' : ''} Selected",
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
            final name = service['name']?.toString() ?? 'Sport';
            final price = (service['price'] as num?)?.toDouble() ?? 0.0;
            final duration = service['duration_minutes']?.toString() ?? '60';
            final description = service['description']?.toString() ?? '';
            final isSelected = selectedServices.any((item) => item['name'] == name);
            final icon = _getSportIcon(name);

            return GestureDetector(
              onTap: () {
                final updated = List<Map<String, dynamic>>.from(selectedServices);
                if (isSelected) {
                  updated.removeWhere((item) => item['name'] == name);
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
                              isSelected ? Icons.check_circle_rounded : icon,
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
                                        name,
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

  double? _getAmenityPrice(String amenityName, List<dynamic>? rawServices) {
    if (rawServices == null) return null;
    for (final s in rawServices) {
      if (s is Map) {
        final name = s['name']?.toString().toLowerCase().trim() ?? '';
        final amenityLower = amenityName.toLowerCase().trim();
        if (name == amenityLower || name.contains(amenityLower)) {
          final price = (s['price'] as num?)?.toDouble();
          if (price != null && price > 0) {
            return price;
          }
        }
      }
    }
    return null;
  }

  Widget _buildAmenitiesGrid(List<String> amenities, List<dynamic>? rawServices) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        final icon = _getAmenityIcon(amenity);
        final price = _getAmenityPrice(amenity, rawServices);

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColor.premiumAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColor.premiumAccent, size: 18.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    amenity,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    price != null && price > 0 ? "₹${price.toInt()}" : "Free",
                    style: GoogleFonts.montserrat(
                      fontSize: 9.sp,
                      fontWeight: price != null ? FontWeight.w800 : FontWeight.w500,
                      color: price != null ? AppColor.premiumAccent : Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildGroundInfoCard(String turfSize, String groundType) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                ),
                child: Text(
                  turfSize,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.grass_rounded, color: Colors.white38, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                groundType,
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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
}
