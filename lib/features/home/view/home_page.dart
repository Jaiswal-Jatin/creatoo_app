import 'package:upgrader/upgrader.dart';

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
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
            color: AppColor.primary,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: -10.0,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            height: kBottomNavigationBarHeight + 16,
            child: Column(
              children: [
                AnimatedAlign(
                  alignment: _getAlignment(viewModel.selectedIndex),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 2),
                    width: roleId == Constants.businessUser ? SizeConfig.screenWidth / 4 : SizeConfig.screenWidth / 5, // Adjusted width for business user tabs
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // Home button
                      Expanded(child: buildGestureDetector(context, 0, AppIcon.home, "Home", isSvg: true)),
                      
                      // For Creator: Search, For Business: Visits
                      if (roleId == Constants.creatorUser) 
                        Expanded(child: buildGestureDetector(context, 1, AppIcon.search, "Search", isSvg: true))
                      else
                        Expanded(child: buildGestureDetector(context, 1, AppIcon.calender, "Visits", isSvg: true)),
                      
                      // Card button (only for creator)
                      if (roleId == Constants.creatorUser)
                        Expanded(child: buildGestureDetector(context, 2, AppIcon.creditCard, "Card", isSvg: false)),
                      
                      // Wallet button
                      Expanded(child: buildGestureDetector(
                        context, 
                        roleId == Constants.creatorUser ? 3 : 2, 
                        AppIcon.wallet, 
                        "Wallet", 
                        isSvg: true
                      )),
                      
                      // Profile button
                      Expanded(child: buildGestureDetector(
                        context, 
                        roleId == Constants.creatorUser ? 4 : 3, 
                        AppIcon.profile, 
                        "Profile", 
                        isSvg: true
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(int selectedIndex) {
    if (roleId == Constants.businessUser) {
      // Business user with 4 items: Home, Visits, Wallet, Profile
      // For 4 items, indicator width is 1/4 of screen
      // Alignment -1 = left edge at 0%, Alignment 1 = right edge at 100%
      if (selectedIndex == 0) return Alignment(-1, 0); // Home
      if (selectedIndex == 1) return Alignment(-0.333, 0); // Visits
      if (selectedIndex == 2) return Alignment(0.333, 0); // Wallet
      if (selectedIndex == 3) return Alignment(1, 0); // Profile
    } else {
      // Creator user with 5 items: Home, Search, Card, Wallet, Profile
      // For 5 items, indicator width is 1/5 of screen
      if (selectedIndex == 0) return Alignment(-1, 0); // Home
      if (selectedIndex == 1) return Alignment(-0.5, 0); // Search
      if (selectedIndex == 2) return Alignment(0, 0); // Card
      if (selectedIndex == 3) return Alignment(0.5, 0); // Wallet
      if (selectedIndex == 4) return Alignment(1, 0); // Profile
    }
    return Alignment(1, 0); // Default
  }

  InkWell buildGestureDetector(BuildContext context, int index, String iconPath, String name, {bool isSvg = true}) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    return InkWell(
      onTap: () => homeViewModel.changeIndex(index, index == (roleId == Constants.creatorUser ? 3 : 2)), // Adjust index for wallet
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        // Removed fixed width, Expanded will handle it
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isSvg
                ? SvgPicture.asset(
                    iconPath,
                    height: 24.h, // Match the height of image icons
                    width: 24.w,  // Match the width of image icons
                    color: homeViewModel.selectedIndex == index ? AppColor.primary : AppColor.black,
                  )
                : Image.asset(
                    iconPath,
                    height: 24.h, // Match the height of SVG icons
                    width: 24.w,  // Match the width of SVG icons
                    color: homeViewModel.selectedIndex == index ? AppColor.primary : AppColor.black,
                  ),
            Text(
              name,
              style: TextStyle(
                fontSize: 12.sp,
                color: homeViewModel.selectedIndex == index ? AppColor.primary : AppColor.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
