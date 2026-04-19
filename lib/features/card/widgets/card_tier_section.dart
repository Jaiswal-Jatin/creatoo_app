import 'package:creatoo/resources/color.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:creatoo/features/card/view_model/card_view_model.dart';
import 'package:creatoo/utils/enums/status.dart'; // Correct and singular import for Status
import 'package:creatoo/features/card/data/user_tier_history_response_model.dart';

class CardTierSection extends StatefulWidget {
  final bool isCardActive;

  const CardTierSection({super.key, required this.isCardActive});

  @override
  State<CardTierSection> createState() => _CardTierSectionState();
}

class _CardTierSectionState extends State<CardTierSection> {
  int? _expandedIndex;
  late CardViewModel _cardViewModel;
  List<Map<String, dynamic>> _tiers = []; // Make it mutable

  @override
  void initState() {
    super.initState();
    _cardViewModel = Provider.of<CardViewModel>(context, listen: false);

    // Schedule the API call for the next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardViewModel.getUserTierHistory();
    });

    _cardViewModel.addListener(_onUserTierHistoryChanged);
    // Initial update with default values
    _tiers = List.from(_defaultTiers);
  }

  @override
  void dispose() {
    _cardViewModel.removeListener(_onUserTierHistoryChanged);
    super.dispose();
  }

  void _onUserTierHistoryChanged() {
    if (mounted) {
      _updateTiersBasedOnViewModel();
      setState(() {});
    }
  }

  // Helper method to filter visits by tier
  List<VisitHistory> _filterVisitsByTier(
      List<VisitHistory> visits, String tier) {
    return visits
        .where((visit) => visit.tier.toLowerCase() == tier.toLowerCase())
        .toList();
  }

  void _updateTiersBasedOnViewModel() {
    if (_cardViewModel.userTierHistoryResponse.status == Status.completed) {
      try {
        final responseData = _cardViewModel.userTierHistoryResponse.data;
        if (responseData == null || !responseData.status) {
          _tiers = List.from(_defaultTiers);
          return;
        }

        final allVisits = responseData.history;

        // Categorize visits by tier
        _tiers = _defaultTiers.map((tier) {
          final tierName = (tier['name'] as String).toLowerCase();
          List<VisitHistory> tierVisits;

          // Handle different tier names
          if (tierName.contains('premium')) {
            tierVisits = _filterVisitsByTier(allVisits, 'premium') +
                _filterVisitsByTier(allVisits, 'new');
          } else if (tierName.contains('elite')) {
            tierVisits = _filterVisitsByTier(allVisits, 'elite');
          } else {
            tierVisits = _filterVisitsByTier(allVisits, 'core');
          }

          return {
            ...tier,
            'visits': tierVisits.length,
            'history': tierVisits,
          };
        }).toList();
      } catch (e) {
        debugPrint('Error updating tiers: $e');
        _tiers = List.from(_defaultTiers);
      }
    } else if (_cardViewModel.userTierHistoryResponse.status == Status.error) {
      debugPrint(
          'Error fetching user tier history in UI: ${_cardViewModel.userTierHistoryResponse.toString()}');
      _tiers = List.from(_defaultTiers);
    }
  }

  // Define default tiers structure
  final List<Map<String, dynamic>> _defaultTiers = [
    {
      'name': 'Premium',
      'visits': 0,
      'gradient': const LinearGradient(
          colors: AppColor.goldGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      'textColor': Colors.black87,
      'icon': Icons.workspace_premium_rounded,
      'iconColor': const Color(0xFFD4AF37),
      'history': <VisitHistory>[],
    },
    {
      'name': 'Elite',
      'visits': 0,
      'gradient': const LinearGradient(
          colors: AppColor.silverGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      'textColor': Colors.black87,
      'icon': Icons.stars_rounded,
      'iconColor': const Color(0xFFC0C0C0),
      'history': <VisitHistory>[],
    },
    {
      'name': 'Core',
      'visits': 0,
      'gradient': const LinearGradient(
          colors: AppColor.bronzeGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      'textColor': Colors.black,
      'icon': Icons.star_half_rounded,
      'iconColor': const Color(0xFFCD7F32),
      'history': <VisitHistory>[],
    },
  ];

  void _toggleExpand(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show empty state if card is not active
    if (!widget.isCardActive) {
      return Container(
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColor.premiumCardBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.credit_card_off_rounded,
                    size: 64,
                    color: AppColor.premiumTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Card Not Active',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColor.premiumTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Activate your Creatoo Card to view\nyour tier information and benefits',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColor.premiumTextSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display a loading indicator or error message if needed
            if (_cardViewModel.userTierHistoryResponse.status == Status.loading)
              const Center(child: CircularProgressIndicator()),
            if (_cardViewModel.userTierHistoryResponse.status == Status.error)
              Center(
                  child: Text(
                      'Error: ${_cardViewModel.userTierHistoryResponse.message ?? 'Unknown error'}')),

            // Display the fetched data, or default data if loading/error
            ...List.generate(_tiers.length, (index) {
              final tier = _tiers[index];
              return TierCard(
                tierName: tier['name'],
                visits: tier['visits'],
                gradient: tier['gradient'],
                textColor: tier['textColor'],
                tierIcon: tier['icon'],
                iconColor: tier['iconColor'],
                isExpanded: _expandedIndex == index,
                onTap: () => _toggleExpand(index),
                visitHistory: tier['history'],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class TierCard extends StatelessWidget {
  final String tierName;
  final int visits;
  final Gradient gradient;
  final Color textColor;
  final IconData tierIcon;
  final Color iconColor;
  final bool isExpanded;
  final VoidCallback onTap;
  final List<VisitHistory> visitHistory;

  const TierCard({
    super.key,
    required this.tierName,
    required this.visits,
    required this.gradient,
    required this.textColor,
    required this.tierIcon,
    required this.iconColor,
    required this.isExpanded,
    required this.onTap,
    required this.visitHistory,
  });

  // Helper method to format date for display
  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    // Responsive breakpoints
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;

    // Responsive values
    double cardPadding;
    double cardMargin;
    double borderRadius;
    double iconContainerPadding;
    double iconSize;
    double tierNameFontSize;
    double visitsFontSize;
    double visitIconSize;
    double arrowIconSize;
    double shadowBlur;

    if (isVerySmall) {
      cardPadding = 10;
      cardMargin = 4;
      borderRadius = 12;
      iconContainerPadding = 5;
      iconSize = 14;
      tierNameFontSize = 12;
      visitsFontSize = 9;
      visitIconSize = 9;
      arrowIconSize = 16;
      shadowBlur = 8;
    } else if (isSmall) {
      cardPadding = 11;
      cardMargin = 5;
      borderRadius = 13;
      iconContainerPadding = 6;
      iconSize = 16;
      tierNameFontSize = 13;
      visitsFontSize = 10;
      visitIconSize = 10;
      arrowIconSize = 17;
      shadowBlur = 9;
    } else if (isMedium) {
      cardPadding = 12;
      cardMargin = 5;
      borderRadius = 14;
      iconContainerPadding = 6;
      iconSize = 18;
      tierNameFontSize = 14;
      visitsFontSize = 10;
      visitIconSize = 10;
      arrowIconSize = 18;
      shadowBlur = 10;
    } else {
      cardPadding = 14;
      cardMargin = 6;
      borderRadius = 16;
      iconContainerPadding = 8;
      iconSize = 20;
      tierNameFontSize = 16;
      visitsFontSize = 11;
      visitIconSize = 11;
      arrowIconSize = 20;
      shadowBlur = 12;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: cardMargin),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.3),
              blurRadius: shadowBlur,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColor.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(iconContainerPadding),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              tierIcon,
                              color: iconColor,
                              size: iconSize,
                            ),
                          ),
                          SizedBox(width: cardPadding * 0.6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tierName,
                                  style: TextStyle(
                                    fontSize: tierNameFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontFamily: 'SFUIText',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: cardPadding * 0.15),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: visitIconSize,
                                      color: textColor.withOpacity(0.7),
                                    ),
                                    SizedBox(width: cardPadding * 0.15),
                                    Text(
                                      '$visits Total Visits',
                                      style: TextStyle(
                                        fontSize: visitsFontSize,
                                        color: textColor.withOpacity(0.8),
                                        fontFamily: 'SFUIText',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(cardPadding * 0.3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: arrowIconSize,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      AnimatedCrossFade(
                        firstChild: Container(),
                        secondChild: _buildVisitHistory(context),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 400),
                        reverseDuration: const Duration(milliseconds: 400),
                        sizeCurve: Curves.easeInOutCubic,
                        firstCurve: Curves.easeInOutCubic,
                        secondCurve: Curves.easeInOutCubic,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitHistory(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    // Responsive breakpoints
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;

    // Responsive values
    double topPadding;
    double historyTitleFontSize;
    double historyIconSize;
    double itemPadding;
    double itemMargin;
    double storeIconSize;
    double storeIconPadding;
    double businessNameFontSize;
    double dateFontSize;
    double dateIconSize;
    double borderRadius;

    if (isVerySmall) {
      topPadding = 12;
      historyTitleFontSize = 12;
      historyIconSize = 14;
      itemPadding = 8;
      itemMargin = 8;
      storeIconSize = 14;
      storeIconPadding = 5;
      businessNameFontSize = 11;
      dateFontSize = 9;
      dateIconSize = 9;
      borderRadius = 8;
    } else if (isSmall) {
      topPadding = 14;
      historyTitleFontSize = 13;
      historyIconSize = 15;
      itemPadding = 9;
      itemMargin = 9;
      storeIconSize = 15;
      storeIconPadding = 6;
      businessNameFontSize = 12;
      dateFontSize = 10;
      dateIconSize = 10;
      borderRadius = 9;
    } else if (isMedium) {
      topPadding = 16;
      historyTitleFontSize = 14;
      historyIconSize = 16;
      itemPadding = 10;
      itemMargin = 10;
      storeIconSize = 16;
      storeIconPadding = 6;
      businessNameFontSize = 13;
      dateFontSize = 11;
      dateIconSize = 10;
      borderRadius = 10;
    } else {
      topPadding = 18;
      historyTitleFontSize = 15;
      historyIconSize = 18;
      itemPadding = 10;
      itemMargin = 10;
      storeIconSize = 18;
      storeIconPadding = 7;
      businessNameFontSize = 14;
      dateFontSize = 12;
      dateIconSize = 11;
      borderRadius = 10;
    }

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  textColor.withOpacity(0.1),
                  textColor.withOpacity(0.3),
                  textColor.withOpacity(0.1),
                ],
              ),
            ),
          ),
          SizedBox(height: topPadding * 0.8),
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: historyIconSize,
                color: textColor.withOpacity(0.8),
              ),
              SizedBox(width: topPadding * 0.4),
              Text(
                'Visit History',
                style: TextStyle(
                  fontSize: historyTitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'SFUIText',
                ),
              ),
            ],
          ),
          SizedBox(height: topPadding * 0.6),
          ...visitHistory.map(
            (visit) => Container(
              margin: EdgeInsets.only(bottom: itemMargin),
              padding: EdgeInsets.all(itemPadding),
              decoration: BoxDecoration(
                color: AppColor.premiumCardBg,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: AppColor.premiumAccent.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(storeIconPadding),
                    decoration: BoxDecoration(
                      color: AppColor.premiumAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(borderRadius * 0.8),
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      color: AppColor.premiumAccent,
                      size: storeIconSize,
                    ),
                  ),
                  SizedBox(width: itemPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.businessName,
                          style: TextStyle(
                            color: AppColor.premiumTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: businessNameFontSize,
                            fontFamily: 'SFUIText',
                          ),
                        ),
                        SizedBox(height: itemPadding * 0.15),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: dateIconSize,
                              color: AppColor.premiumTextSecondary,
                            ),
                            SizedBox(width: itemPadding * 0.3),
                            Text(
                              _formatDate(visit.time),
                              style: TextStyle(
                                color: AppColor.premiumTextSecondary,
                                fontSize: dateFontSize,
                                fontFamily: 'SFUIText',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
