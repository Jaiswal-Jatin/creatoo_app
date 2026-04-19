import '../../core.dart';

class AppGradient {
  // gradient: LinearGradient(
//   colors: [Color(0xFFFCBF22), Color(0xFFFFF8E6),AppColor.primary],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
//   stops: [0.0, 0.5, 1],
//   tileMode: TileMode.decal,
// ),

  static RadialGradient scaffoldGradient = RadialGradient(
    center: const Alignment(0.8, -0.6),
    radius: 1.5,
    colors: [
      AppColor.premiumAccent.withOpacity(0.12), // Vibrant but deep glow
      AppColor.premiumBg, // Deep dark background
    ],
    stops: const [0.0, 0.7],
  );

  static RadialGradient onboardingBg = RadialGradient(
    colors: [Color(0xFFFFF8E6), Color(0xFFFCBF22)],
    center: Alignment.bottomLeft,
    radius: 2.9,
    stops: [0.5, 1.0],
    tileMode: TileMode.decal,
  );

  static LinearGradient loginBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColor.bgLightYellow, // Light yellow
      AppColor.bgLightPurple, // Light purple
    ],
  );

  static LinearGradient profileBg = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.1, 1],
    tileMode: TileMode.mirror,
    colors: [
      Color(0xFFF62E8E), // Light yellow
      Color(0xFFAC1AF0), // Light yellow
    ],
  );

  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColor.primary,
      AppColor.primaryLight,
    ],
  );
}
