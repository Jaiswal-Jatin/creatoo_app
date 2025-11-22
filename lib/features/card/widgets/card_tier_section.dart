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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter),
      'textColor': Colors.black87,
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter),
      'textColor': Colors.black87,
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter),
      'textColor': Colors.black,
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
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: List.generate(_tiers.length, (index) {
            final tier = _tiers[index];
            return TierCard(
              tierName: tier['name'],
              visits: tier['visits'],
              gradient: tier['gradient'],
              textColor: tier['textColor'],
              isExpanded: _expandedIndex == index,
              onTap: () => _toggleExpand(index),
              visitHistory: tier['history'],
            );
          }),
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
  final bool isExpanded;
  final VoidCallback onTap;
  final List<Map<String, String>> visitHistory;

  const TierCard({
    super.key,
    required this.tierName,
    required this.visits,
    required this.gradient,
    required this.textColor,
    required this.isExpanded,
    required this.onTap,
    required this.visitHistory,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: AppColor.lightGrey),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tierName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontFamily: 'SFUIText',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Your total Visits: $visits',
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor.withOpacity(0.8),
                              fontFamily: 'SFUIText',
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 32,
                        color: textColor,
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: Container(),
                    secondChild: _buildVisitHistory(),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 350),
                  ),
                ],
              ),
            ),
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
          Divider(color: textColor.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text(
            'Visit History:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'SFUIText',
            ),
          ),
          const SizedBox(height: 10),
          ...visitHistory.map(
            (visit) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on, color: textColor),
              title: Text(
                visit['place']!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                visit['date']!,
                style: TextStyle(color: textColor.withOpacity(0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
