import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../view_model/business_wallet_earning_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessWalletCalendar extends StatefulWidget {
  final BusinessWalletEarningViewModel viewModel;

  const BusinessWalletCalendar({super.key, required this.viewModel});

  @override
  State<BusinessWalletCalendar> createState() => _BusinessWalletCalendarState();
}

class _BusinessWalletCalendarState extends State<BusinessWalletCalendar> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        selectedDayPredicate: (day) {
          if (widget.viewModel.selectedDate == null) return false;
          return isSameDay(widget.viewModel.selectedDate, day);
        },
        eventLoader: (day) {
          // Return list with one item if this date has transactions
          DateTime normalizedDate = DateTime(day.year, day.month, day.day);
          if (widget.viewModel.transactionDates.contains(normalizedDate)) {
            return [1]; // Non-empty list indicates events
          }
          return [];
        },
        onDaySelected: (selectedDay, fDay) {
          setState(() {
            focusedDay = fDay;
          });
          widget.viewModel.selectDate(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            calendarFormat = format;
          });
        },
        onPageChanged: (fDay) {
          setState(() {
            focusedDay = fDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          markerSize: 7.0,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          weekendStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.red),
        ),
        calendarBuilders: CalendarBuilders(
          // Add dot indicator below dates with transactions
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
