import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import '../view_model/business_payments_view_model.dart';

class BusinessPaymentsScreen extends StatefulWidget {
  const BusinessPaymentsScreen({super.key});

  @override
  State<BusinessPaymentsScreen> createState() => _BusinessPaymentsScreenState();
}

class _BusinessPaymentsScreenState extends State<BusinessPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<BusinessPaymentsViewModel>();
      vm.loadPayments();
      vm.loadPaymentStats();
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
            _buildFilterTabs(),
            Expanded(child: _buildPaymentsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: Row(
        children: [
          CustomBackButton(onTap: () => Navigator.pop(context)),
          SizedBox(width: 16.w),
          Text(
            "Payments",
            style: GoogleFonts.montserrat(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Consumer<BusinessPaymentsViewModel>(
      builder: (context, vm, _) {
        final filters = ['ALL', 'PENDING', 'CONFIRMED', 'CANCELLED'];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: filters.map((f) {
              final selected = vm.selectedFilter == f;
              final count = f == 'ALL'
                  ? vm.payments.length
                  : f == 'PENDING'
                      ? vm.pendingPayments.length
                      : f == 'CONFIRMED'
                          ? vm.confirmedPayments.length
                          : vm.cancelledPayments.length;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    vm.setFilter(f);
                    vm.loadPayments(statusFilter: f == 'ALL' ? null : f);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColor.premiumAccent.withOpacity(0.2)
                          : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColor.premiumAccent
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          f == 'ALL' ? 'All' : f == 'PENDING' ? 'Pending' : f == 'CONFIRMED' ? 'Received' : 'Cancelled',
                          style: GoogleFonts.montserrat(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColor.premiumAccent : Colors.white60,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "$count",
                          style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsList() {
    return Consumer<BusinessPaymentsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.premiumAccent),
          );
        }
        if (vm.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.white38, size: 48.sp),
                SizedBox(height: 16.h),
                Text("Failed to load payments", style: TextStyle(color: Colors.white54)),
                SizedBox(height: 16.h),
                AppButton(text: "Retry", onTap: () => vm.loadPayments()),
              ],
            ),
          );
        }
        final displayList = vm.selectedFilter == 'ALL'
            ? vm.payments
            : vm.selectedFilter == 'PENDING'
                ? vm.pendingPayments
                : vm.selectedFilter == 'CONFIRMED'
                    ? vm.confirmedPayments
                    : vm.cancelledPayments;
        if (displayList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 64.sp),
                SizedBox(height: 16.h),
                Text("No payments found", style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white38)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: displayList.length,
          itemBuilder: (context, index) => _buildPaymentCard(displayList[index]),
        );
      },
    );
  }

  Widget _buildPaymentCard(payment) {
    final isPending = payment.status == 'PENDING';
    final isConfirmed = payment.status == 'CONFIRMED';
    final isCancelled = payment.status == 'CANCELLED';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending
              ? AppColor.mangoYellow.withOpacity(0.3)
              : isConfirmed
                  ? AppColor.activeGreen.withOpacity(0.3)
                  : Colors.redAccent.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.premiumAccent.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        (payment.userName ?? 'U')[0].toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.premiumAccent,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.userName ?? 'User',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (payment.userMobile != null)
                        Text(
                          payment.userMobile!,
                          style: GoogleFonts.montserrat(
                            fontSize: 11.sp,
                            color: Colors.white38,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isPending
                      ? AppColor.mangoYellow.withOpacity(0.15)
                      : isConfirmed
                          ? AppColor.activeGreen.withOpacity(0.15)
                          : Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPending ? 'PENDING' : isConfirmed ? 'RECEIVED' : 'CANCELLED',
                  style: GoogleFonts.montserrat(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: isPending ? AppColor.mangoYellow : isConfirmed ? AppColor.activeGreen : Colors.redAccent,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCol("Bill", "₹${payment.billAmount.toStringAsFixed(0)}", Colors.white70),
              if (payment.discountPercentage != null && payment.discountPercentage! > 0)
                _buildInfoCol("Discount", "${payment.discountPercentage}%", AppColor.premiumAccent),
              if (payment.pointsRedeemed > 0)
                _buildInfoCol("Points", "-${payment.pointsRedeemed}", AppColor.mangoYellow),
              _buildInfoCol("Final", "₹${payment.finalAmount.toStringAsFixed(0)}", Colors.white),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _formatDate(payment.createdAt),
            style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white38)),
        SizedBox(height: 4.h),
        Text(value, style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

}
