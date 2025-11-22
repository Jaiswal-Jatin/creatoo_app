// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:creatoo/core.dart'; // For AppColor, SizeConfig
import 'package:intl/intl.dart';

// Data model for a single visit
class Visit {
  final String restaurantName;
  final DateTime date;
  final String tier;
  final String imageUrl;

  Visit({
    required this.restaurantName,
    required this.date,
    required this.tier,
    required this.imageUrl,
  });
}

// ViewModel for a restaurant, containing its visit history
class RestaurantViewModel {
  final String name;
  final String imageUrl;
  final List<Visit> visits;

  RestaurantViewModel({
    required this.name,
    required this.imageUrl,
    required this.visits,
  });

  // Get the most recent visit date for sorting
  DateTime get mostRecentVisit => visits.first.date;
}

class VisitTabView extends StatefulWidget {
  const VisitTabView({super.key});

  @override
  State<VisitTabView> createState() => _VisitTabViewState();
}

class _VisitTabViewState extends State<VisitTabView> {
  late List<RestaurantViewModel> _restaurants;

  @override
  void initState() {
    super.initState();
    _restaurants = _processVisits(_getMockVisits());
    // Sort restaurants by the most recent visit
    _restaurants.sort((a, b) => b.mostRecentVisit.compareTo(a.mostRecentVisit));
  }

  // Helper to group visits by restaurant
  List<RestaurantViewModel> _processVisits(List<Visit> visits) {
    // Group visits by restaurant name
    final Map<String, List<Visit>> groupedVisits = {};
    for (final visit in visits) {
      if (!groupedVisits.containsKey(visit.restaurantName)) {
        groupedVisits[visit.restaurantName] = [];
      }
      // Sort visits for each restaurant by date (newest first)
      groupedVisits[visit.restaurantName]!.add(visit);
    }

    // Sort visits within each restaurant and create the view models
    return groupedVisits.entries.map((entry) {
      final restaurantName = entry.key;
      final restaurantVisits = entry.value;
      restaurantVisits.sort(
          (a, b) => b.date.compareTo(a.date)); // Sort visits for the restaurant
      return RestaurantViewModel(
        name: restaurantName,
        imageUrl: restaurantVisits.first.imageUrl,
        visits: restaurantVisits,
      );
    }).toList();
  }

  // Mock data source
  List<Visit> _getMockVisits() {
    return [
      Visit(
          restaurantName: 'The Grand Bistro',
          date: DateTime(2025, 10, 26),
          tier: 'Gold',
          imageUrl:
              'https://images.unsplash.com/photo-1552566626-52f8b828add9?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
      Visit(
          restaurantName: 'Pizza Palace',
          date: DateTime(2025, 9, 15),
          tier: 'Silver',
          imageUrl:
              'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
      Visit(
          restaurantName: 'The Grand Bistro',
          date: DateTime(2025, 8, 1),
          tier: 'Silver',
          imageUrl:
              'https://images.unsplash.com/photo-1552566626-52f8b828add9?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
      Visit(
          restaurantName: 'Cafe Delight',
          date: DateTime(2025, 7, 20),
          tier: 'Bronze',
          imageUrl:
              'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
      Visit(
          restaurantName: 'The Grand Bistro',
          date: DateTime(2025, 6, 5),
          tier: 'Gold',
          imageUrl:
              'https://images.unsplash.com/photo-1552566626-52f8b828add9?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
      Visit(
          restaurantName: 'Sushi Express',
          date: DateTime(2025, 11, 1),
          tier: 'Gold',
          imageUrl:
              'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
      Visit(
          restaurantName: 'Cafe Delight',
          date: DateTime(2025, 10, 30),
          tier: 'Silver',
          imageUrl:
              'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        final tier = restaurant.visits.first.tier.toLowerCase();
        final tierGradient = tier == 'gold'
            ? AppColor.goldGradient
            : tier == 'silver'
                ? AppColor.silverGradient
                : AppColor.bronzeGradient;

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: AppColor.moreLighterDd.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.grey.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColor.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with image and basic info
              Container(
                height: 100.h, // Reduced height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(restaurant.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColor.black,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Restaurant name
                      Text(
                        restaurant.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColor.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 6,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // Visit info row
                      Row(
                        children: [
                          // Last visit date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                DateFormat('MMM d, yyyy')
                                    .format(restaurant.mostRecentVisit),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColor.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 12.w),

                          // Visit count
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14.sp,
                                color: AppColor.mangoYellow,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${restaurant.visits.length} ${restaurant.visits.length == 1 ? 'Visit' : 'Visits'}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColor.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Visit history section
              Container(
                decoration: BoxDecoration(
                  color: AppColor.moreLighterDd.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Theme(
                  data: theme.copyWith(
                    dividerColor: AppColor.transparent,
                    cardColor: AppColor.moreLighterDd,
                  ),
                  child: ExpansionTile(
                    tilePadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    title: Text(
                      'View Visit History',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColor.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColor.black,
                      size: 22.sp,
                    ),
                    children: [
                      _buildVisitHistory(restaurant.visits, theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisitHistory(List<Visit> visits, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        children: [
          Divider(height: 2, color: AppColor.black),
          SizedBox(height: 4.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 4.h),
            itemCount: visits.length,
            separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Divider(height: 0, color: AppColor.transparent),
            ),
            itemBuilder: (context, index) {
              final visit = visits[index];
              return _buildVisitRow(visit, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisitRow(Visit visit, ThemeData theme) {
    final tierGradient = visit.tier.toLowerCase() == 'gold'
        ? AppColor.goldGradient
        : visit.tier.toLowerCase() == 'silver'
            ? AppColor.silverGradient
            : AppColor.bronzeGradient;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Date icon
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 18.sp,
              color: AppColor.black.withOpacity(0.5),
            ),
          ),

          SizedBox(width: 12.w),

          // Visit details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(visit.date),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.dd,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12.sp,
                      color: AppColor.grey,
                      
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${DateFormat('h:mm a').format(visit.date)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColor.grey,
                         fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tier badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: tierGradient[0], // Solid background color
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              visit.tier.toUpperCase(),
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColor.black, // Black text for better contrast
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
