import 'package:upgrader/upgrader.dart';

import '../../../core.dart';
import '../../creator_wallet/view/creator_wallet_view.dart';
import '../../search/view/search_view.dart';
import '../../settings/view/settings_view.dart';
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
            WalletView(),
            SettingsView(),
          ]
        : [
            const HomeView(),
            const SearchView(),
            // CategoryView(),
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
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: _getAlignment(viewModel.selectedIndex),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 70),
                    width: roleId == Constants.businessUser ? SizeConfig.screenWidth / 3 : SizeConfig.screenWidth / 4,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildGestureDetector(context, 0, AppIcon.home, "Home"),
                    if (roleId == Constants.creatorUser) buildGestureDetector(context, 1, AppIcon.search, "Search"),
                    // if (roleId == Constants.creatorUser) buildGestureDetector(context, 2, AppIcon.category, "Category"),
                    if (roleId == Constants.creatorUser)
                      buildGestureDetector(context, 2, AppIcon.wallet, "Wallet")
                    else
                      buildGestureDetector(context, 1, AppIcon.wallet, "Wallet"),
                    if (roleId == Constants.creatorUser)
                      buildGestureDetector(context, 3, AppIcon.profile, "Profile")
                    else
                      buildGestureDetector(context, 2, AppIcon.profile, "Profile"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(int selectedIndex) {
    if (selectedIndex == 0) return Alignment(-1, 0);
    if (selectedIndex == 1) return roleId == Constants.creatorUser ? Alignment(-0.3, 0) : Alignment(0, 0);
    if (selectedIndex == 2) return roleId == Constants.creatorUser ? Alignment(0.3, 0) : Alignment(1, 0);
    if (roleId == Constants.creatorUser && selectedIndex == 3) return Alignment(1, 0);
    return Alignment(1, 0);
  }

  InkWell buildGestureDetector(BuildContext context, int index, String iconPath, String name) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    return InkWell(
      onTap: () => homeViewModel.changeIndex(index, index == 2),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        width: (roleId == Constants.creatorUser) ? 60.w : 80.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset(
              iconPath,
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
