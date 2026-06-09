import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import 'package:creatoo/features/creator_wallet/model/creator_creatoo_transaction_response.dart';
import '../view_model/user_points_view_model.dart';

class UserPointsScreen extends StatefulWidget {
  const UserPointsScreen({super.key});

  @override
  State<UserPointsScreen> createState() => _UserPointsScreenState();
}

class _UserPointsScreenState extends State<UserPointsScreen> {
  final Set<int> _expandedTiles = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserPointsViewModel>().loadPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 5.h),
      child: Row(
        children: [
          CustomBackButton(onTap: () => Navigator.pop(context)),
          SizedBox(width: 16.w),
          Text(
            "My Loyalty Points",
            style: GoogleFonts.montserrat(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Spacer(),
          Tooltip(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.premiumCardBg,
              border: Border.all(color: AppColor.premiumAccent.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            enableTapToDismiss: true,
            showDuration: Duration(seconds: 100),
            triggerMode: TooltipTriggerMode.tap,
            preferBelow: true,
            richMessage: TextSpan(
              text: Constants.walletInfo,
              style: TextStyle(color: AppColor.premiumTextPrimary, fontSize: 14.sp),
            ),
            child: Icon(Icons.info_outline, size: 20.h, color: AppColor.premiumAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<UserPointsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColor.premiumAccent));
        }
        if (vm.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.white38, size: 48.sp),
                SizedBox(height: 16.h),
                Text("Failed to load points", style: TextStyle(color: Colors.white54)),
                SizedBox(height: 16.h),
                AppButton(text: "Retry", onTap: () => vm.loadPoints()),
              ],
            ),
          );
        }
        if (vm.businessTransactions == null || vm.businessTransactions!.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard_outlined, color: Colors.white24, size: 64.sp),
                SizedBox(height: 16.h),
                Text("No points earned yet", style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white38)),
                SizedBox(height: 8.h),
                Text("Pay bills at businesses to earn loyalty points!",
                    style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white24)),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalPointsCard(vm),
              SizedBox(height: 20.h),
              Text(
                "Points by Business",
                style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              SizedBox(height: 12.h),
              ...vm.businessTransactions!.asMap().entries.map(
                    (entry) => _buildBusinessCard(entry.key, entry.value),
                  ),
              SizedBox(height: 24.h),
              _buildInfoCard(),
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalPointsCard(UserPointsViewModel vm) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.premiumAccent.withOpacity(0.2), AppColor.premiumAccent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColor.premiumAccent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.workspace_premium, color: AppColor.premiumAccent, size: 32.sp),
          SizedBox(height: 12.h),
          Text(
            "Total Points Balance",
            style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.white60),
          ),
          SizedBox(height: 8.h),
          Text(
            "${vm.formatPoints(vm.totalPoints)} Points",
            style: GoogleFonts.montserrat(fontSize: 36.sp, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          SizedBox(height: 4.h),
          Text(
            "Across ${vm.totalBusinesses} ${vm.totalBusinesses == 1 ? "business" : "businesses"}",
            style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(int index, BusinessTransaction bt) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent),
        child: ExpansionTile(
          showTrailingIcon: false,
          tilePadding: EdgeInsets.zero,
          collapsedShape: Border.all(style: BorderStyle.none),
          shape: Border.all(style: BorderStyle.none),
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColor.premiumAccent.withOpacity(0.15),
                  child: Icon(Icons.store, color: AppColor.premiumAccent, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bt.businessName ?? "Unknown Business",
                        style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.monetization_on_outlined, size: 14.sp, color: AppColor.mangoYellow),
                          SizedBox(width: 4.w),
                          Text(
                            "${bt.totalPoints?.isNegative == true ? 0 : bt.totalPoints} Points",
                            style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColor.mangoYellow),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expandedTiles.contains(index) ? 0.5 : 0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.premiumAccent.withOpacity(0.2)),
                      shape: BoxShape.circle,
                      color: AppColor.premiumAccent.withOpacity(0.15),
                    ),
                    child: Icon(Icons.keyboard_arrow_down, color: AppColor.premiumAccent, size: 24),
                  ),
                ),
              ],
            ),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              if (expanded) { _expandedTiles.add(index); } else { _expandedTiles.remove(index); }
            });
          },
          children: [
            if (bt.transactions != null && bt.transactions!.isNotEmpty)
              ...bt.transactions!.map((t) => _buildTransactionRow(t)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(Transaction t) {
    final isExpired = t.isExpired == true || t.creditDebitRemainingStatus == "expired";
    final isCredit = !isExpired && t.creditDebitRemainingStatus == "credit";

    String label;
    String dateStr;
    Color accentColor;
    IconData icon;
    String pointsPrefix;

    if (isExpired) {
      label = "Expired";
      dateStr = t.expiryDate != null ? DateFormat("dd MMM yyyy").format(t.expiryDate!) : "";
      accentColor = Colors.grey;
      icon = Icons.history;
      pointsPrefix = "-";
    } else if (isCredit) {
      label = "Earned";
      dateStr = t.createdAt != null ? DateFormat("dd MMM yyyy").format(t.createdAt!) : "";
      accentColor = AppColor.activeGreen;
      icon = Icons.arrow_downward;
      pointsPrefix = "+";
    } else {
      label = "Redeemed";
      dateStr = t.createdAt != null ? DateFormat("dd MMM yyyy").format(t.createdAt!) : "";
      accentColor = Colors.redAccent;
      icon = Icons.arrow_upward;
      pointsPrefix = "-";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: isExpired ? Colors.white.withOpacity(0.02) : Colors.transparent,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.15),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                SizedBox(height: 2.h),
                Text(dateStr, style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white24)),
              ],
            ),
          ),
          Text(
            "$pointsPrefix${t.points ?? 0} pts",
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.premiumAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.premiumAccent.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColor.premiumAccent, size: 18.h),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "Points are business-specific. Earn 10% of your bill as points. "
              "25% expire after 15 days, 50% after 30 days, 100% after 60 days. "
              "1 Point = ₹1 discount on future bills at the same business.",
              style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white54, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
