import 'package:creatoo/features/business_payments/view_model/business_payments_view_model.dart';
import 'package:creatoo/features/user_payments/view_model/user_payments_view_model.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:intl/intl.dart';

import '../view_model/creator_wallet_view_model.dart';
import '../widgets/creatoo_tab_view.dart';

final GlobalKey<_CreatorWalletViewState> creatorWalletKey =
    GlobalKey<_CreatorWalletViewState>();

class CreatorWalletView extends StatefulWidget {
  final int index;
  const CreatorWalletView({super.key, this.index = 0});

  @override
  State<CreatorWalletView> createState() => _CreatorWalletViewState();
}

class _CreatorWalletViewState extends State<CreatorWalletView> {
  late CreatorWalletViewModel viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
    });
  }

  void _loadPayments() {
    if (roleId == Constants.businessUser) {
      context.read<BusinessPaymentsViewModel>().loadPayments();
    } else {
      context.read<UserPaymentsViewModel>().loadPayments();
      context.read<CreatorWalletViewModel>().fetchCreatorEarningWalletTransaction();
    }
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CreatorWalletViewModel>(context);
    return AppScaffold(
      useGradient: false,
      backgroundColor: Colors.transparent,
      isSafe: false,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumHeader(),
            SizedBox(height: 15.h),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: AppSlidingSegmentController(
                name1: "Transaction",
                name2: "Creatoo",
                index: viewModel.currentSelection,
                onTap: (index) {
                  viewModel.changeIndex(index);
                  if (index == 0) _loadPayments();
                },
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: IndexedStack(
                index: viewModel.currentSelection,
                children: [
                  _buildPaymentsTab(),
                  CreatooTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    if (roleId == Constants.businessUser) {
      return Consumer<BusinessPaymentsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return Center(child: CircularProgressIndicator(color: AppColor.premiumAccent));
          }
          if (vm.error != null) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline, color: Colors.white38, size: 48.sp),
              SizedBox(height: 16.h),
              Text("Failed to load payments", style: TextStyle(color: Colors.white54)),
              SizedBox(height: 16.h),
              AppButton(text: "Retry", onTap: () => vm.loadPayments()),
            ]));
          }
          if (vm.payments.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 64.sp),
              SizedBox(height: 16.h),
              Text("No payments yet", style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white38)),
            ]));
          }
          return RefreshIndicator(
            color: AppColor.premiumAccent,
            backgroundColor: AppColor.premiumCardBg,
            onRefresh: () => vm.loadPayments(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
              itemCount: vm.payments.length,
              itemBuilder: (context, index) => _buildPaymentTile(vm.payments[index], isBusiness: true),
            ),
          );
        },
      );
    }
    return Consumer2<UserPaymentsViewModel, CreatorWalletViewModel>(
      builder: (context, vm, cv, _) {
        final orderTxns = cv.earningTransactionResponse.data?.data?.transactions ?? [];
        final hasManualPayments = vm.payments.isNotEmpty;
        final hasOrderTxns = orderTxns.isNotEmpty;

        if (vm.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColor.premiumAccent));
        }
        if (vm.error != null && !hasManualPayments && !hasOrderTxns) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, color: Colors.white38, size: 48.sp),
            SizedBox(height: 16.h),
            Text("Failed to load payments", style: TextStyle(color: Colors.white54)),
            SizedBox(height: 16.h),
            AppButton(text: "Retry", onTap: () => vm.loadPayments()),
          ]));
        }
        if (!hasManualPayments && !hasOrderTxns) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 64.sp),
            SizedBox(height: 16.h),
            Text("No payments yet", style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white38)),
          ]));
        }
        return RefreshIndicator(
          color: AppColor.premiumAccent,
          backgroundColor: AppColor.premiumCardBg,
          onRefresh: () async {
            await vm.loadPayments();
            await cv.fetchCreatorEarningWalletTransaction();
          },
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
            itemCount: vm.payments.length + orderTxns.length,
            itemBuilder: (context, index) {
              if (index < vm.payments.length) {
                return _buildPaymentTile(vm.payments[index], isBusiness: false);
              }
              final order = orderTxns[index - vm.payments.length];
              return _buildOrderTile(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentTile(dynamic payment, {required bool isBusiness}) {
    final isPending = payment.status == 'PENDING';
    final isConfirmed = payment.status == 'CONFIRMED';
    final name = isBusiness ? (payment.userName ?? "Customer") : (payment.businessName ?? payment.userName ?? "Shop");
    final imageUrl = isBusiness ? payment.userImage : payment.businessImage;
    final timeStr = DateFormat("dd MMM yyyy, hh:mm a").format(payment.createdAt);
    final discountPct = payment.discountPercentage;
    final discountAmt = payment.discountAmount ?? 0.0;
    final points = payment.pointsRedeemed;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColor.mangoYellow.withOpacity(0.3) : isConfirmed ? AppColor.activeGreen.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.06),
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null
                    ? Icon(isBusiness ? Icons.person : Icons.store, color: Colors.white38, size: 20.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                      style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 2.h),
                    Text(timeStr,
                      style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white30)),
                  ],
                ),
              ),
              _buildStatusBadge(payment.status),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Bill Amount", style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white.withOpacity(0.5))),
              Text("₹${payment.billAmount.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white70)),
            ],
          ),
          if (discountPct != null && discountPct > 0)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Discount ($discountPct%)", style: GoogleFonts.montserrat(fontSize: 11.sp, color: AppColor.premiumAccent.withOpacity(0.7))),
                  Text("-₹${discountAmt.toStringAsFixed(0)}",
                    style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColor.premiumAccent)),
                ],
              ),
            ),
          if (points > 0)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Points ($points)", style: GoogleFonts.montserrat(fontSize: 11.sp, color: AppColor.mangoYellow.withOpacity(0.7))),
                  Text("-$points", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColor.mangoYellow)),
                ],
              ),
            ),
          Divider(color: Colors.white.withOpacity(0.08), height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isBusiness ? "Received" : "You Paid", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white)),
              Text("₹${payment.finalAmount.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isPending = status == 'PENDING';
    final isConfirmed = status == 'CONFIRMED';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isPending
            ? AppColor.mangoYellow.withOpacity(0.12)
            : isConfirmed
                ? AppColor.activeGreen.withOpacity(0.12)
                : Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPending
              ? AppColor.mangoYellow.withOpacity(0.3)
              : isConfirmed
                  ? AppColor.activeGreen.withOpacity(0.3)
                  : Colors.redAccent.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        isPending ? "PENDING" : isConfirmed ? "PAID" : "CANCELLED",
        style: GoogleFonts.montserrat(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: isPending ? AppColor.mangoYellow : isConfirmed ? AppColor.activeGreen : Colors.redAccent,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildOrderTile(dynamic order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.06),
                backgroundImage: order.businessImage != null ? NetworkImage(order.businessImage!) : null,
                child: order.businessImage == null
                    ? Icon(Icons.store, color: AppColor.premiumAccent, size: 18.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.paidTo ?? "Business",
                      style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      order.dateTime != null ? _formatPaymentDate(order.dateTime!) : "",
                      style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white30),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColor.activeGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.activeGreen.withOpacity(0.3), width: 0.5),
                ),
                child: Text(
                  "PAID",
                  style: GoogleFonts.montserrat(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppColor.activeGreen, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Bill Amount", style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white.withOpacity(0.5))),
              Text("₹${order.totalBill ?? '0'}", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white70)),
            ],
          ),
          if (order.discountPercentage != null && order.discountPercentage! > 0)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Discount (${order.discountPercentage!.toStringAsFixed(0)}%)", style: GoogleFonts.montserrat(fontSize: 11.sp, color: AppColor.premiumAccent.withOpacity(0.7))),
                  Text("-₹${(double.tryParse(order.totalBill ?? '0')! * order.discountPercentage! / 100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColor.premiumAccent)),
                ],
              ),
            ),
          Divider(color: Colors.white.withOpacity(0.08), height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("You Paid", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white)),
              Text("₹${order.finalBill ?? '0'}", style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPaymentDate(DateTime dt) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
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
                AppTextWidget(text: "CREATOO", fontSize: 11.sp, color: AppColor.premiumAccent, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                SizedBox(height: 2.h),
                AppTextWidget(text: "My Wallet", fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppColor.premiumTextPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
