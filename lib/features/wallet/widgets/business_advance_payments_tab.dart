import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:creatoo/core.dart';
import 'package:intl/intl.dart';
import '../model/settlement_response_model.dart';
import '../view_model/settlement_view_model.dart';

class BusinessAdvancePaymentsTab extends StatefulWidget {
  const BusinessAdvancePaymentsTab({super.key});

  @override
  State<BusinessAdvancePaymentsTab> createState() => _BusinessAdvancePaymentsTabState();
}

class _BusinessAdvancePaymentsTabState extends State<BusinessAdvancePaymentsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettlementViewModel>().fetchAdvancePayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettlementViewModel>();

    return SafeArea(
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextWidget(text: "CREATOO", fontSize: 11.sp, color: AppColor.premiumAccent, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                      SizedBox(height: 2.h),
                      AppTextWidget(text: "Advance Payments", fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppColor.premiumTextPrimary),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(child: _buildContent(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SettlementViewModel vm) {
    if (vm.advancePayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, size: 60.sp, color: AppColor.premiumTextSecondary.withOpacity(0.3)),
            SizedBox(height: 12.h),
            Text('No advance payments yet', style: GoogleFonts.montserrat(fontSize: 14.sp, color: AppColor.premiumTextSecondary)),
          ],
        ),
      );
    }

    // Calculate total
    double totalAdvance = 0;
    for (final t in vm.advancePayments) {
      totalAdvance += t.amount;
    }

    return RefreshIndicator(
      color: AppColor.premiumAccent,
      onRefresh: () => vm.fetchAdvancePayments(),
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          // Total card
          _buildTotalCard(totalAdvance, vm),
          SizedBox(height: 20.h),
          // List
          ...vm.advancePayments.map((t) => _buildAdvanceTile(t)),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildTotalCard(double total, SettlementViewModel vm) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A5ACD), Color(0xFF9759C4).withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Color(0xFF6A5ACD).withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total Advance Received", style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white70)),
          SizedBox(height: 6.h),
          Text("₹ ${total.toCommaSeparated()}", style: GoogleFonts.montserrat(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white)),
          SizedBox(height: 4.h),
          Text("${vm.advancePayments.length} transaction${vm.advancePayments.length > 1 ? 's' : ''}", style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildAdvanceTile(WalletTransactionItem txn) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          txn.fromUserProfile.isNotEmpty
              ? CircleAvatar(
                  radius: 18.w,
                  backgroundImage: NetworkImage(txn.fromUserProfile),
                  onBackgroundImageError: (_, __) {},
                )
              : CircleAvatar(
                  radius: 18.w,
                  backgroundColor: Color(0xFF6A5ACD).withOpacity(0.15),
                  child: Text(
                    (txn.fromUserName.isNotEmpty ? txn.fromUserName[0] : 'U').toUpperCase(),
                    style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Color(0xFF6A5ACD)),
                  ),
                ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.fromUserName.isNotEmpty ? txn.fromUserName : (txn.remark ?? 'Advance Payment'),
                  style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColor.premiumTextPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(txn.createdAt.toLocal()),
                  style: GoogleFonts.montserrat(fontSize: 10.sp, color: AppColor.premiumTextSecondary),
                ),
              ],
            ),
          ),
          Text(
            '+₹${txn.amount.toStringAsFixed(0)}',
            style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColor.activeGreen),
          ),
        ],
      ),
    );
  }
}
