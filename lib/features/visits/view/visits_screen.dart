import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../resources/color.dart';
import '../../../../utils/ui_config/app_text_style.dart';

class VisitsScreen extends StatelessWidget {
  const VisitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with actual data from your API
    final List<Visit> visits = [
      Visit(
        userName: 'John Doe',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        tier: Tier.gold,
        coins: 150,
      ),
      Visit(
        userName: 'Jane Smith',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        tier: Tier.silver,
        coins: 100,
      ),
      Visit(
        userName: 'Mike Johnson',
        dateTime: DateTime.now(),
        tier: Tier.bronze,
        coins: 50,
      ),
    ];

    // Group visits by date
    final Map<String, List<Visit>> visitsByDate = {};
    for (var visit in visits) {
      final dateKey = DateFormat('EEEE, MMMM d, y').format(visit.dateTime);
      if (!visitsByDate.containsKey(dateKey)) {
        visitsByDate[dateKey] = [];
      }
      visitsByDate[dateKey]!.add(visit);
    }

    // Count users by tier
    final goldCount = visits.where((v) => v.tier == Tier.gold).length;
    final silverCount = visits.where((v) => v.tier == Tier.silver).length;
    final bronzeCount = visits.where((v) => v.tier == Tier.bronze).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tier Summary Cards
            Row(
              children: [
                _buildTierCard(
                  context,
                  'Gold Users',
                  goldCount.toString(),
                  'assets/icons/gold_medal.svg',
                  const Color(0xFFFFD700),
                ),
                const SizedBox(width: 12),
                _buildTierCard(
                  context,
                  'Silver Users',
                  silverCount.toString(),
                  'assets/icons/silver_medal.svg',
                  const Color(0xFFC0C0C0),
                ),
                const SizedBox(width: 12),
                _buildTierCard(
                  context,
                  'Bronze Users',
                  bronzeCount.toString(),
                  'assets/icons/bronze_medal.svg',
                  const Color(0xFFCD7F32),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Visits List
            ...visitsByDate.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      entry.key,
                      style: AppTextStyles.montserratStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.darkGrey,
                      ),
                    ),
                  ),
                  ...entry.value.map((visit) => _buildVisitCard(visit)),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context,
    String title,
    String count,
    String iconPath,
    Color color,
  ) {
    // Determine gradient based on color
    List<Color> gradientColors = [];
    if (color == const Color(0xFFFFD700)) {
      gradientColors = [const Color(0xFFFFF3B0), const Color(0xFFFEDB5F)];
    } else if (color == const Color(0xFFC0C0C0)) {
      gradientColors = [const Color(0xFFF0F0F0), const Color(0xFFC0C0C0)];
    } else {
      gradientColors = [const Color(0xFFF0D9B5), const Color(0xFFCD7F32)];
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SvgPicture.asset(
            //   iconPath,
            //   height: 28,
            //   width: 28,
            //   color: Colors.black87,
            // ),
            const SizedBox(height: 8),
            Text(
              count,
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitCard(Visit visit) {
    final timeFormat = DateFormat('h:mm a');
    
    // Determine gradient based on tier
    List<Color> tierGradient;
    switch (visit.tier) {
      case Tier.gold:
        tierGradient = [const Color(0xFFFFF3B0), const Color(0xFFFEDB5F)];
        break;
      case Tier.silver:
        tierGradient = [const Color(0xFFF0F0F0), const Color(0xFFC0C0C0)];
        break;
      case Tier.bronze:
      default:
        tierGradient = [const Color(0xFFF0D9B5), const Color(0xFFCD7F32)];
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // color: AppColor.moreLighterDd,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Tier indicator with gradient
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: tierGradient,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.userName,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeFormat.format(visit.dateTime),
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Tier badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: tierGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  visit.tier.toString().split('.').last.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(Tier tier) {
    switch (tier) {
      case Tier.gold:
        return const Color(0xFFFFD700); // Gold
      case Tier.silver:
        return const Color(0xFFC0C0C0); // Silver
      case Tier.bronze:
        return const Color(0xFFCD7F32); // Bronze
    }
  }
}

class Visit {
  final String userName;
  final DateTime dateTime;
  final Tier tier;
  final int coins;

  Visit({
    required this.userName,
    required this.dateTime,
    required this.tier,
    required this.coins,
  });
}

enum Tier { gold, silver, bronze }
