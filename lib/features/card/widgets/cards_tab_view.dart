import 'package:flutter/material.dart';
import 'card_tier_section.dart'; // Import the new widget

class CardsTabView extends StatelessWidget {
  final bool isCardActive;

  const CardsTabView({super.key, required this.isCardActive});

  @override
  Widget build(BuildContext context) {
    return CardTierSection(isCardActive: isCardActive);
  }
}
