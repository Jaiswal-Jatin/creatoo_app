import 'package:flutter/material.dart';
import '../utils/theme/material_color.dart';

class AppColor {
  // Material Colors
  static MaterialColor primary = CustomMaterialColor.generate(0xFF9759C4);
  static MaterialColor primaryDark = CustomMaterialColor.generate(0xFF545454);

  // Primary Colors
  static const Color kPrimary = Color(0xFF9759C4);
  static const Color primaryLight = Color(0xFFE5F8FB);
  static const Color primaryDisabled = Color(0xFFB3A0D4);

  // Basic Colors
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;
  static const Color error = Colors.red;
  static const Color general = Colors.orangeAccent;

  // Grey Scale
  static const Color grey = Color(0xFFB3B3AA);
  static const Color lightGrey = Color(0xFFDADADA);
  static const Color darkGrey = Color(0xFF4A4846);
  static const Color mediumDarkGrey = Color(0xFF3D3D3D);
  static const Color lightButtonGrey = Color(0xFFF6F6F6);
  static const Color darkButtonGrey = Color(0xFFE5E7EB);
  
  // DD Colors
  static const Color dd = Color(0xFF545454);
  static const Color lighterDd = Color(0xFF9C9C9C);
  static const Color moreLighterDd = Color(0xFFC4C4C4);

  // Green Colors
  static const Color green = Color(0xFF008000);
  static const Color rating = Color(0xFF1A663E);
  static const Color openNow = Color(0xFF3E9F55);
  static const Color activeGreen = Color(0xFF27AA1A);
  static const Color referralCard = Color(0xFF42BF42);

  // Yellow/Orange Colors
  static const Color mangoYellow = Color(0xFFFCBF22);
  static const Color bgLightYellow = Color(0xFFFFE082);
  static const Color bgLighterYellow = Color(0xFFFFF0B3);
  static const Color orange = Color(0xFFF58C3F);

  // Purple/Pink Colors
  static const Color bgLightPurple = Color(0xFFE1BEE7);
  static const Color buttonPay = Color(0xFF5D059C);
  static const Color payCard = Color.fromARGB(255, 251, 232, 255);

  // Other Colors
  static const Color scaffoldColor = Color(0xFFCECEFF);
  static const Color darkRed = Color(0xFFDD5050);
  static const Color lightBack = Color(0xFF191D23);
  static const Color cardText = Color(0xFF9B0084EB);

  // Tier Colors
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);



  // Medal Gradients
  static const List<Color> goldGradient = [Color(0xFFF4D98A), Color(0xFFEBCB71)];
  static const List<Color> silverGradient = [Color(0xFFE9E9EC), Color(0xFFC9C9CE)];
  static const List<Color> bronzeGradient = [Color(0xFFE9A171), Color(0xFFC67C4E)];




  // Gradients
  
  // static List<Color> get premiumCardGradient => [
  //   const Color(0xFF2D2D2D),
  //   const Color(0xFF1A1A1A),
  //   const Color(0xFF2B2929).withOpacity(0.7),
  //   const Color(0xFF2D2D2D),
  //   const Color(0xFF2D2D2D),
  // ];



  // static List<Color> premiumCardGradient = [
  //   Color(0xFF2E005C), // Very Dark Purple
  //   Color(0xFF4A0B8A), // Deep Violet
  //   Color(0xFF7C2BC6), // Vivid Purple
  //   Color(0xFF9B47E0), // Medium Lavender
  //   Color(0xFFC27BFF), // Soft Light Purple
  // ];


static List<Color> premiumCardGradient = [
  Color(0xFF3A0070), // Dark Violet
  Color(0xFF5A0FA3), // Royal Purple
  Color(0xFF8B33C9), // Bright Purple
  Color(0xFFBF6BFF), // Pinkish Light Purple
  Color(0xFFF1D7FF), // Very Light Highlight
];



  // Alternative premium gradient with deeper primary shades
  // static List<Color> get premiumCardGradient => [
  //   const Color(0xFF6A2D9A),  // Dark purple
  //   const Color(0xFF7E3FB2),  // Dark primary
  //   const Color(0xFF9759C4),  // Primary color
  //   const Color(0xFFB17FD6),  // Light primary
  //   const Color.fromARGB(255, 214, 186, 235).withOpacity(0.8),  // Subtle highlight
  //   const Color(0xFFB17FD6),  // Light primary
  //   const Color(0xFF9759C4),  // Primary color
  //   const Color(0xFF7E3FB2),  // Dark primary
  //   const Color(0xFF6A2D9A),  // Dark purple
  // ];

}
