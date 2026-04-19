import 'package:flutter/services.dart';

import '../../core.dart';

class AppTheme {
  static ThemeData get lightTheme => _lightThemeData;

  // static ThemeData get darkTheme => _darkThemeData;

  static final _lightThemeData = _getThemeData(AppColor.primary, Brightness.light, AppColor.black);

  // static final _darkThemeData = _getThemeData(AppColor.primaryDark);

  static ThemeData _getThemeData(MaterialColor color, Brightness brightness, Color textColor) {
    return ThemeData(
      useMaterial3: false,
      // primaryColor: AppColor.kPrimary,
      primarySwatch: color,
      brightness: brightness,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      fontFamilyFallback: [Constants.sfUIText],
      scaffoldBackgroundColor: AppColor.premiumBg,
      // textTheme: TextTheme(
      //   displayLarge: AppTextStyles.title.copyWith(color: textColor),
      //   displayMedium: AppTextStyles.title.copyWith(color: textColor),
      //   displaySmall: AppTextStyles.title.copyWith(color: textColor),
      //   headlineMedium: AppTextStyles.title.copyWith(color: textColor),
      //   headlineSmall: AppTextStyles.title.copyWith(color: textColor),
      //   titleLarge: AppTextStyles.title.copyWith(color: textColor),
      //   titleMedium: AppTextStyles.body().copyWith(color: textColor),
      //   titleSmall: AppTextStyles.body().copyWith(color: textColor),
      //   bodyLarge: AppTextStyles.body().copyWith(color: textColor),
      //   bodyMedium: AppTextStyles.body().copyWith(color: textColor),
      //   bodySmall: AppTextStyles.body().copyWith(color: textColor),
      //   labelLarge: AppTextStyles.body().copyWith(color: textColor),
      //   labelSmall: AppTextStyles.body().copyWith(color: textColor),
      // ),
      textTheme: GoogleFonts.montserratTextTheme(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(color: textColor),
        toolbarTextStyle: AppTextStyles.title.copyWith(color: textColor),
        iconTheme: IconThemeData(color: textColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.light ? AppColor.white : AppColor.black,
        elevation: 0,
        shadowColor: AppColor.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }
}
