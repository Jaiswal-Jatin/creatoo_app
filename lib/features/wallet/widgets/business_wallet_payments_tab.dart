import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/business_payments/model/manual_payment_model.dart';
import 'package:creatoo/features/business_payments/view_model/business_payments_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

class BusinessWalletPaymentsTab extends StatefulWidget {
  const BusinessWalletPaymentsTab({super.key});

  @override
  State<BusinessWalletPaymentsTab> createState() => _BusinessWalletPaymentsTabState();
}

class _BusinessWalletPaymentsTabState extends State<BusinessWalletPaymentsTab> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final Set<String> _expandedDates = {};
  bool _isCalendarExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<BusinessPaymentsViewModel>();
      vm.loadPayments();
    });
  }

  List<ManualPayment> _getFilteredPayments(List<ManualPayment> allPayments) {
    if (_selectedDate != null) {
      final target = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      return allPayments.where((p) {
        final date = DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day);
        return date.isAtSameMomentAs(target);
      }).toList();
    }
    return allPayments;
  }

  Map<String, List<ManualPayment>> _groupPaymentsByDay(List<ManualPayment> payments) {
    final Map<String, List<ManualPayment>> groups = {};
    for (final p in payments) {
      final dateStr = DateFormat('yyyy-MM-dd').format(p.createdAt);
      if (!groups.containsKey(dateStr)) {
        groups[dateStr] = [];
      }
      groups[dateStr]!.add(p);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessPaymentsViewModel>(
      builder: (context, vm, _) {
        final allPayments = vm.payments;
        double todayTotal = 0;
        double lifetimeTotal = 0;

        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);

        for (final p in allPayments) {
          if (p.status == 'CONFIRMED') {
            lifetimeTotal += p.finalAmount;
            if (!p.createdAt.isBefore(todayStart)) {
              todayTotal += p.finalAmount;
            }
          }
        }

        final filteredPayments = _getFilteredPayments(allPayments);

        final paymentDates = allPayments
            .map((p) => DateFormat('yyyy-MM-dd').format(p.createdAt))
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
              _buildEarningCard(lifetimeTotal, todayTotal, dateText, vm, paymentDates),
              SizedBox(height: 16.h),
              _buildTransactionsHeader(vm),
              SizedBox(height: 10.h),
              Expanded(child: _buildGroupedPaymentList(vm, filteredPayments)),
            ],
          ),
        );
      },
    );
  }

  void _showCalendarDialog(BusinessPaymentsViewModel vm, Set<String> paymentDates) {
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
                            } else {
                              _selectedDate = selectedDay;
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
                            if (paymentDates.contains(dateStr)) {
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
    double totalAmount,
    double dailyAmount,
    String dateText,
    BusinessPaymentsViewModel vm,
    Set<String> paymentDates,
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
                            "Total Earnings",
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "₹ ${totalAmount.toStringAsFixed(0)}",
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
                          _showCalendarDialog(vm, paymentDates);
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
                            "Today's Earnings",
                            style: GoogleFonts.montserrat(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "₹ ${dailyAmount.toStringAsFixed(0)}",
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.premiumAccent,
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

  Widget _buildTransactionsHeader(BusinessPaymentsViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "UPI Transactions",
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

  Widget _buildGroupedPaymentList(BusinessPaymentsViewModel vm, List<ManualPayment> paymentsList) {
    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.premiumAccent));
    }

    if (paymentsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, size: 60.sp, color: AppColor.premiumTextSecondary.withOpacity(0.3)),
            SizedBox(height: 12.h),
            Text('No payments found', style: GoogleFonts.montserrat(fontSize: 14.sp, color: AppColor.premiumTextSecondary)),
          ],
        ),
      );
    }

    final grouped = _groupPaymentsByDay(paymentsList);
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      color: AppColor.premiumAccent,
      onRefresh: () => vm.loadPayments(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(top: 8.h, bottom: 40.h),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final dateStr = dates[index];
          final dayPayments = grouped[dateStr]!;
          
          final dayTotal = dayPayments.fold<double>(
            0,
            (sum, p) => sum + (p.status == 'CONFIRMED' ? p.finalAmount : 0),
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
          final paymentCount = dayPayments.length;

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
                                "$paymentCount payment${paymentCount != 1 ? 's' : ''}",
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
                              "₹ ${dayTotal.toStringAsFixed(0)}",
                              style: GoogleFonts.montserrat(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColor.premiumAccent,
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
                        ...dayPayments.map((p) => _buildPaymentTile(p)).toList(),
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

  Widget _buildInitialsAvatar(String name, bool isConfirmed) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white.withOpacity(0.06),
      child: Text(
        name.isEmpty ? 'C' : name[0].toUpperCase(),
        style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColor.premiumAccent),
      ),
    );
  }

  Widget _buildPaymentTile(ManualPayment p) {
    final isPending = p.status == 'PENDING';
    final isConfirmed = p.status == 'CONFIRMED';
    final name = p.userName ?? "Customer";
    final timeStr = DateFormat("dd MMM yyyy, hh:mm a").format(p.createdAt);
    final discountPct = p.discountPercentage;
    final discountAmt = p.discountAmount ?? 0.0;
    final points = p.pointsRedeemed;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending 
              ? AppColor.mangoYellow.withOpacity(0.3) 
              : isConfirmed 
                  ? AppColor.activeGreen.withOpacity(0.2) 
                  : Colors.redAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showPaymentReceipt(p),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: p.userImage != null && p.userImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: p.userImage!.startsWith('http')
                              ? p.userImage!
                              : 'https://creatoos3.blr1.digitaloceanspaces.com/images/${p.userImage!.startsWith('/') ? p.userImage!.substring(1) : p.userImage!}',
                          width: 40.w,
                          height: 40.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 40.w,
                            height: 40.w,
                            color: Colors.white.withOpacity(0.05),
                            child: Center(
                              child: SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColor.premiumAccent),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildInitialsAvatar(name, isConfirmed),
                        )
                      : _buildInitialsAvatar(name, isConfirmed),
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
                _buildStatusBadge(p.status),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: Colors.white.withOpacity(0.06), height: 1),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Bill Amount", style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white.withOpacity(0.5))),
                Text("₹${p.billAmount.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white70)),
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
                    Text("-₹${p.pointsValue.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColor.mangoYellow)),
                  ],
                ),
              ),
            Divider(color: Colors.white.withOpacity(0.08), height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Received", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                Text("₹${p.finalAmount.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentReceipt(ManualPayment p) {
    final isConfirmed = p.status == 'CONFIRMED';
    final statusColor = isConfirmed ? AppColor.activeGreen : Colors.orange;
    
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
                    isConfirmed ? Icons.check_circle_rounded : Icons.pending_rounded,
                    size: 40.sp,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  isConfirmed ? 'Payment Confirmed' : 'Payment Pending',
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '₹${p.finalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    color: isConfirmed ? AppColor.activeGreen : Colors.orange,
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
                      _receiptRow('Customer Name', p.userName ?? 'User'),
                      if (p.userMobile != null && p.userMobile!.isNotEmpty)
                        _receiptRow('Mobile Number', p.userMobile!),
                      _receiptRow('Payment ID', '#${p.id}', isCopyable: true),
                      _receiptRow('Payment Method', p.paymentMethod),
                      _receiptRow('Date & Time', DateFormat("dd MMM yyyy, hh:mm a").format(p.createdAt)),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Billing Summary',
                        style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColor.premiumAccent),
                      ),
                      const Divider(color: Colors.white10),
                      _billingRow('Bill Amount', '₹${p.billAmount.toStringAsFixed(2)}'),
                      if (p.discountAmount != null && p.discountAmount! > 0)
                        _billingRow(
                          'Discount (${p.discountPercentage ?? 0}%)', 
                          '-₹${p.discountAmount!.toStringAsFixed(2)}',
                          isNegative: true,
                        ),
                      if (p.pointsRedeemed > 0)
                        _billingRow(
                          'Points Value (${p.pointsRedeemed} pts)', 
                          '-₹${p.pointsValue.toStringAsFixed(2)}',
                          isNegative: true,
                        ),
                      const Divider(color: Colors.white24),
                      _billingRow(
                        'Total Paid', 
                        '₹${p.finalAmount.toStringAsFixed(2)}', 
                        isBold: true,
                        color: AppColor.activeGreen,
                      ),
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

  Widget _billingRow(String label, String value, {bool isNegative = false, bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11.sp,
              color: isBold ? Colors.white : AppColor.premiumTextSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: isBold ? 14.sp : 11.sp,
              color: color ?? (isNegative ? Colors.orangeAccent : Colors.white),
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
