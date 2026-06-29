import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:creatoo/core.dart';
import '../model/business_settlement_model.dart';
import '../view_model/settlement_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

class BusinessWalletSettlementsTab extends StatefulWidget {
  const BusinessWalletSettlementsTab({super.key});

  @override
  State<BusinessWalletSettlementsTab> createState() => _BusinessWalletSettlementsTabState();
}

class _BusinessWalletSettlementsTabState extends State<BusinessWalletSettlementsTab> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettlementViewModel>().fetchSettlementsTabData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettlementViewModel>();
    final data = vm.combinedSettlement;
    final records = vm.allRecords;

    String dateText = "All Time";
    if (_selectedDate != null) {
      dateText = DateFormat('dd MMM yyyy').format(_selectedDate!);
    }

    final recordDates = records
        .map((r) {
          try { return r.createdAt.length >= 10 ? r.createdAt.substring(0, 10) : ''; }
          catch (_) { return ''; }
        })
        .where((d) => d.isNotEmpty)
        .toSet();

    if (vm.isLoadingSettlement && data == null) {
      return Center(child: CircularProgressIndicator(color: AppColor.premiumAccent));
    }

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 8.h, bottom: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(data),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Settlement History",
                  style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => _showCalendarDialog(vm, recordDates),
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
                        Text(dateText, style: GoogleFonts.montserrat(fontSize: 9.sp, fontWeight: FontWeight.w700, color: Colors.white70)),
                        SizedBox(width: 4.w),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 14.sp, color: Colors.white60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_selectedDate != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GestureDetector(
                  onTap: () {
                    setState(() { _selectedDate = null; });
                    vm.fetchSettlementsTabData();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColor.premiumAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColor.premiumAccent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel_rounded, size: 14.sp, color: AppColor.premiumAccent),
                        SizedBox(width: 4.w),
                        Text('Clear Filter', style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColor.premiumAccent)),
                      ],
                    ),
                  ),
                ),
              ),
            if (records.isEmpty)
              Container(
                width: double.infinity, padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Text("No settlement records found",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white38)),
              )
            else
              ...records.map((r) => _buildRecordTile(r)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CombinedSettlementData? data) {
    final d = data ?? CombinedSettlementData();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity, padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.premiumAccent.withOpacity(0.15), AppColor.premiumAccent.withOpacity(0.05)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.premiumAccent.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text("Total Settlement", style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white70)),
              SizedBox(height: 8.h),
              Text("₹${d.settledAmount.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 28.sp, fontWeight: FontWeight.w900, color: const Color(0xFF4CAF50))),
              SizedBox(height: 4.h),
              Text("Pending: ₹${d.pendingAmount.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColor.mangoYellow)),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text("Pending Bill", style: GoogleFonts.montserrat(fontSize: 9.sp, color: Colors.white38)),
                        SizedBox(height: 2.h),
                        Text("₹${d.billPending.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColor.mangoYellow)),
                      ],
                    ),
                    Container(width: 1, height: 30, color: Colors.white10),
                    Column(
                      children: [
                        Text("Pending Booking", style: GoogleFonts.montserrat(fontSize: 9.sp, color: Colors.white38)),
                        SizedBox(height: 2.h),
                        Text("₹${d.bookingPending.toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.orangeAccent)),
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

  Widget _buildRecordTile(SettlementRecordItem r) {
    final hasBill = r.billAmount > 0;
    final hasBooking = r.bookingAmount > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h), padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_circle_rounded, color: const Color(0xFF4CAF50), size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("₹${r.amount.toStringAsFixed(0)} settled", style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 2.h),
                    Text(_fmt(r.createdAt), style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white38)),
                  ],
                ),
              ),
            ],
          ),
          if (hasBill || hasBooking) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                if (hasBill)
                  _chip("Bill: ₹${r.billAmount.toStringAsFixed(0)}", AppColor.mangoYellow),
                if (hasBill && hasBooking) SizedBox(width: 8.w),
                if (hasBooking)
                  _chip("Booking: ₹${r.bookingAmount.toStringAsFixed(0)}", Colors.orangeAccent),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color)),
    );
  }

  String _fmt(String d) {
    try {
      final dt = DateTime.parse(d);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
    } catch (_) {
      return d.length >= 16 ? d.substring(0, 16) : d;
    }
  }

  void _showCalendarDialog(SettlementViewModel vm, Set<String> dates) {
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
                  margin: EdgeInsets.all(24.w), padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColor.premiumCardBg, borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Select Date", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          IconButton(icon: Icon(Icons.close_rounded, color: Colors.white60, size: 20.sp), onPressed: () => Navigator.pop(dialogContext)),
                        ],
                      ),
                      const Divider(color: Colors.white10),
                      SizedBox(height: 8.h),
                      TableCalendar(
                        firstDay: DateTime.utc(2024, 1, 1),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            if (isSameDay(_selectedDate, selectedDay)) {
                              _selectedDate = null;
                              vm.fetchSettlementsTabData();
                            } else {
                              _selectedDate = selectedDay;
                              final fromStr = DateFormat('yyyy-MM-dd').format(selectedDay);
                              vm.fetchSettlementsTabData(fromDate: fromStr, toDate: fromStr);
                            }
                            _focusedDay = focusedDay;
                          });
                          setStateDialog(() {});
                          Navigator.pop(dialogContext);
                        },
                        onFormatChanged: (format) { setState(() => _calendarFormat = format); setStateDialog(() {}); },
                        onPageChanged: (focusedDay) { setState(() => _focusedDay = focusedDay); },
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: GoogleFonts.montserrat(color: Colors.white70, fontSize: 11.sp),
                          weekendTextStyle: GoogleFonts.montserrat(color: Colors.redAccent.withOpacity(0.8), fontSize: 11.sp),
                          outsideTextStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 11.sp),
                          todayDecoration: BoxDecoration(color: AppColor.premiumAccent.withOpacity(0.15), shape: BoxShape.circle),
                          todayTextStyle: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontWeight: FontWeight.bold, fontSize: 11.sp),
                          selectedDecoration: const BoxDecoration(color: AppColor.premiumAccent, shape: BoxShape.circle),
                          selectedTextStyle: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp),
                        ),
                        headerStyle: HeaderStyle(
                          titleCentered: true, titleTextStyle: GoogleFonts.montserrat(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          leftChevronIcon: Icon(Icons.chevron_left_rounded, color: AppColor.premiumAccent, size: 20.sp),
                          rightChevronIcon: Icon(Icons.chevron_right_rounded, color: AppColor.premiumAccent, size: 20.sp),
                          formatButtonVisible: true, formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                          formatButtonTextStyle: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontSize: 9.sp, fontWeight: FontWeight.bold),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: GoogleFonts.montserrat(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w600),
                          weekendStyle: GoogleFonts.montserrat(color: Colors.redAccent.withOpacity(0.5), fontSize: 10.sp, fontWeight: FontWeight.w600),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final dateStr = DateFormat('yyyy-MM-dd').format(date);
                            if (dates.contains(dateStr)) {
                              return Positioned(bottom: 4.h, child: Container(width: 5.w, height: 5.h, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)));
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack), child: FadeTransition(opacity: anim1, child: child));
      },
    );
  }
}
