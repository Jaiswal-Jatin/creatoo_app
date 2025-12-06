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

              return _buildRestaurantCard(restaurant, theme, context);
            },
          );
        }

        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildRestaurantCard(RestaurantViewModel restaurant, ThemeData theme, BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;
    
    // Responsive values
    double cardMargin;
    double headerHeight;
    double borderRadius;
    double titleFontSize;
    double subtitleFontSize;
    double iconSize;
    double padding;
    double expansionTitleFontSize;
    double expansionIconSize;
    
    if (isVerySmall) {
      cardMargin = 10;
      headerHeight = 70;
      borderRadius = 12;
      titleFontSize = 14;
      subtitleFontSize = 10;
      iconSize = 10;
      padding = 10;
      expansionTitleFontSize = 12;
      expansionIconSize = 18;
    } else if (isSmall) {
      cardMargin = 12;
      headerHeight = 80;
      borderRadius = 14;
      titleFontSize = 15;
      subtitleFontSize = 11;
      iconSize = 11;
      padding = 12;
      expansionTitleFontSize = 13;
      expansionIconSize = 19;
    } else if (isMedium) {
      cardMargin = 14;
      headerHeight = 90;
      borderRadius = 15;
      titleFontSize = 16;
      subtitleFontSize = 11;
      iconSize = 12;
      padding = 14;
      expansionTitleFontSize = 14;
      expansionIconSize = 20;
    } else {
      cardMargin = 16;
      headerHeight = 100;
      borderRadius = 16;
      titleFontSize = 18;
      subtitleFontSize = 12;
      iconSize = 12;
      padding = 16;
      expansionTitleFontSize = 16;
      expansionIconSize = 22;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: cardMargin),
      decoration: BoxDecoration(
        color: AppColor.moreLighterDd.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
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
            height: headerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
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
                    BorderRadius.vertical(top: Radius.circular(borderRadius)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColor.black,
                  ],
                ),
              ),
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Restaurant name
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color: AppColor.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: padding * 0.25),

                  // Visit info row
                  Row(
                    children: [
                      // Last visit date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: iconSize,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          SizedBox(width: padding * 0.25),
                          Text(
                            DateFormat('MMM d, yyyy')
                                .format(restaurant.mostRecentVisit),
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: AppColor.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: padding * 0.75),

                      // Visit count
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: iconSize + 2,
                            color: AppColor.mangoYellow,
                          ),
                          SizedBox(width: padding * 0.25),
                          Text(
                            '${restaurant.visits.length} ${restaurant.visits.length == 1 ? 'Visit' : 'Visits'}',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
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
                  BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
            ),
            child: Theme(
              data: theme.copyWith(
                dividerColor: AppColor.transparent,
                cardColor: AppColor.moreLighterDd,
              ),
              child: ExpansionTile(
                tilePadding:
                    EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.25),
                title: Text(
                  'View Visit History',
                  style: TextStyle(
                    fontSize: expansionTitleFontSize,
                    color: AppColor.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColor.black,
                  size: expansionIconSize,
                ),
                children: [
                  _buildVisitHistory(restaurant.visits, theme, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitHistory(List<Visit> visits, ThemeData theme, BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;
    
    double bottomPadding = isVerySmall ? 8 : isSmall ? 10 : isMedium ? 11 : 12;
    double verticalPadding = isVerySmall ? 3 : isSmall ? 3 : isMedium ? 4 : 4;
    
    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        children: [
          Divider(height: 2, color: AppColor.black),
          SizedBox(height: verticalPadding),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            itemCount: visits.length,
            separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              child: Divider(height: 0, color: AppColor.transparent),
            ),
            itemBuilder: (context, index) {
              final visit = visits[index];
              return _buildVisitRow(visit, theme, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisitRow(Visit visit, ThemeData theme, BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;
    
    // Responsive values
    double horizontalMargin;
    double verticalMargin;
    double horizontalPadding;
    double verticalPadding;
    double borderRadius;
    double iconContainerSize;
    double calendarIconSize;
    double dateFontSize;
    double timeFontSize;
    double timeIconSize;
    double tierPaddingH;
    double tierPaddingV;
    double tierFontSize;
    
    if (isVerySmall) {
      horizontalMargin = 8;
      verticalMargin = 1;
      horizontalPadding = 8;
      verticalPadding = 6;
      borderRadius = 10;
      iconContainerSize = 28;
      calendarIconSize = 14;
      dateFontSize = 11;
      timeFontSize = 9;
      timeIconSize = 9;
      tierPaddingH = 7;
      tierPaddingV = 3;
      tierFontSize = 8;
    } else if (isSmall) {
      horizontalMargin = 10;
      verticalMargin = 2;
      horizontalPadding = 10;
      verticalPadding = 8;
      borderRadius = 11;
      iconContainerSize = 30;
      calendarIconSize = 15;
      dateFontSize = 12;
      timeFontSize = 10;
      timeIconSize = 10;
      tierPaddingH = 8;
      tierPaddingV = 3;
      tierFontSize = 9;
    } else if (isMedium) {
      horizontalMargin = 11;
      verticalMargin = 2;
      horizontalPadding = 11;
      verticalPadding = 9;
      borderRadius = 11;
      iconContainerSize = 33;
      calendarIconSize = 16;
      dateFontSize = 13;
      timeFontSize = 11;
      timeIconSize = 11;
      tierPaddingH = 9;
      tierPaddingV = 3;
      tierFontSize = 9;
    } else {
      horizontalMargin = 12;
      verticalMargin = 2;
      horizontalPadding = 12;
      verticalPadding = 10;
      borderRadius = 12;
      iconContainerSize = 36;
      calendarIconSize = 18;
      dateFontSize = 14;
      timeFontSize = 12;
      timeIconSize = 12;
      tierPaddingH = 10;
      tierPaddingV = 4;
      tierFontSize = 10;
    }
    
    // Tier mapping
    final rawTier = visit.tier.toLowerCase();
    
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
        tierGradient = AppColor.goldGradient;
        tierLabel = 'PREMIUM';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Date icon
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: calendarIconSize,
              color: AppColor.black.withOpacity(0.5),
            ),
          ),

          SizedBox(width: horizontalPadding),

          // Visit details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(visit.date),
                  style: TextStyle(
                    fontSize: dateFontSize,
                    color: AppColor.dd,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: verticalPadding * 0.2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: timeIconSize,
                      color: AppColor.grey,
                    ),
                    SizedBox(width: horizontalPadding * 0.3),
                    Text(
                      '${DateFormat('h:mm a').format(visit.date)}',
                      style: TextStyle(
                        fontSize: timeFontSize,
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
            padding: EdgeInsets.symmetric(horizontal: tierPaddingH, vertical: tierPaddingV),
            decoration: BoxDecoration(
              color: tierGradient[0],
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Text(
              tierLabel,
              style: TextStyle(
                fontSize: tierFontSize,
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