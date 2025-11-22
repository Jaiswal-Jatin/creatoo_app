import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core.dart'; // Contains AppColor, SizeConfig, AppGradient
import '../view_model/card_view_model.dart';
import 'about_us_tab_view.dart';
import 'cards_tab_view.dart';
import 'visit_tab_view.dart';
import 'package:animated_button/animated_button.dart';
import '../widgets/activate_card_modal.dart';
import '../widgets/premium_card.dart'; // New widget for the modal

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

          SizedBox(height: 20.h),

          // Tabs Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFF2D2D2D), // Active tab color
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal),
              tabs: const [
                Tab(text: 'Cards'),
                Tab(text: 'Visit'),
                Tab(text: 'About Us'),
              ],
            ),
          ),
          SizedBox(height: 15.h),

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

  void _showActivateCardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparent,
      builder: (context) {
        return ActivateCardModal();
      },
    );
  }
}
