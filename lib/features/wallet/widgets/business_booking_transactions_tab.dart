import 'package:creatoo/core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/settlement_response_model.dart';
import '../view_model/settlement_view_model.dart';

class BusinessBookingTransactionsTab extends StatefulWidget {
  const BusinessBookingTransactionsTab({super.key});

  @override
  State<BusinessBookingTransactionsTab> createState() => _BusinessBookingTransactionsTabState();
}

class _BusinessBookingTransactionsTabState extends State<BusinessBookingTransactionsTab> {
  final Set<String> _expandedDates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SettlementViewModel>();
      vm.fetchSummary();
      vm.fetchTransactions();
      vm.fetchCombinedSettlement();
    });
  }

  Map<String, List<WalletTransactionItem>> _groupTransactionsByDay(List<WalletTransactionItem> txns) {
    final Map<String, List<WalletTransactionItem>> groups = {};
    for (final txn in txns) {
      final dateStr = DateFormat('yyyy-MM-dd').format(txn.createdAt);
      if (!groups.containsKey(dateStr)) {
        groups[dateStr] = [];
      }
      groups[dateStr]!.add(txn);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettlementViewModel>();
    final summary = vm.summary;
    final txns = vm.transactions;

    final totalAmount = summary?.totalAmount ?? 0;
    final unsettledAmount = vm.combinedSettlement?.bookingPending ?? 0;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningCard(totalAmount, unsettledAmount),
          SizedBox(height: 16.h),
          Expanded(child: _buildTransactionList(vm, txns)),
        ],
      ),
    );
  }

  Widget _buildEarningCard(double totalAmount, double unsettledAmount) {
    return Container(
      width: double.infinity,
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D1B36),
            Color(0xFF0F0E23),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                AppIcon.walletBg,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
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
                          Text(
                            "Total Amount",
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "₹ ${totalAmount.toCommaSeparated()}",
                            style: GoogleFonts.montserrat(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Unsettled Balance",
                            style: GoogleFonts.montserrat(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "₹ ${unsettledAmount.toCommaSeparated()}",
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(SettlementViewModel vm, List<WalletTransactionItem> displayTxns) {
    if (displayTxns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60.sp, color: AppColor.premiumTextSecondary.withOpacity(0.3)),
            SizedBox(height: 12.h),
            Text('No booking transactions found',
              style: GoogleFonts.montserrat(fontSize: 14.sp, color: AppColor.premiumTextSecondary)),
          ],
        ),
      );
    }

    final grouped = _groupTransactionsByDay(displayTxns);
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      color: AppColor.premiumAccent,
      onRefresh: () => vm.fetchTransactions(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(top: 8.h, bottom: 40.h),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final dateStr = dates[index];
          final dayTxns = grouped[dateStr]!;
          
          final dayTotal = dayTxns.fold<double>(
            0,
            (sum, t) => sum + (t.creditDebit == 'credit' ? t.amount : -t.amount),
          );

          final parsedDate = DateTime.parse(dateStr);
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          final targetDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

          String dayLabel;
          if (targetDate == today) {
            dayLabel = "Today";
          } else if (targetDate == yesterday) {
            dayLabel = "Yesterday";
          } else {
            dayLabel = DateFormat('dd MMMM yyyy').format(parsedDate);
          }

          final isExpanded = _expandedDates.contains(dateStr);
          final txnCount = dayTxns.length;

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: AppColor.premiumCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded
                    ? AppColor.premiumAccent.withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedDates.remove(dateStr);
                      } else {
                        _expandedDates.add(dateStr);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? AppColor.premiumAccent.withOpacity(0.12)
                                : Colors.white.withOpacity(0.04),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 16.sp,
                            color: isExpanded ? AppColor.premiumAccent : Colors.white60,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayLabel,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "$txnCount transaction${txnCount != 1 ? 's' : ''}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${dayTotal >= 0 ? '+' : '-'} ₹${dayTotal.abs().toStringAsFixed(0)}",
                              style: GoogleFonts.montserrat(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: dayTotal >= 0 ? AppColor.activeGreen : Colors.redAccent,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18.sp,
                                color: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 14.w, right: 14.w, bottom: 12.h),
                    child: Column(
                      children: [
                        const Divider(color: Colors.white10),
                        SizedBox(height: 8.h),
                        ...dayTxns.map((t) => _buildTransactionTile(t)).toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(WalletTransactionItem txn) {
    final isCredit = txn.creditDebit == 'credit';
    final amountColor = isCredit ? AppColor.activeGreen : Colors.redAccent;
    final leadingBg = amountColor.withOpacity(0.08);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: InkWell(
        onTap: () => _showTransactionReceipt(txn),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: leadingBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: amountColor,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Row(
                    children: [
                      if (txn.fromUserProfile.isNotEmpty)
                        CircleAvatar(
                          radius: 16.w,
                          backgroundImage: NetworkImage(txn.fromUserProfile),
                          onBackgroundImageError: (_, __) {},
                        )
                      else
                        CircleAvatar(
                          radius: 16.w,
                          backgroundColor: AppColor.premiumAccent.withOpacity(0.2),
                          child: Text(
                            (txn.fromUserName.isNotEmpty ? txn.fromUserName[0] : 'U').toUpperCase(),
                            style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColor.premiumAccent),
                          ),
                        ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(txn.fromUserName.isNotEmpty ? txn.fromUserName : (txn.remark ?? 'Payment'),
                              style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                            SizedBox(height: 2.h),
                            Text(
                              DateFormat('dd MMM yyyy, hh:mm a').format(txn.createdAt.toLocal()),
                              style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white30)),
                          ],
                        ),
                      ),
                    ],
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
                Text("Transaction ID", style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white.withOpacity(0.5))),
                Text("#${txn.id}", style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white70)),
              ],
            ),
            if (txn.via != null && txn.via!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Payment Method", style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white.withOpacity(0.5))),
                    Text(txn.via!, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColor.premiumAccent)),
                  ],
                ),
              ),

            Divider(color: Colors.white.withOpacity(0.08), height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isCredit ? "Credit Inflow" : "Payout Outflow", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                Text("${isCredit ? '+' : '-'} ₹${txn.amount.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w900, color: amountColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionReceipt(WalletTransactionItem txn) {
    final isCredit = txn.creditDebit == 'credit';
    final amountColor = isCredit ? AppColor.activeGreen : Colors.redAccent;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF131324),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: amountColor.withOpacity(0.12),
                    border: Border.all(color: amountColor.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    size: 40.sp,
                    color: amountColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  isCredit ? 'Payment Received' : 'Payment Sent',
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${isCredit ? "+" : "-"} ₹${txn.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    color: amountColor,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Container(width: 10.w, height: 20.h, decoration: const BoxDecoration(color: Color(0xFF131324), borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)))),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: List.generate(
                                (constraints.constrainWidth() / 10).floor(),
                                (_) => SizedBox(
                                  width: 5.w,
                                  height: 1.h,
                                  child: const DecoratedBox(decoration: BoxDecoration(color: Colors.white24)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(width: 10.w, height: 20.h, decoration: const BoxDecoration(color: Color(0xFF131324), borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      _receiptRow('Description', txn.remark ?? 'Booking Payment'),
                      _receiptRow('Transaction ID', '#${txn.id}', isCopyable: true),
                      if (txn.via != null && txn.via!.isNotEmpty)
                        _receiptRow('Payment Gateway', txn.via!),

                      _receiptRow('Type', isCredit ? 'Credit (Inflow)' : 'Debit (Outflow)'),
                      _receiptRow('Created Date & Time', DateFormat("dd MMM yyyy, hh:mm a").format(txn.createdAt)),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                AppButton(
                  text: 'Close',
                  onTap: () => Navigator.pop(context),
                  textColor: Colors.white,
                  buttonColor: AppColor.premiumAccent,
                  isIconEnabled: false,
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _receiptRow(String label, String value, {bool isCopyable = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 11.sp, color: AppColor.premiumTextSecondary, fontWeight: FontWeight.w500)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCopyable) ...[
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value.replaceAll('#', '')));
                      Utils.toastMessage("ID copied to clipboard!");
                    },
                    child: Icon(Icons.copy_rounded, size: 14.sp, color: AppColor.premiumAccent),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
