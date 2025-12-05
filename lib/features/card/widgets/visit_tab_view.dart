// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/card/data/visit_by_restaurant_response_model.dart';
import 'package:creatoo/features/card/view_model/card_visit_view_model.dart';
import 'package:creatoo/utils/enums/status.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  final bool isCardActive;
  
  const VisitTabView({super.key, required this.isCardActive});

  @override
  State<VisitTabView> createState() => _VisitTabViewState();
}

class _VisitTabViewState extends State<VisitTabView> {
  late CardVisitViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<CardVisitViewModel>(context, listen: false);
    // Fetch data on init only if card is active
    if (widget.isCardActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.fetchVisitByRestaurant(token ?? '');
      });
    }
  }

  // Helper to convert API response to Visit model
  List<RestaurantViewModel> _convertToRestaurantViewModels(
      VisitByRestaurantResponseModel apiResponse) {
    List<RestaurantViewModel> restaurants = [];

    if (apiResponse.restaurants != null && apiResponse.restaurants!.isNotEmpty) {
      for (var restaurant in apiResponse.restaurants!) {
        List<Visit> visits = [];

        if (restaurant.visits != null && restaurant.visits!.isNotEmpty) {
          for (var visit in restaurant.visits!) {
            visits.add(
              Visit(
                restaurantName: restaurant.businessName ?? 'Unknown Business',
                date: _parseDate(visit.time),
                tier: visit.tier ?? 'new',
                // <CHANGE> Using local asset instead of Images.placeholder
                imageUrl: restaurant.businessImage?.isNotEmpty == true
                    ? restaurant.businessImage!
                    : 'assets/images/logo.png',
              ),
            );
          }
        }

        if (visits.isNotEmpty) {
          restaurants.add(
            RestaurantViewModel(
              name: restaurant.businessName ?? 'Unknown Business',
              // <CHANGE> Using local asset instead of Images.placeholder
              imageUrl: restaurant.businessImage?.isNotEmpty == true
                  ? restaurant.businessImage!
                  : 'assets/images/logo.png',
              visits: visits,
            ),
          );
        }
      }
    }

    // Sort by most recent visit
    restaurants.sort((a, b) => b.mostRecentVisit.compareTo(a.mostRecentVisit));
    return restaurants;
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  // <CHANGE> Helper to check if URL is a network URL or local asset
  bool _isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show empty state if card is not active
    if (!widget.isCardActive) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.lightGrey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 64,
                  color: AppColor.grey,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Card Not Active',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Activate your Creatoo Card to view\nyour visit history',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColor.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<CardVisitViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.visitResponse.status == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.visitResponse.status == Status.error) {
          return Center(
            child: Text(
              'Error: ${viewModel.visitResponse.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (viewModel.visitResponse.status == Status.completed &&
            viewModel.visitResponse.data != null) {
          final restaurants =
              _convertToRestaurantViewModels(viewModel.visitResponse.data!);

          if (restaurants.isEmpty) {
            return const Center(
              child: Text('No visits yet'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];

              return _buildRestaurantCard(restaurant, theme);
            },
          );
        }

        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildRestaurantCard(RestaurantViewModel restaurant, ThemeData theme) {
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
            height: 100.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              // <CHANGE> Handle both network and asset images
              image: DecorationImage(
                image: _isNetworkImage(restaurant.imageUrl)
                    ? NetworkImage(restaurant.imageUrl) as ImageProvider
                    : AssetImage(restaurant.imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
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
                      fontWeight: FontWeight.w700,
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
    // <CHANGE> Fixed tier mapping - now correctly maps API tier values
    final rawTier = visit.tier.toLowerCase();
    
    // <CHANGE> Correct tier to gradient and label mapping
    List<Color> tierGradient;
    String tierLabel;
    
    switch (rawTier) {
      case 'premium':
        tierGradient = AppColor.goldGradient;
        tierLabel = 'PREMIUM';
        break;
      case 'elite':
        tierGradient = AppColor.silverGradient;
        tierLabel = 'ELITE';
        break;
      case 'core':
        tierGradient = AppColor.bronzeGradient;
        tierLabel = 'CORE';
        break;
      case 'new':
        tierGradient = AppColor.goldGradient;
        tierLabel = 'NEW';
        break;
      // <CHANGE> Handle legacy gold/silver/bronze values if any
      case 'gold':
        tierGradient = AppColor.goldGradient;
        tierLabel = 'PREMIUM';
        break;
      case 'silver':
        tierGradient = AppColor.silverGradient;
        tierLabel = 'ELITE';
        break;
      case 'bronze':
        tierGradient = AppColor.bronzeGradient;
        tierLabel = 'CORE';
        break;
      default:
        // <CHANGE> Default to PREMIUM instead of CORE
        tierGradient = AppColor.goldGradient;
        tierLabel = 'PREMIUM';
    }

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

          // <CHANGE> Tier badge with correct mapping
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: tierGradient[0],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tierLabel,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColor.black,
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