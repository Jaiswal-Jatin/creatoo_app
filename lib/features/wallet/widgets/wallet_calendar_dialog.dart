import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:creatoo/core.dart';
import '../view_model/wallet_view_model.dart';

class WalletCalendarDialog extends StatefulWidget {
  final WalletViewModel viewModel;
  final Function(DateTime, DateTime) onDateRangeSelected;

  const WalletCalendarDialog({
    super.key,
    required this.viewModel,
    required this.onDateRangeSelected,
  });

  @override
  State<WalletCalendarDialog> createState() => _WalletCalendarDialogState();
}

class _WalletCalendarDialogState extends State<WalletCalendarDialog> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? rangeStart;
  DateTime? rangeEnd;
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();
    rangeStart = widget.viewModel.selectedDate;
    rangeEnd = widget.viewModel.selectedEndDate;
    if (rangeStart != null) {
      focusedDay = rangeStart!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Date Range',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            // Show selected range
            if (rangeStart != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  rangeEnd != null && rangeStart != rangeEnd
                      ? '${_formatDate(rangeStart!)} - ${_formatDate(rangeEnd!)}'
                      : _formatDate(rangeStart!),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(height: 10),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              calendarFormat: calendarFormat,
              rangeSelectionMode: rangeSelectionMode,
              rangeStartDay: rangeStart,
              rangeEndDay: rangeEnd,
              selectedDayPredicate: (day) {
                // For single day selection when no range
                if (rangeEnd == null && rangeStart != null) {
                  return isSameDay(rangeStart, day);
                }
                return false;
              },
              eventLoader: (day) {
                // Return list with one item if this date has transactions
                DateTime normalizedDate = DateTime(day.year, day.month, day.day);
                if (widget.viewModel.transactionDates.contains(normalizedDate)) {
                  return [1]; // Non-empty list indicates events
                }
                return [];
              },
              onDaySelected: (selected, focused) {
                // Single tap for single date
                setState(() {
                  rangeStart = selected;
                  rangeEnd = null;
                  focusedDay = focused;
                  rangeSelectionMode = RangeSelectionMode.toggledOn;
                });
              },
              onRangeSelected: (start, end, focused) {
                setState(() {
                  rangeStart = start;
                  rangeEnd = end;
                  focusedDay = focused;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  calendarFormat = format;
                });
              },
              onPageChanged: (focused) {
                focusedDay = focused;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: Colors.purple.withOpacity(0.2),
                withinRangeDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerSize: 6.0,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.purple),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.purple),
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
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (rangeStart != null) {
                      widget.onDateRangeSelected(
                        rangeStart!, 
                        rangeEnd ?? rangeStart!,
                      );
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: Text('Select', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')}-${months[date.month - 1]}-${date.year}';
  }
}
