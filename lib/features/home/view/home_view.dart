import 'package:flutter/material.dart';
import 'package:creatoo/features/home/model/home_screen_response_model.dart';
import 'dart:developer';
import '../../../core.dart';
import '../../../widgets/app_dialog.dart';
import '../../creator_wallet/view_model/creator_wallet_view_model.dart';
import '../../wallet/view/business_wallet_view.dart';
import '../view_model/home_view_model.dart';
import '../../search/view_model/search_view_model.dart';
import '../../booking/view_model/booking_view_model.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeViewModel viewModel;
  bool hasNewNotification = true;
  int _businessCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<HomeViewModel>(context, listen: false);
    if (viewModel.homeResponse.status != Status.completed) {
      viewModel.init();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchVM = Provider.of<SearchViewModel>(context, listen: false);
      searchVM.preloadCategory('restaurant');
      searchVM.preloadCategory('salon');
      searchVM.preloadCategory('turf');
      if (roleId == Constants.businessUser) {
        Provider.of<BookingViewModel>(context, listen: false).loadBusinessBookings();
      }
    });
  }

  void clearNewNotificationFlag() {
    setState(() {
      hasNewNotification = false;
    });
  }

  Map<String, dynamic> _getBusinessTheme(Business item) {
    final category = item.businessCategory?.toLowerCase() ?? "";
    if (category == "salon") {
      return {"icon": Icons.content_cut, "color": Color(0xFFE91E63)};
    }
    if (category == "turf") {
      return {"icon": Icons.sports_soccer, "color": Color(0xFF4CAF50)};
    }
    if (category == "restaurant") {
      return {"icon": Icons.restaurant, "color": Color(0xFFFF5722)};
    }

    // Default fallback for businesses without a category set
    return {"icon": Icons.store_rounded, "color": Color(0xFF7C4DFF)};
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<HomeViewModel>(context);
    switch (viewModel.homeResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.homeResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    final w = MediaQuery.of(navigatorKey.currentContext!).size.width;
    final h = MediaQuery.of(navigatorKey.currentContext!).size.height;
    final isSmall = h < 700;
    final bool isBusiness = roleId == Constants.businessUser;

    return AppScaffold(
      useGradient: false,
      backgroundColor: Colors.transparent,
      extendBody: true,
      isSafe: false,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h),
        child: SingleChildScrollView(
          child: isBusiness ? _buildBusinessHomeBody() : _buildCreatorHomeBody(),
        ),
      ),
    );
  }


  Widget _buildCreatorHomeBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPremiumHeader(),
        SizedBox(height: 12.h),
        SizedBox(height: 15.h),
        _buildCategoryFilters(),
        SizedBox(height: 15.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 17.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 72, child: _buildWalletBalanceCard()),
              SizedBox(width: 12.w),
              Expanded(
                flex: 28,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSidebarAction(
                      title: "Scan",
                      icon: Icons.qr_code_scanner,
                      color: Color(0xFF9759C4),
                      onTap: () => Navigator.pushNamed(context, RoutesName.qrScannerView),
                    ),
                    SizedBox(height: 12.h),
                    _buildSidebarAction(
                      title: "Card",
                      icon: Icons.credit_card,
                      color: Color(0xFF2196F3),
                      onTap: () => Navigator.pushNamed(context, RoutesName.cardView),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        // if (viewModel.homeResponse.data!.data!.topReviewers!.isNotEmpty)
        //   buildReviewers(
        //       name: "Top Reviewers",
        //       data: viewModel.homeResponse.data!.data!.topReviewers!),
        _buildCombinedBusinessSection(),
        if (viewModel.homeResponse.data!.data!.newCreator!.isNotEmpty)
          buildUser(
              name: "Recently Joined",
              data: viewModel.homeResponse.data!.data!.newCreator!),
        SizedBox(height: 100.h),
      ],
    );
  }

  Widget _buildBusinessHomeBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPremiumHeader(),
        SizedBox(height: 16.h),
        _buildBusinessDashboard(),
        SizedBox(height: 100.h),
      ],
    );
  }

  Widget _buildBusinessDashboard() {
    final stats = viewModel.businessDashboardStats;
    final isLoading = viewModel.isDashboardStatsLoading;
    final pendingBookings = Provider.of<BookingViewModel>(context).pendingBookingsCount;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Today's Total Revenue (Big Hero Card with Gradient) ───
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF26278D), Color(0xFF1E1F66)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(9.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.trending_up_rounded, color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S TOTAL REVENUE",
                        style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                      ),
                      SizedBox(height: 2.h),
                      isLoading
                          ? Container(height: 18.h, width: 80.w, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)))
                          : Text(
                              currencyFormat.format(stats?.dailyTotalRevenue ?? 0),
                              style: GoogleFonts.montserrat(fontSize: 20.sp, color: Color(0xFF4CAF50), fontWeight: FontWeight.w800),
                            ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Month',
                      style: GoogleFonts.montserrat(fontSize: 9.sp, color: Colors.white60),
                    ),
                    SizedBox(height: 2.h),
                    isLoading
                        ? Container(height: 14.h, width: 60.w, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)))
                        : Text(
                            currencyFormat.format(stats?.monthlyTotalRevenue ?? 0),
                            style: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // ─── Today's Breakdown (Unified Card) ───
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColor.premiumCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: "Bill Payments",
                        value: isLoading ? null : currencyFormat.format(stats?.dailyBillRevenue ?? 0),
                        icon: Icons.receipt_long_rounded,
                        color: Color(0xFF9759C4),
                        isLoading: isLoading,
                      ),
                    ),
                    Container(height: 40.h, width: 1, color: Colors.white.withOpacity(0.08)), // Vertical Divider
                    Expanded(
                      child: _buildStatItem(
                        label: "Booking Amount",
                        value: isLoading ? null : currencyFormat.format(stats?.dailyBookingRevenue ?? 0),
                        icon: Icons.calendar_today_rounded,
                        color: Color(0xFFFF9800),
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.white.withOpacity(0.08), height: 24.h), // Horizontal Divider
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: "Today's Visits",
                        value: isLoading ? null : '${stats?.todayVisitCount ?? 0}',
                        icon: Icons.people_alt_rounded,
                        color: Color(0xFF2196F3),
                        isLoading: isLoading,
                      ),
                    ),
                    Container(height: 40.h, width: 1, color: Colors.white.withOpacity(0.08)), // Vertical Divider
                    Expanded(
                      child: _buildStatItem(
                        label: 'Pending Bookings',
                        value: '$pendingBookings',
                        icon: Icons.pending_actions_rounded,
                        color: Color(0xFFE91E63),
                        isLoading: false,
                        badgeAlert: pendingBookings > 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // ─── Quick Actions ───
          Row(
            children: [
              _buildBusinessAction(
                title: "Show QR",
                icon: Icons.qr_code_2_rounded,
                color: Color(0xFF9759C4),
                onTap: () {
                  if (viewModel.isSubscriptionLocked) { AppDialog.showSubscriptionRequiredDialog(); return; }
                  Navigator.pushNamed(context, RoutesName.businessQrView, arguments: {
                    'businessId': userId ?? 0,
                    'businessName': viewModel.user?.name ?? 'Business',
                  });
                },
              ),
              SizedBox(width: 10.w),
              if (['restaurant', 'salon', 'turf'].contains(viewModel.businessCategory)) ...[
                _buildBusinessAction(
                  title: "Visits",
                  icon: Icons.history_rounded,
                  color: Color(0xFF2196F3),
                  onTap: () {
                    if (viewModel.isSubscriptionLocked) { AppDialog.showSubscriptionRequiredDialog(); return; }
                    Provider.of<HomeViewModel>(context, listen: false).changeIndex(1, false);
                  },
                ),
                SizedBox(width: 10.w),
              ],
              _buildBusinessAction(
                title: "Bookings",
                icon: Icons.calendar_month_rounded,
                color: Color(0xFFFF9800),
                badgeCount: pendingBookings,
                onTap: () {
                  if (viewModel.isSubscriptionLocked) { AppDialog.showSubscriptionRequiredDialog(); return; }
                  Provider.of<HomeViewModel>(context, listen: false).changeIndex(2, false);
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ─── Recent Payments ───
          if (!isLoading && (stats?.recentPayments.isNotEmpty ?? false)) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Payments',
                  style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColor.premiumTextPrimary),
                ),
                GestureDetector(
                  onTap: () => Provider.of<HomeViewModel>(context, listen: false).changeIndex(3, true),
                  child: Text(
                    'See all',
                    style: GoogleFonts.montserrat(fontSize: 12.sp, color: AppColor.premiumAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ...stats!.recentPayments.take(3).map((p) => _buildRecentPaymentTile(p, currencyFormat)),
          ],

          if (isLoading) ...[
            Text(
              'Recent Payments',
              style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColor.premiumTextPrimary),
            ),
            SizedBox(height: 8.h),
            ...List.generate(3, (_) => _buildPaymentTileShimmer()),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    String? value,
    required IconData icon,
    required Color color,
    required bool isLoading,
    bool badgeAlert = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(fontSize: 11.sp, color: AppColor.premiumTextSecondary, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          isLoading
              ? Container(height: 16.h, width: 60.w, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)))
              : Text(
                  value ?? '-',
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: badgeAlert ? Color(0xFFE91E63) : AppColor.premiumTextPrimary,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRecentPaymentTile(dynamic p, NumberFormat fmt) {
    final isConfirmed = p.status == 'CONFIRMED';
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w, height: 38.w,
            decoration: BoxDecoration(
              color: Color(0xFF26278D).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (p.userName?.isNotEmpty == true ? p.userName![0].toUpperCase() : '?'),
                style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Color(0xFF9759C4)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.userName ?? 'Customer',
                  style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColor.premiumTextPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  p.paymentMethod == 'WALLET' ? 'Wallet Payment' : 'Bill Payment',
                  style: GoogleFonts.montserrat(fontSize: 11.sp, color: AppColor.premiumTextSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmt.format(p.finalAmount),
                style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Color(0xFF4CAF50)),
              ),
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isConfirmed ? Color(0xFF4CAF50).withOpacity(0.12) : Color(0xFFFF9800).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isConfirmed ? 'Paid' : 'Pending',
                  style: GoogleFonts.montserrat(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: isConfirmed ? Color(0xFF4CAF50) : Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTileShimmer() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(width: 38.w, height: 38.w, decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12.h, width: 100.w, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4))),
                SizedBox(height: 6.h),
                Container(height: 10.h, width: 70.w, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
          Container(height: 16.h, width: 50.w, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }

  Widget _buildCategoryDashboardSection() {
    final category = viewModel.businessCategory?.toLowerCase() ?? '';
    if (category != 'salon' && category != 'turf') return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category == 'salon' ? Icons.content_cut : Icons.sports_soccer, color: AppColor.premiumAccent, size: 18.sp),
              SizedBox(width: 10.w),
              Text(
                "Manage ${category == 'salon' ? 'Salon Services' : 'Turf Services'}",
                style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, RoutesName.editBusinessProfile, arguments: "Services"),
              icon: Icon(Icons.add_circle_outline, color: AppColor.premiumAccent, size: 18.sp),
              label: Text(
                "Add / Edit Services",
                style: GoogleFonts.montserrat(fontSize: 13.sp, color: AppColor.premiumAccent, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColor.premiumCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.premiumTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                top: -4.h,
                right: -4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColor.premiumAccent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.premiumAccent.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Text(
                    '$badgeCount',
                    style: GoogleFonts.montserrat(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSearch() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColor.premiumTextSecondary, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: AppTextWidget(
              text: "Search for 'Ek Din'",
              fontSize: 14.sp,
              color: AppColor.premiumTextSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCategoryPills() {
    final categories = ["For you", "Dining", "Events", "Movies", "Stores"];
    return Container(
      height: 40.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 17.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 0; // Defaulting first to isSelected per image
          return Container(
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.premiumAccent.withOpacity(0.8) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: AppTextWidget(
                text: categories[index],
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColor.premiumTextSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white.withOpacity(0.2), thickness: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: AppTextWidget(
              text: title.toUpperCase(),
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.premiumTextSecondary,
              letterSpacing: 2.0,
            ),
          ),
          Expanded(child: Divider(color: Colors.white.withOpacity(0.2), thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildCombinedBusinessSection() {
    // Consolidation: Combine Top and New businesses (deduplicated by id)
    final seen = <int>{};
    final List<Business> allBusinesses = [
      ...(viewModel.homeResponse.data?.data?.topBusiness ?? <Business>[]),
      ...(viewModel.homeResponse.data?.data?.newBusiness ?? <Business>[]),
    ].where((b) {
      if (b.isActive != 1 || b.id == null) return false;
      return seen.add(b.id!);
    }).toList();

    if (allBusinesses.isEmpty) return SizedBox.shrink();

    return Column(
      children: [
        _buildCustomSectionHeader("Plan Your Visit"),
        SizedBox(height: 8.h),
        Container(
          height: 400.h,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            itemCount: allBusinesses.length,
            onPageChanged: (index) {
              setState(() {
                _businessCarouselIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: _buildLargeBusinessCard(allBusinesses[index]),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        // Dot indicator for the carousel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            allBusinesses.length,
            (index) {
              final bool isActive = index == _businessCarouselIndex;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isActive ? 12.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: isActive ? AppColor.white : AppColor.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 30.h),
      ],
    );
  }

  Widget _buildLargeBusinessCard(Business item) {
    int? displayDiscount = item.discount_type == "regular" 
        ? item.set_regular_discount 
        : item.set_first_time_discount;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutesName.businessDescriptionView,
          arguments: item.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Large Image
              Expanded(
                flex: 75,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImageWidget(
                      imageUrl: item.businessImage ?? '',
                      fit: BoxFit.cover,
                    ),
                    // Offers Overlay Bar (The purple bar at bottom of image)
                    if (displayDiscount != null && displayDiscount > 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2E095C), 
                                AppColor.premiumAccent.withOpacity(0.9)
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_offer, size: 16.sp, color: Colors.white),
                              SizedBox(width: 10.w),
                              AppTextWidget(
                                text: "Flat $displayDiscount% OFF • Book Now",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // 2. Business Details
              Expanded(
                flex: 25,
                child: Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextWidget(
                              text: item.businessName ?? '',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              maxLines: 1,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.averageRating != null && item.averageRating! > 0)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFD700).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Color(0xFFFFD700), size: 12.sp),
                                  SizedBox(width: 4.w),
                                  AppTextWidget(
                                    text: item.averageRating is double
                                        ? (item.averageRating as double).toStringAsFixed(1)
                                        : '${item.averageRating}',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFFD700),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12.sp, color: AppColor.premiumTextSecondary),
                          SizedBox(width: 4.w),
                          AppTextWidget(
                            text: '${item.businessArea ?? 'Pune'} • ',
                            fontSize: 12.sp,
                            color: AppColor.premiumTextSecondary,
                          ),
                          Icon(Icons.category, size: 12.sp, color: AppColor.premiumAccent),
                          SizedBox(width: 4.w),
                          AppTextWidget(
                            text: item.businessCategory != null && item.businessCategory!.isNotEmpty
                                ? "${item.businessCategory![0].toUpperCase()}${item.businessCategory!.substring(1)}"
                                : "Business",
                            fontSize: 12.sp,
                            color: AppColor.premiumAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildBusinessCard(Business item) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    // More granular responsive breakpoints for different screen sizes
    final isVerySmall = h < 600; // Very small iPhones (SE, Mini)
    final isSmall = h < 700 && !isVerySmall; // Small screens
    final isMedium = h >= 700 && h < 850; // Medium screens
    // Large screens are h >= 850

    // Calculate responsive values based on screen size
    double cardWidth;
    double imageHeight;
    double cardPadding;
    double titleFontSize;
    double discountFontSize;
    double borderRadius;

    if (isVerySmall) {
      cardWidth = w * 0.42; // Increased from 0.38
      imageHeight = h * 0.08;
      cardPadding = 6;
      titleFontSize = 12.sp;
      discountFontSize = 11.sp;
      borderRadius = 12;
    } else if (isSmall) {
      cardWidth = w * 0.45; // Increased from 0.40
      imageHeight = h * 0.09;
      cardPadding = 8;
      titleFontSize = 13.sp;
      discountFontSize = 12.sp;
      borderRadius = 14;
    } else if (isMedium) {
      cardWidth = w * 0.48; // Increased from 0.42
      imageHeight = h * 0.11;
      cardPadding = 9;
      titleFontSize = 14.sp;
      discountFontSize = 13.sp;
      borderRadius = 15;
    } else {
      cardWidth = 200.w; // Increased from 180.w
      imageHeight = 115.h;
      cardPadding = 10;
      titleFontSize = 16.sp;
      discountFontSize = 14.sp;
      borderRadius = 16;
    }
    int? displayDiscount;

    if (item.discount_type == "regular") {
      displayDiscount = item.set_regular_discount;
    } else {
      // Default to first_time if type is first_time or null
      displayDiscount = item.set_first_time_discount;
    }
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutesName.businessDescriptionView,
          arguments: item.id,
        );
      },
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: AppColor.premiumCardBg,
          border: Border.all(
            color: AppColor.premiumAccent.withOpacity(0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.premiumAccent.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Subtle Inner Glass Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Top Reflective Line
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with constrained height and Discount Overlay
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius - 4),
                          child: AppImageWidget(
                            height: imageHeight,
                            width: double.infinity,
                            imageUrl: item.businessImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (displayDiscount != null && displayDiscount > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColor
                                    .mangoYellow, // Matching top reviewers rank badge
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_offer,
                                      size: 10.sp, color: Colors.black),
                                  SizedBox(width: 4.w),
                                  AppTextWidget(
                                    text: '${displayDiscount}% OFF',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: cardPadding * 1.0),
                    // Title Row with Category Icon
                    Row(
                      children: [
                        Expanded(
                          child: AppTextWidget(
                            text: '${item.businessName}',
                            textOverflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w700,
                            color: AppColor.premiumTextPrimary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // Category-specific theme icon
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _getBusinessTheme(item)["color"]
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getBusinessTheme(item)["icon"],
                              color: _getBusinessTheme(item)["color"],
                              size: 16.sp // Increased further from 14.sp
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Location as fallback if no discount (with effect color)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 11.sp,
                            color:
                                AppColor.premiumTextSecondary.withOpacity(0.7)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: AppTextWidget(
                            text: item.businessArea ?? 'Pune',
                            fontSize: 10.sp,
                            color:
                                AppColor.premiumTextSecondary.withOpacity(0.7),
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildDotIndicator(HomeViewModel homeViewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          homeViewModel.homeResponse.data!.data!.banners!.asMap().entries.map(
        (entry) {
          bool isActive = homeViewModel.position == entry.key;
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: isActive ? 20.w : 6.w,
            height: 6.h,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isActive
                  ? AppColor.premiumAccent
                  : AppColor.premiumTextSecondary.withOpacity(0.2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColor.premiumAccent.withOpacity(0.4),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ]
                  : [],
            ),
          );
        },
      ).toList(),
    );
  }

  CarouselSlider buildCarouselSlider(HomeViewModel homeViewModel) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160.0.h,
        autoPlay: true,
        enlargeCenterPage: false,
        enableInfiniteScroll: true,
        aspectRatio: 16 / 9,
        viewportFraction: 1.0,
        autoPlayCurve: Curves.fastOutSlowIn,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayInterval: Duration(seconds: 4),
        onPageChanged: (index, reason) =>
            homeViewModel.updateBannerIndex(index),
      ),
      carouselController: homeViewModel.controller,
      items: homeViewModel.homeResponse.data!.data!.banners!.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                homeViewModel.launchBannerUrl(item.link);
              },
              child: Container(
                width: SizeConfig.screenWidth,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Transform.scale(
                        scale: 1.02, // Subtle zoom as requested
                        child: AppImageWidget(
                          imageUrl: item.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    // Enhanced Glassy Overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 0.4, 0.6, 1.0],
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.02),
                            Colors.black.withOpacity(0.02),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    // Reflective Gloss Line
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Column buildComingSoon(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextWidget(
          text: title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColor.premiumTextPrimary,
        ),
        SizedBox(
          height: 10.h,
        ),
        Container(
          height: 180.h,
          width: SizeConfig.screenWidth,
          decoration: BoxDecoration(
            color: AppColor.darkGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Image.asset(
                        height: 120.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        Images.appLogo),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            height: 20.h,
                            width: 20.h,
                            AppIcon.calender,
                          ),
                          SizedBox(width: 5),
                          AppTextWidget(
                            text: '22 Dec 2024',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColor.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTextWidget(
                        text: 'Coming Soon...',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.white),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        SvgPicture.asset(
                          height: 14.h,
                          width: 14.h,
                          color: AppColor.white,
                          AppIcon.location,
                        ),
                        SizedBox(width: 5.w),
                        AppTextWidget(
                          text: 'Pune',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColor.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget buildReviewers({required String name, required List<Reviewer> data}) {
  //   return Column(
  //     children: [
  //       Container(
  //         height: 170.h,
  //         width: SizeConfig.screenWidth,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 17.w),
  //               child: AppTextWidget(
  //                 text: name,
  //                 fontSize: 18.sp,
  //                 fontWeight: FontWeight.w700,
  //                 color: AppColor.premiumTextPrimary,
  //               ),
  //             ),
  //
  //             SizedBox(
  //               height: 18.h,
  //             ),
  //             Expanded(
  //               child: ListView.builder(
  //                 itemCount: data.length,
  //                 shrinkWrap: true,
  //                 scrollDirection: Axis.horizontal,
  //                 padding: EdgeInsets.symmetric(horizontal: 17.w),
  //                 itemBuilder: (context, index) {
  //                   if (data[index].name == null) {
  //                     return SizedBox.shrink();
  //                   } else {
  //                     return Padding(
  //                       padding: EdgeInsets.only(
  //                         right: Utils.getValueBasedOnIndex(index, data.length),
  //                       ),
  //                       child: buildReviewersCard(data[index], name, index + 1),
  //                     );
  //                   }
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       // SizedBox(
  //       //   height: 5.h,
  //       // ),
  //     ],
  //   );
  // }

  Widget buildUser({required String name, required List<Creator> data}) {
    return Column(
      children: [
        Container(
          height: 160.h,
          width: SizeConfig.screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: AppTextWidget(
                  text: name,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.premiumTextPrimary,
                ),
              ),

              SizedBox(
                height: 18.h,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 17.w),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: Utils.getValueBasedOnIndex(index, data.length),
                      ),
                      child: buildCreatorCard(data[index], name),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }

  Widget buildBusiness({required String name, required List<Business> data}) {
    final h = MediaQuery.of(context).size.height;

    // More granular responsive breakpoints for different screen sizes
    final isVerySmall = h < 600; // Very small iPhones (SE, Mini)
    final isSmall = h < 700 && !isVerySmall; // Small screens
    final isMedium = h >= 700 && h < 850; // Medium screens
    // Large screens are h >= 850

    // Calculate responsive values based on screen size
    double sectionHeight;
    double cardHeight;
    double titleSpacing;
    double titleFontSize;
    double bottomSpacing;

    if (isVerySmall) {
      sectionHeight = h * 0.20; // Increased to fix overflow
      cardHeight = h * 0.16; // Increased to fix overflow
      titleSpacing = h * 0.005;
      titleFontSize = 14.sp;
      bottomSpacing = h * 0.005;
    } else if (isSmall) {
      sectionHeight = h * 0.22; // Increased to fix overflow
      cardHeight = h * 0.18; // Increased to fix overflow
      titleSpacing = h * 0.006;
      titleFontSize = 15.sp;
      bottomSpacing = h * 0.008;
    } else if (isMedium) {
      sectionHeight = h * 0.24; // Increased to fix overflow
      cardHeight = h * 0.20; // Increased to fix overflow
      titleSpacing = h * 0.008;
      titleFontSize = 16.sp;
      bottomSpacing = h * 0.01;
    } else {
      sectionHeight = 220.h; // Increased from 190 to fix overflow
      cardHeight = 195.h; // Increased from 165 to fix overflow
      titleSpacing = 8.h;
      titleFontSize = 18.sp;
      bottomSpacing = 10.h;
    }

    return Column(
      children: [
        Container(
          height: sectionHeight,
          width: SizeConfig.screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextWidget(
                text: name.toUpperCase(),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.premiumTextPrimary,
                letterSpacing: 0.5,
              ),
              SizedBox(height: titleSpacing),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: Utils.getValueBasedOnIndex(index, data.length),
                      ),
                      child: SizedBox(
                        height: cardHeight,
                        child: buildBusinessCard(data[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }

  // Widget buildReviewersCard(Reviewer item, String name, int rank) {
  //   return GestureDetector(
  //     onTap: () {
  //       if (name == "Top Reviewers") {
  //         Navigator.pushNamed(
  //           context,
  //           RoutesName.reviewView,
  //           arguments: item.id,
  //         );
  //       }
  //     },
  //     child: Container(
  //       // width: 70.w,
  //       alignment: Alignment.topCenter,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Stack(
  //             children: [
  //               Container(
  //                 padding: EdgeInsets.all(3),
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   border: Border.all(
  //                       color: AppColor.premiumAccent.withOpacity(0.3),
  //                       width: 1.5),
  //                 ),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(100),
  //                   child: AppImageWidget(
  //                     isProfile: true,
  //                     height: 65.h,
  //                     width: 65.h,
  //                     fit: BoxFit.cover,
  //                     iconSize: 50.sp,
  //                     imageUrl: item.userImage ?? '',
  //                   ),
  //                 ),
  //               ),
  //               Positioned(
  //                 top: 0,
  //                 left: 0,
  //                 child: Container(
  //                   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //                   decoration: BoxDecoration(
  //                     color: AppColor.mangoYellow,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   child: AppTextWidget(
  //                     text: "#$rank",
  //                     fontSize: 10.sp,
  //                     fontWeight: FontWeight.w800,
  //                     color: AppColor.black,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(
  //             height: 10.h,
  //           ),
  //           Container(
  //             width: 65.h,
  //             child: AppTextWidget(
  //               text: "${item.name}",
  //               fontSize: 12.sp,
  //               fontWeight: FontWeight.w600,
  //               color: AppColor.premiumTextPrimary,
  //               textAlign: TextAlign.center,
  //               maxLines: 1,
  //               textOverflow: TextOverflow.ellipsis,
  //             ),
  //           ),
  //           Container(
  //             width: 70.h,
  //             child: AppTextWidget(
  //               text: "${item.totalReviews} Reviews",
  //               maxLines: 2,
  //               softWrap: true,
  //               textAlign: TextAlign.center,
  //               textOverflow: TextOverflow.ellipsis,
  //               fontSize: 10.sp,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget buildCreatorCard(Creator item, String name) {
    return GestureDetector(
      onTap: () {
        AppDialog.showFullScreenDialog(
          Item(
            image: item.userImage,
            name: item.name,
            address: item.address,
            role: item.roleId == 2 ? "Business" : "Creator",
            isActive: item.isActive == 1 ? true : false,
          ),
        );
      },
      child: Container(
        // width: 80.w,
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColor.premiumAccent.withOpacity(0.3), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: AppImageWidget(
                  isProfile: true,
                  height: 65.h,
                  width: 65.h,
                  iconSize: 50.sp,
                  imageUrl: item.userImage ?? '',
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              width: 65.h,
              child: AppTextWidget(
                text: "${item.name}",
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.premiumTextPrimary,
                textAlign: TextAlign.center,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCard({
    required dynamic icon,
    required String title,
    required VoidCallback onPressed,
    String? balance,
    bool isImage = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Container for Icon/Image
          Container(
            padding: EdgeInsets.all(10.h),
            decoration: BoxDecoration(
              color: AppColor.primary.shade100,
              borderRadius: BorderRadius.circular(10.sp),
              // border: Border.all(color: AppColor.primary),
            ),
            child: isImage
                ? Image.asset(
                    icon,
                    width: 35.w,
                    height: 35.h,
                    color: Colors.white,
                  )
                : Icon(
                    icon,
                    size: 35.sp,
                    color: AppColor.white,
                  ),
          ),
          SizedBox(height: 8.h),
          // Title

          AppTextWidget(
            text: title,
            fontSize: 13.sp,
            color: AppColor.black,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          if (balance != null) ...[
            SizedBox(height: 4.h),
            AppTextWidget(
              text: balance,
              fontSize: 12,
              color: AppColor.activeGreen,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildPremiumHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                child: CircleAvatar(
                  backgroundColor: AppColor.premiumCardBg,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AppImageWidget(
                      height: 46,
                      width: 46,
                      isProfile: true,
                      fit: BoxFit.cover,
                      iconSize: 24.sp,
                      imageUrl: viewModel.user?.image ?? "",
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColor.premiumBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.verified,
                      color: AppColor.premiumAccent, size: 14),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  text: _getGreetingText(),
                  fontSize: 11.sp,
                  color: AppColor.premiumTextSecondary,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Flexible(
                      child: AppTextWidget(
                        text: viewModel.user?.name ?? '',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.premiumTextPrimary,
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 4.h),
                // Stylized Premium Badge
              //   Container(
              //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //     decoration: BoxDecoration(
              //       color: AppColor.mangoYellow.withOpacity(0.15),
              //     borderRadius: BorderRadius.circular(6),
              //     border: Border.all(
              //       color: AppColor.mangoYellow.withOpacity(0.3),
              //       width: 0.5,
              //     ),
              //   ),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Text(
              //         "👑",
              //         style: TextStyle(fontSize: 8.sp),
              //       ),
              //       SizedBox(width: 4),
              //       AppTextWidget(
              //         text: "PREMIUM",
              //         fontSize: 8.sp,
              //         fontWeight: FontWeight.w900,
              //         color: AppColor.mangoYellow,
              //         letterSpacing: 0.5,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
        // _buildHeaderIcon(Icons.search, () {
        //   Provider.of<HomeViewModel>(context, listen: false).changeIndex(1, false);
        // }),
        // SizedBox(width: 10.w),
        _buildHeaderIcon(Icons.notifications_none_outlined, () {
          Navigator.pushNamed(context, RoutesName.notificationView);
          clearNewNotificationFlag();
        },
            hasBadge: roleId == Constants.businessUser
                ? hasNewNotification
                : (viewModel.homeResponse.data?.data?.isPendingReviewFlag != null || hasNewNotification)),
      ],
    ));
  }

  String _getGreetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap,
      {bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppColor.premiumTextPrimary, size: 20.sp),
            if (hasBadge)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.premiumBg, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildWalletBalanceCard() {
    return GestureDetector(
      onTap: () {
        Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: false)
            .changeIndex(3, true);
      },
      child: Container(
        height: 132.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E095C), 
              Color(0xFF1A1A1A), 
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2E095C).withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextWidget(
                              text: "TOTAL POINTS",
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 1.5,
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AppTextWidget(
                            text: "WALLET",
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextWidget(
                              text: "${viewModel.walletCreatooPoints}",
                              fontSize: 34.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            AppTextWidget(
                              text: "CREATOO PTS",
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.premiumAccent,
                              letterSpacing: 1.2,
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 4.h),
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColor.activeGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.trending_up, color: AppColor.activeGreen, size: 12.sp),
                              SizedBox(width: 4.w),
                              AppTextWidget(
                                text: "2.5%",
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColor.activeGreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarAction(
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 10.w),
            AppTextWidget(
              text: title.toUpperCase(),
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.premiumTextPrimary,
              letterSpacing: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 4,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.premiumCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.premiumBorder, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8.h),
            AppTextWidget(
              text: title,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.premiumTextPrimary,
              textAlign: TextAlign.center,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCategoryFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 17.w),
          child: AppTextWidget(
            text: "EXPLORE CATEGORIES",
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 18.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 17.w), // Flush to edges but starts correctly
          child: Row(
            children: [
              _buildFilterItem("Restaurants", Icons.restaurant_menu, Color(0xFFFF5722)),
              _buildFilterItem("Salon", Icons.content_cut, Color(0xFFE91E63)),
              _buildFilterItem("Turf", Icons.sports_soccer, Color(0xFF4CAF50)),
              _buildFilterItem("Bookings", Icons.event_note, Color(0xFFFFC107)),
              _buildFilterItem("Events", Icons.event_available, Color(0xFF009688)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterItem(String title, IconData icon, Color color) {
    final String? categoryKey = _categoryKey(title);
    return GestureDetector(
      onTap: () {
        if (title == "Bookings") {
          Provider.of<HomeViewModel>(context, listen: false).changeIndex(2, false);
        } else if (categoryKey != null) {
          Navigator.pushNamed(context, RoutesName.categoryBusinessListView, arguments: categoryKey);
        } else {
          Navigator.pushNamed(context, RoutesName.comingSoonView);
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        child: Column(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppColor.premiumCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2), width: 1.2),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.06), blurRadius: 8),
                ],
              ),
              child: Center(child: Icon(icon, color: color, size: 26.sp)),
            ),
            SizedBox(height: 5.h),
            AppTextWidget(
              text: title,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.premiumTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String? _categoryKey(String title) {
    switch (title) {
      case 'Restaurants': return 'restaurant';
      case 'Salon': return 'salon';
      case 'Turf': return 'turf';
      default: return null;
    }
  }

  AppBar _buildHomeAppBarWidget() {
    return AppBar();
  }
}
