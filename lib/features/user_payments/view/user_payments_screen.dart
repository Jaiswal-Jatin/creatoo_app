import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import 'package:creatoo/utils/routes/routes_name.dart';
import '../view_model/user_payments_view_model.dart';

class UserPaymentsScreen extends StatefulWidget {
  const UserPaymentsScreen({super.key});

  @override
  State<UserPaymentsScreen> createState() => _UserPaymentsScreenState();
}

class _UserPaymentsScreenState extends State<UserPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserPaymentsViewModel>().loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          Positioned(top: -120.h, right: -60.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(width: 350.w, height: 350.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.premiumAccent.withValues(alpha: 0.1))),
          )),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
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
          Text("My Payments", style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, RoutesName.userPointsView),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.premiumAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, size: 14.sp, color: AppColor.premiumAccent),
                  SizedBox(width: 4.w),
                  Text("Points", style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColor.premiumAccent)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<UserPaymentsViewModel>(
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
                Text("Failed to load payments", style: TextStyle(color: Colors.white54)),
                SizedBox(height: 16.h),
                AppButton(text: "Retry", onTap: () => vm.loadPayments()),
              ],
            ),
          );
        }
        if (vm.payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 64.sp),
                SizedBox(height: 16.h),
                Text("No payments yet", style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white38)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: vm.payments.length,
          itemBuilder: (context, index) => _buildPaymentCard(vm.payments[index]),
        );
      },
    );
  }

  Widget _buildPaymentCard(dynamic payment) {
    final isPending = payment.status == 'PENDING';
    final isConfirmed = payment.status == 'CONFIRMED';
    final hasDiscount = payment.discountPercentage != null && payment.discountPercentage! > 0;
    final hasPoints = payment.pointsRedeemed > 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.04),
                Colors.white.withValues(alpha: 0.01),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPending
                  ? AppColor.mangoYellow.withValues(alpha: 0.25)
                  : isConfirmed
                      ? AppColor.activeGreen.withValues(alpha: 0.2)
                      : Colors.redAccent.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      backgroundImage: payment.businessImage != null ? NetworkImage(payment.businessImage!) : null,
                      child: payment.businessImage == null
                          ? Icon(Icons.store, color: Colors.white38, size: 20.sp)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.businessName ?? "Business",
                          style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatDate(payment.createdAt),
                          style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white30),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: isPending
                          ? AppColor.mangoYellow.withValues(alpha: 0.12)
                          : isConfirmed
                              ? AppColor.activeGreen.withValues(alpha: 0.12)
                              : Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPending
                            ? AppColor.mangoYellow.withValues(alpha: 0.3)
                            : isConfirmed
                                ? AppColor.activeGreen.withValues(alpha: 0.3)
                                : Colors.redAccent.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      isPending ? "PENDING" : isConfirmed ? "PAID" : "CANCELLED",
                      style: GoogleFonts.montserrat(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: isPending
                            ? AppColor.mangoYellow
                            : isConfirmed
                                ? AppColor.activeGreen
                                : Colors.redAccent,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
              SizedBox(height: 14.h),
              _buildAmountRow("Bill Amount", "₹${payment.billAmount.toStringAsFixed(0)}", Colors.white70),
              if (hasDiscount)
                _buildAmountRow("Discount (${payment.discountPercentage}%)", "-₹${payment.discountAmount?.toStringAsFixed(0) ?? '0'}", AppColor.premiumAccent),
              if (hasPoints)
                _buildAmountRow("Points Redeemed", "-${payment.pointsRedeemed}", AppColor.mangoYellow),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 20.h),
              _buildAmountRow("You Paid", "₹${payment.finalAmount.toStringAsFixed(0)}", Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white70)),
          Text(value, style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
