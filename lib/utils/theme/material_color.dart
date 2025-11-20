import 'package:flutter/material.dart';

class CustomMaterialColor {
  static MaterialColor generate(int customColor) {
    return MaterialColor(customColor, <int, Color>{
      50: Color(customColor),
      100: Color(customColor),
      200: Color(customColor),
      300: Color(customColor),
      400: Color(customColor),
      500: Color(customColor),
      600: Color(customColor),
      700: Color(customColor),
      800: Color(customColor),
      900: Color(customColor),
    });
  }
}
