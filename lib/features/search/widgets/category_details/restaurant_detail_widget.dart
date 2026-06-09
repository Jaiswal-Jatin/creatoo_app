import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:creatoo/core.dart';

import '../../../../resources/color.dart';
import '../../../../widgets/app_full_screen_image_view.dart';
import '../../../../widgets/app_image_widget.dart';
import '../../../../widgets/app_text_widget.dart';
import '../../model/business_details_response_model.dart';

/// Restaurant-specific detail widget showing menu carousel, cuisine tags, and seating info
class RestaurantDetailWidget extends StatelessWidget {
  final BusinessDescription business;

  const RestaurantDetailWidget({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final attrs = business.categoryAttributes ?? {};
    final cuisines = attrs['cuisines'] != null
        ? List<String>.from(attrs['cuisines'])
        : <String>[];
    final isVegOnly = attrs['is_veg_only'] == true;
    final seatingCapacity = attrs['seating_capacity']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menu Carousel
        _buildMenuCarousel(context),

        // // Category Quick Info Badges
        // if (cuisines.isNotEmpty || isVegOnly || seatingCapacity != null) ...[
        //   SizedBox(height: 32.h),
        //   _buildSectionHeader("Restaurant Info"),
      //     SizedBox(height: 16.h),
      //     _buildInfoChips(cuisines, isVegOnly, seatingCapacity),
      //   ],
      ],
    );
  }

  Widget _buildMenuCarousel(BuildContext context) {
    List<String> menuImages = [];
    final json = business.toJson();

    for (int i = 1; i <= 5; i++) {
      var imageUrl = json['menu_card_$i'];
      if (imageUrl != null) {
        menuImages.add(imageUrl);
      }
    }

    if (menuImages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.h),
        _buildSectionHeader("Menu"),
        SizedBox(height: 20.h),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: menuImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageCarouselView(
                        imageUrls: menuImages,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 160.w,
                  margin: EdgeInsets.only(right: 16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: AppImageWidget(
                      imageUrl: menuImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChips(List<String> cuisines, bool isVegOnly, String? seatingCapacity) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Veg/Non-Veg badge
              if (isVegOnly)
                Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, color: Colors.green, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        "Pure Vegetarian",
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

              // Seating capacity
              if (seatingCapacity != null && seatingCapacity.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Row(
                    children: [
                      Icon(Icons.chair_rounded, color: const Color(0xFFFF5722), size: 18.sp),
                      SizedBox(width: 10.w),
                      Text(
                        "Seating Capacity: $seatingCapacity",
                        style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

              // Cuisines
              if (cuisines.isNotEmpty) ...[
                Text(
                  "Cuisines",
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: cuisines.map((cuisine) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFF5722).withOpacity(0.2)),
                    ),
                    child: Text(
                      cuisine,
                      style: GoogleFonts.montserrat(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF5722),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextWidget(
          text: title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
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
