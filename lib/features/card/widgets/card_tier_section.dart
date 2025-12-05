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
  List<VisitHistory> _filterVisitsByTier(List<VisitHistory> visits, String tier) {
    return visits.where((visit) => visit.tier.toLowerCase() == tier.toLowerCase()).toList();
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
      debugPrint('Error fetching user tier history in UI: ${_cardViewModel.userTierHistoryResponse.toString()}');
      _tiers = List.from(_defaultTiers);
    }
  }

  // Define default tiers structure
  final List<Map<String, dynamic>> _defaultTiers = [
    {
      'name': 'Premium Tier',
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
      'name': 'Elite Tier',
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
      'name': 'Core Tier',
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

  // Helper to format visit history for display
  List<Map<String, String>> _formatVisitHistory(List<VisitHistory> visits) {
    return visits.map<Map<String, String>>((visit) => {
      'place': visit.businessName,
      'date': visit.time,
      'tier': visit.tier,
      'image': visit.businessImage ?? '',
    }).toList();
  }

  void _toggleExpand(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show empty state if card is not active
    if (!widget.isCardActive) {
      return Scaffold(
        body: Center(
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
                    Icons.credit_card_off_rounded,
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
                  'Activate your Creatoo Card to view\nyour tier information and benefits',
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
        ),
      );
    }
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display a loading indicator or error message if needed
            if (_cardViewModel.userTierHistoryResponse.status == Status.loading)
              const Center(child: CircularProgressIndicator()),
            if (_cardViewModel.userTierHistoryResponse.status == Status.error)
              Center(child: Text('Error: ${_cardViewModel.userTierHistoryResponse.message ?? 'Unknown error'}')),
            
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.3),
              blurRadius: 20,
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
          borderRadius: BorderRadius.circular(24.0),
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
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
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tierName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontFamily: 'SFUIText',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 16,
                                      color: textColor.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$visits Total Visits',
                                      style: TextStyle(
                                        fontSize: 15,
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 28,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      AnimatedCrossFade(
                        firstChild: Container(),
                        secondChild: _buildVisitHistory(),
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

  Widget _buildVisitHistory() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 20,
                color: textColor.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Visit History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'SFUIText',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...visitHistory.map(
            (visit) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      color: textColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.businessName,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            fontFamily: 'SFUIText',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: textColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(visit.time),
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 13,
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
