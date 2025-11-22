import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core.dart'; // Contains AppColor, SizeConfig, AppGradient
import '../view_model/card_view_model.dart';
import '../widgets/about_us_tab_view.dart';
import '../widgets/cards_tab_view.dart';
import '../widgets/visit_tab_view.dart';
import 'package:animated_button/animated_button.dart';
import '../widgets/activate_card.dart';
import '../widgets/premium_card.dart'; // New widget for the modal
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
          PremiumGlassCard(),

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
