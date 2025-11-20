import 'package:creatoo/core.dart';

class AppTextStyles {
  // Title style
  static TextStyle title = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle appBarTitleTextStyle = GoogleFonts.montserrat(
    textStyle: Theme.of(navigatorKey.currentContext!).textTheme.displayLarge,
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle appBarSubtitleTextStyle = GoogleFonts.montserrat(
    textStyle: Theme.of(navigatorKey.currentContext!).textTheme.displayMedium,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade600, // Adjust color as needed
  );

  static TextStyle formHeaderStyle({FontWeight fontWeight = FontWeight.w400, double fontSize = 15}) {
    return GoogleFonts.montserrat(
      textStyle: Theme.of(navigatorKey.currentContext!).textTheme.displayLarge,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    );
  }

  static TextStyle montserratStyle({FontWeight fontWeight = FontWeight.w500, double fontSize = 14, Color? color}) {
    return GoogleFonts.montserrat(
      textStyle: Theme.of(navigatorKey.currentContext!).textTheme.displayLarge,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle header = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
  );

  // Subtitle style
  static TextStyle subtitle = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );

  // Body text style
  static TextStyle body({FontWeight fontWeight = FontWeight.w400, double fontSize = 16, Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Caption style
  static TextStyle caption = TextStyle(
    fontSize: 14.sp,
  );

  // Button text style
  static TextStyle button = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Error text style
  static TextStyle error = TextStyle(
    fontSize: 14.sp,
    color: Colors.red,
  );

  // Custom style example
  static TextStyle customStyle = TextStyle(
    fontSize: 20.sp,
    fontStyle: FontStyle.italic,
    letterSpacing: 1.2,
    color: Colors.blue,
  );
}
