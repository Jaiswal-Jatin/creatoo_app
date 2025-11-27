import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core.dart'; // Contains AppColor, SizeConfig, AppGradient
import '../view_model/card_view_model.dart';
import '../widgets/about_us_tab_view.dart';
import '../widgets/cards_tab_view.dart';
import '../widgets/visit_tab_view.dart';
import '../widgets/premium_card.dart' hide AppColor; // New widget for the modal
import '../widgets/card_tab_button.dart';
import 'package:creatoo/data/services/shared_preference_service.dart'; // Import to get user data

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CardViewModel viewModel;
  String? _userName;
  String? _cardNumber;
  bool _isCardActive = false;

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
    _loadInitialCardData();
    // Defer the call to _checkForCard to avoid setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForCard();
    });
  }

  Future<void> _checkForCard() async {
    await viewModel.checkCard(context);
    if (mounted) {
      setState(() {
        if (viewModel.cardData != null) {
          _cardNumber = viewModel.cardData!.cardNumber;
          _userName = viewModel.cardData!.name;
          _isCardActive = viewModel.cardData!.status == 'active';
        }
      });
    }
  }

  Future<void> _loadInitialCardData() async {
    final userData = await SharedPreferencesService().getUserData();
    if (userData != null && mounted) {
      setState(() {
        _userName = userData.name;
      });
    }
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
                userName: cardViewModel.cardData?.name,
                cardNumber: cardViewModel.cardData?.cardNumber,
                isCardActive: cardViewModel.cardData?.status == 'active',
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
            child: TabBarView(
              controller: _tabController,
              children: [
                CardsTabView(),
                VisitTabView(),
                AboutUsTabView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
