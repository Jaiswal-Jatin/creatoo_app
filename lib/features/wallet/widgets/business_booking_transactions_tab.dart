import 'package:creatoo/core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/settlement_response_model.dart';
import '../view_model/settlement_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

class BusinessBookingTransactionsTab extends StatefulWidget {
  const BusinessBookingTransactionsTab({super.key});

  @override
  State<BusinessBookingTransactionsTab> createState() => _BusinessBookingTransactionsTabState();
}

class _BusinessBookingTransactionsTabState extends State<BusinessBookingTransactionsTab> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final Set<String> _expandedDates = {};
  bool _isCalendarExpanded = false;
  int _settlementFilter = 0; // 0 = All, 1 = Unsettled, 2 = Settled

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SettlementViewModel>();
      vm.fetchSummary();
      vm.fetchTransactions();
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

    final allTxns = txns;
    final unsettledTxns = txns.where((t) => t.settlementStatus == 'pending').toList();
    final settledTxns = txns.where((t) => t.settlementStatus == 'settled').toList();
    final displayTxns = _settlementFilter == 0 ? allTxns
        : _settlementFilter == 1 ? unsettledTxns
        : settledTxns;

    final settledAmount = displayTxns.where((t) => t.settlementStatus == 'settled').fold<double>(0, (sum, t) => sum + t.amount);
    final unsettledAmount = displayTxns.where((t) => t.settlementStatus == 'pending').fold<double>(0, (sum, t) => sum + t.amount);

    final transactionDates = txns
        .map((t) => DateFormat('yyyy-MM-dd').format(t.createdAt))
        .toSet();

    String dateText = "All Time";
    if (_selectedDate != null) {
      dateText = DateFormat('dd MMM yyyy').format(_selectedDate!);
    }

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningCard(settledAmount, unsettledAmount, dateText, vm, transactionDates),
          SizedBox(height: 16.h),
          _buildSubFilter(txns.length, unsettledTxns.length, settledTxns.length),
          SizedBox(height: 12.h),
          _buildTransactionsHeader(vm),
          SizedBox(height: 10.h),
          Expanded(child: _buildTransactionList(vm, displayTxns)),
        ],
      ),
    );
  }

  void _showCalendarDialog(SettlementViewModel vm, Set<String> transactionDates) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "CalendarDialog",
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (dialogContext, setStateDialog) {
                return Container(
                  margin: EdgeInsets.all(24.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColor.premiumCardBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Date",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: Colors.white60, size: 20.sp),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10),
                      SizedBox(height: 8.h),
                      TableCalendar(
                        firstDay: DateTime.utc(2024, 1, 1),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDate, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            if (isSameDay(_selectedDate, selectedDay)) {
                              _selectedDate = null;
                              vm.fetchTransactions();
                            } else {
                              _selectedDate = selectedDay;
                              final fromStr = DateFormat('yyyy-MM-dd').format(selectedDay);
                              vm.fetchTransactions(
                                fromDate: fromStr,
                                toDate: fromStr,
                              );
                            }
                            _focusedDay = focusedDay;
                          });
                          setStateDialog(() {});
                          Navigator.pop(dialogContext);
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                          setStateDialog(() {});
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: GoogleFonts.montserrat(color: Colors.white70, fontSize: 11.sp),
                          weekendTextStyle: GoogleFonts.montserrat(color: Colors.redAccent.withOpacity(0.8), fontSize: 11.sp),
                          outsideTextStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 11.sp),
                          todayDecoration: BoxDecoration(
                            color: AppColor.premiumAccent.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontWeight: FontWeight.bold, fontSize: 11.sp),
                          selectedDecoration: const BoxDecoration(
                            color: AppColor.premiumAccent,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp),
                        ),
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          titleTextStyle: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          leftChevronIcon: Icon(Icons.chevron_left_rounded, color: AppColor.premiumAccent, size: 20.sp),
                          rightChevronIcon: Icon(Icons.chevron_right_rounded, color: AppColor.premiumAccent, size: 20.sp),
                          formatButtonVisible: true,
                          formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          formatButtonTextStyle: GoogleFonts.montserrat(
                            color: AppColor.premiumAccent,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: GoogleFonts.montserrat(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w600),
                          weekendStyle: GoogleFonts.montserrat(color: Colors.redAccent.withOpacity(0.5), fontSize: 10.sp, fontWeight: FontWeight.w600),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final dateStr = DateFormat('yyyy-MM-dd').format(date);
                            if (transactionDates.contains(dateStr)) {
                              return Positioned(
                                bottom: 4.h,
                                child: Container(
                                  width: 5.w,
                                  height: 5.h,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                              });
                              vm.fetchTransactions();
                              Navigator.pop(dialogContext);
                            },
                            child: Text(
                              "Clear Filter",
                              style: GoogleFonts.montserrat(
                                color: AppColor.premiumAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.premiumAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              "Done",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildEarningCard(
    double settledAmount,
    double unsettledAmount,
    String dateText,
    SettlementViewModel vm,
    Set<String> transactionDates,
  ) {
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
                            "Total Settled",
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "₹ ${settledAmount.toCommaSeparated()}",
                            style: GoogleFonts.montserrat(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          _showCalendarDialog(vm, transactionDates);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_month_rounded, size: 12.sp, color: AppColor.premiumAccent),
                              SizedBox(width: 4.w),
                              Text(
                                dateText,
                                style: GoogleFonts.montserrat(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14.sp,
                                color: Colors.white60,
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildSubFilter(int total, int unsettledCount, int settledCount) {
    final labels = [
      "All ($total)",
      "Unsettled ($unsettledCount)",
      "Settled ($settledCount)",
    ];
    return Row(
      children: List.generate(3, (i) {
        final sel = _settlementFilter == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _settlementFilter = i),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: sel ? AppColor.premiumAccent.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? AppColor.premiumAccent : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: sel ? AppColor.premiumAccent : Colors.white60,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTransactionsHeader(SettlementViewModel vm) {
    final headerLabels = ["Booking Transactions", "Unsettled Payments", "Settled Payments"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          headerLabels[_settlementFilter],
          style: GoogleFonts.montserrat(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        if (_selectedDate != null)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = null;
              });
              vm.fetchTransactions();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.premiumAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColor.premiumAccent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel_rounded,
                    size: 14.sp,
                    color: AppColor.premiumAccent,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Clear Filter',
                    style: GoogleFonts.montserrat(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.premiumAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
            Text(
              _settlementFilter == 0 ? 'No booking transactions found'
                  : _settlementFilter == 1 ? 'No unsettled payments'
                  : 'No settled payments',
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

  Widget _buildSettlementBadge(String status) {
    final isSettled = status == 'settled';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isSettled
            ? AppColor.activeGreen.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSettled
              ? AppColor.activeGreen.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        isSettled ? "SETTLED" : "UNSETTLED",
        style: GoogleFonts.montserrat(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: isSettled ? AppColor.activeGreen : Colors.orange,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTransactionTile(WalletTransactionItem txn) {
    final isSettled = txn.isSettled;
    final isCredit = txn.creditDebit == 'credit';
    final statusColor = isSettled ? AppColor.activeGreen : Colors.orange;
    final amountColor = isCredit ? AppColor.activeGreen : Colors.redAccent;
    final leadingBg = amountColor.withOpacity(0.08);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSettled 
              ? AppColor.activeGreen.withOpacity(0.2) 
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
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
                SizedBox(width: 8.w),
                _buildSettlementBadge(txn.settlementStatus),
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
    final isSettled = txn.isSettled;
    final isCredit = txn.creditDebit == 'credit';
    final statusColor = isSettled ? AppColor.activeGreen : Colors.orange;
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
                    color: statusColor.withOpacity(0.12),
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(
                    isSettled ? Icons.check_circle_rounded : Icons.pending_rounded,
                    size: 40.sp,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  isSettled ? 'Transaction Settled' : 'Settlement Pending',
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
                      _receiptRow('Settlement Status', isSettled ? 'Settled' : 'Pending'),
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
