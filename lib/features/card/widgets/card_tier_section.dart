import 'package:creatoo/resources/color.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class CardTierSection extends StatefulWidget {
  const CardTierSection({super.key});

  @override
  State<CardTierSection> createState() => _CardTierSectionState();
}

class _CardTierSectionState extends State<CardTierSection> {
  int? _expandedIndex;

  final List<Map<String, dynamic>> _tiers = [
    {
      'name': 'Golden Tier',
      'visits': 15,
      'gradient': const LinearGradient(
          colors: AppColor.goldGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      'textColor': Colors.black87,
      'icon': Icons.workspace_premium_rounded,
      'iconColor': const Color(0xFFD4AF37),
      'history': [
        {'place': 'The Grand Restaurant', 'date': '2025-11-20'},
        {'place': 'Ocean View Cafe', 'date': '2025-11-15'},
        {'place': 'Mountain Top Bistro', 'date': '2025-11-05'},
      ]
    },
    {
      'name': 'Silver Tier',
      'visits': 8,
      'gradient': const LinearGradient(
          colors: AppColor.silverGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      'textColor': Colors.black87,
      'icon': Icons.stars_rounded,
      'iconColor': const Color(0xFFC0C0C0),
      'history': [
        {'place': 'City Diner', 'date': '2025-10-30'},
        {'place': 'The Corner Cafe', 'date': '2025-10-22'},
      ]
    },
    {
      'name': 'Bronze Tier',
      'visits': 3,
      'gradient': const LinearGradient(
          colors: AppColor.bronzeGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      'textColor': Colors.black,
      'icon': Icons.star_half_rounded,
      'iconColor': const Color(0xFFCD7F32),
      'history': [
        {'place': 'Local Coffee Shop', 'date': '2025-09-12'},
      ]
    },
  ];

  void _toggleExpand(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.all(10),
            //       decoration: BoxDecoration(
            //         gradient: const LinearGradient(
            //           colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            //           begin: Alignment.topLeft,
            //           end: Alignment.bottomRight,
            //         ),
            //         borderRadius: BorderRadius.circular(12),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.orange.withOpacity(0.3),
            //             blurRadius: 8,
            //             offset: const Offset(0, 4),
            //           ),
            //         ],
            //       ),
            //       child: const Icon(
            //         Icons.card_membership_rounded,
            //         color: Colors.white,
            //         size: 24,
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Your Membership',
            //           style: TextStyle(
            //             fontSize: 20,
            //             fontWeight: FontWeight.bold,
            //             color: AppColor.black,
            //             fontFamily: 'SFUIText',
            //           ),
            //         ),
            //         Text(
            //           'Exclusive tier benefits',
            //           style: TextStyle(
            //             fontSize: 13,
            //             color: AppColor.black.withOpacity(0.6),
            //             fontFamily: 'SFUIText',
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 24),
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
  final List<Map<String, String>> visitHistory;

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
                          visit['place']!,
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
                              visit['date']!,
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
