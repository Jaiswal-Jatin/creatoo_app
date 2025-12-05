import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core.dart'; // Contains AppColor, SizeConfig, AppGradient
import '../view_model/card_view_model.dart';
import '../view_model/card_visit_view_model.dart';
import '../widgets/about_us_tab_view.dart';
import '../widgets/cards_tab_view.dart';
import '../widgets/RecentRestaurantCardPreview.dart';
import '../widgets/visit_tab_view.dart';
import '../widgets/premium_card.dart' hide AppColor;
import '../widgets/card_tab_button.dart';


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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Card'),
        backgroundColor: AppColor.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Premium Glass Card Design
          Consumer<CardViewModel>(
            builder: (context, cardViewModel, child) {
              return PremiumGlassCard(
                initialUserName: cardViewModel.cardData?.name,
                initialCardNumber: cardViewModel.cardData?.cardNumber,
                initialIsCardActive: cardViewModel.cardData?.status == 'active',
              );
            },
          ),
          Consumer<CardVisitViewModel>(
            builder: (context, visitViewModel, child) {
              final recentVisit = visitViewModel.getMostRecentVisit();

              // Hide if there's no recent visit or if it's older than 2 hours
              if (recentVisit == null ||
                  DateTime.now().difference(recentVisit.date).inHours >= 2) {
                return const SizedBox.shrink(); // Show nothing if no recent visit
              }

              // Show the card if the visit is within the last 2 hours
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text('Recent Restaurant',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  ),
                  RecentRestaurantCard(
                    name: recentVisit.restaurantName,
                    dateTime: recentVisit.date,
                    tier: recentVisit.tier,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 25.h),

          // Tabs Section
          Padding(
            padding: EdgeInsets.only(left: 20.w),
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
          SizedBox(height: 5.h),

          // Tab Bar View
          Expanded(
            child: Consumer<CardViewModel>(
              builder: (context, cardViewModel, child) {
                final isCardActive = cardViewModel.cardData?.status == 'active';
                
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
    );
  }
}
