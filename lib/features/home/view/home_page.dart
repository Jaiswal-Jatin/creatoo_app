import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter/services.dart';
import 'dart:ui';



import '../../../core.dart';
import '../../card/view/card_screen.dart';
import '../../creator_wallet/view/creator_wallet_view.dart';
import '../../search/view/search_view.dart';
import '../../settings/view/settings_view.dart';
import '../../visits/view/visits_screen.dart';
import '../../wallet/view/wallet_view.dart';
import '../view_model/home_view_model.dart';
import 'home_view.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel viewModel;
  Upgrader _upgrader = Upgrader();

  @override
  void initState() {
    super.initState();
    Upgrader.clearSavedSettings();

    final upgrader = Upgrader();
    upgrader.initialize();

    _upgrader = upgrader;
  }

  @override
  Widget build(BuildContext context) {
    viewModel = context.watch<HomeViewModel>();

    List<Widget> _widgetOptions = roleId == Constants.businessUser
        ? [
            const HomeView(),
            const VisitsScreen(), // Replaced CardScreen with VisitsScreen
            WalletView(),
            SettingsView(),
          ]
        : [
            const HomeView(),
            const SearchView(),
            const CardScreen(),
            CreatorWalletView(
              key: creatorWalletKey,
              index: viewModel.creatooView ? 1 : 0,
            ),
            SettingsView(),
          ];

    return PopScope(
      canPop: (viewModel.selectedIndex == 0),
      onPopInvoked: (didPop) async {
        if (viewModel.selectedIndex != 0) {
          viewModel.changeIndex(0, false);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.6),
            radius: 1.5,
            colors: [
              AppColor.premiumAccent.withOpacity(0.12), // Vibrant but deep
              AppColor.premiumBg,
            ],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent, // Background comes from Container
          resizeToAvoidBottomInset: true,
          extendBody: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          body: UpgradeAlert(
            upgrader: _upgrader,
            dialogStyle: UpgradeDialogStyle.material,
            showIgnore: false,
            showLater: false,
            barrierDismissible: false,
            shouldPopScope: () => false,
            child: _widgetOptions[viewModel.selectedIndex],
            cupertinoButtonTextStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: AppColor.premiumAccent,
            ),
          ),
          bottomNavigationBar: _buildAnimatedNavBar(context),
        ),
      ),
    );
  }

  Widget _buildAnimatedNavBar(BuildContext context) {
    final int itemCount = roleId == Constants.businessUser ? 4 : 5;
    final double barWidth = SizeConfig.screenWidth * 0.92;
    final double itemWidth = barWidth / itemCount;
    
    return Container(
      color: Colors.transparent, 
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Background Blur Layer
          Padding(
            padding: EdgeInsets.only(
              left: SizeConfig.screenWidth * 0.02,
              right: SizeConfig.screenWidth * 0.02,
              bottom: 12.h,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 95.h,
                  width: SizeConfig.screenWidth * 0.96,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),
          ),
          
          // 2. Glassmorphic Nav Bar (See-through)
          Container(
            margin: EdgeInsets.only(
              left: SizeConfig.screenWidth * 0.04,
              right: SizeConfig.screenWidth * 0.04,
              bottom: 24.h,
            ),
            height: 72.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.premiumCardBg.withOpacity(0.55), // Glassmorphic transparency
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(

              children: [
                // Premium Glowing Circle Highlight (Centered vertically)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  left: viewModel.selectedIndex * itemWidth + (itemWidth - 62.h) / 2,
                  top: 5.h,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 62.h,
                    height: 62.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColor.premiumAccent.withOpacity(0.6),
                          AppColor.premiumAccent.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.premiumAccent.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Interaction Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildNavItem(0, AppIcon.home, "Home", isSvg: true),
                    
                    if (roleId == Constants.creatorUser) 
                      _buildNavItem(1, AppIcon.search, "Search", isSvg: true)
                    else
                      _buildNavItem(1, AppIcon.calender, "Visits", isSvg: true),
                    
                    if (roleId == Constants.creatorUser)
                      _buildNavItem(2, AppIcon.creditCard, "Card", isSvg: false),
                    
                    _buildNavItem(
                      roleId == Constants.creatorUser ? 3 : 2, 
                      AppIcon.wallet, 
                      "Wallet", 
                      isSvg: true
                    ),
                    
                    _buildNavItem(
                      roleId == Constants.creatorUser ? 4 : 3, 
                      AppIcon.profile, 
                      "Profile", 
                      isSvg: true
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      )]));
  }


  Widget _buildNavItem(int index, String iconPath, String name, {bool isSvg = true}) {
    final bool isSelected = viewModel.selectedIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            HapticFeedback.mediumImpact();
            viewModel.changeIndex(index, index == (roleId == Constants.creatorUser ? 3 : 2));
          }
        },
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: isSelected ? 1.25 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon (Always centered in the column/circle)
              isSvg
                  ? SvgPicture.asset(
                      iconPath,
                      height: 24.h,
                      width: 24.w,
                      color: isSelected ? AppColor.white : AppColor.premiumTextSecondary.withOpacity(0.7),
                    )
                  : Image.asset(
                      iconPath,
                      height: 24.h,
                      width: 24.w,
                      color: isSelected ? AppColor.white : AppColor.premiumTextSecondary.withOpacity(0.7),
                    ),
              
              if (isSelected)
                // Small indicator line below the icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(top: 4.h),
                  height: 2.5.h,
                  width: 14.w,
                  decoration: BoxDecoration(
                    color: AppColor.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.white.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    SizedBox(height: 4.h),
                    AppTextWidget(
                      text: name,
                      fontSize: 10.sp,
                      color: AppColor.premiumTextSecondary.withOpacity(0.7),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
