import 'package:flutter/material.dart';
import 'package:creatoo/core.dart'; // For AppColor
import '../widgets/card_tier_section.dart'; // Import the new widget

class CardsTabView extends StatelessWidget {
  const CardsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        children: [
          CardTierSection(
            tierName: 'Golden Tier',
            tierColor: AppColor.gold,
            visitsCount: 15, // Example data
          ),
          CardTierSection(
            tierName: 'Silver Tier',
            tierColor: AppColor.silver,
            visitsCount: 8, // Example data
          ),
          CardTierSection(
            tierName: 'Bronze Tier',
            tierColor: AppColor.bronze,
            visitsCount: 3, // Example data
          ),
        ],
      ),
    );
  }
}
