import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core.dart'; // Contains AppColor, SizeConfig, AppGradient
import '../view_model/card_view_model.dart';
import '../view_model/card_visit_view_model.dart';
import '../widgets/about_us_tab_view.dart';
import '../widgets/cards_tab_view.dart';
import '../widgets/RecentRestaurantCardPreview.dart';
import '../widgets/visit_tab_view.dart';
import '../widgets/premium_card.dart';
import '../widgets/card_tab_button.dart';
import '../../../widgets/app_text_widget.dart'; // Needed for premium typography

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CardViewModel viewModel;
  late CardVisitViewModel visitViewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    viewModel = Provider.of<CardViewModel>(context, listen: false);
    visitViewModel = Provider.of<CardVisitViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForCard();
      visitViewModel.fetchVisitByRestaurant(token ?? '');
    });
  }

  Future<void> _checkForCard() async {
    await viewModel.checkCard(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await viewModel.checkCard(context);
    await visitViewModel.fetchVisitByRestaurant(token ?? '');
  }

  Widget _buildPremiumHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  text: "CREATOO",
                  fontSize: 11.sp,
                  color: AppColor.premiumAccent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
                SizedBox(height: 2.h),
                AppTextWidget(
                  text: "My Card",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.premiumTextPrimary,
                ),
              ],
            ),
          ),
          if (roleId == Constants.businessUser)
            _buildHeaderIcon(Icons.qr_code_scanner, () {
               Navigator.pushNamed(context, RoutesName.qrScannerView);
            }),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColor.premiumTextPrimary, size: 20.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: false,
      backgroundColor: Colors.transparent, // Inherit Exact HomePage Global Background
      isSafe: false,
      body: Container(
         width: double.infinity,
         padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h),
         child: RefreshIndicator(
          color: AppColor.premiumAccent,
          backgroundColor: AppColor.premiumCardBg,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPremiumHeader(),
                  SizedBox(height: 15.h),
                  
                  // Premium Glass Card Design
                  Consumer<CardViewModel>(
                    builder: (context, cardViewModel, child) {
                      return PremiumGlassCard(
                        initialUserName: cardViewModel.cardData?.name,
                        initialCardNumber: cardViewModel.cardData?.cardNumber,
                        initialIsCardActive:
                            cardViewModel.cardData?.status == 'active',
                      );
                    },
                  ),
                  Consumer<CardVisitViewModel>(
                    builder: (context, visitViewModel, child) {
                      final recentVisit = visitViewModel.getMostRecentVisit();

                      // Hide if there's no recent visit or if it's older than 2 hours
                      if (recentVisit == null ||
                          DateTime.now().difference(recentVisit.date).inHours >=
                              2) {
                        return const SizedBox
                            .shrink(); // Show nothing if no recent visit
                      }

                      // Show the card if the visit is within the last 2 hours
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: AppTextWidget(
                              text: 'Recent Activity',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.premiumTextPrimary,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          RecentRestaurantCard(
                            name: recentVisit.restaurantName,
                            dateTime: recentVisit.date,
                            tier: recentVisit.tier,
                            imageUrl: recentVisit.imageUrl,
                            businessId: recentVisit.businessId,
                            onTap: () {
                              if (recentVisit.businessId != null) {
                                Navigator.pushNamed(
                                  context,
                                  RoutesName.businessDescriptionView,
                                  arguments: recentVisit.businessId,
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 25.h),

                  // Tabs Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        CardTabButton(
                          text: 'Cards',
                          isSelected: _tabController.index == 0,
                          onTap: () => _tabController.index = 0,
                        ),
                        SizedBox(width: 8.w),
                        CardTabButton(
                          text: 'Visit',
                          isSelected: _tabController.index == 1,
                          onTap: () => _tabController.index = 1,
                        ),
                        SizedBox(width: 8.w),
                        CardTabButton(
                          text: 'About Us',
                          isSelected: _tabController.index == 2,
                          onTap: () => _tabController.index = 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Tab Bar View
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Consumer<CardViewModel>(
                      builder: (context, cardViewModel, child) {
                        final isCardActive =
                            cardViewModel.cardData?.status == 'active';

                        return TabBarView(
                          controller: _tabController,
                          children: [
                            CardsTabView(isCardActive: isCardActive),
                            VisitTabView(isCardActive: isCardActive),
                            AboutUsTabView(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
