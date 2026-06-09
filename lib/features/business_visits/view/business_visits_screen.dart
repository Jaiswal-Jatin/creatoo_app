import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import '../view_model/business_visits_view_model.dart';

class BusinessVisitsScreen extends StatefulWidget {
  const BusinessVisitsScreen({super.key});

  @override
  State<BusinessVisitsScreen> createState() => _BusinessVisitsScreenState();
}

class _BusinessVisitsScreenState extends State<BusinessVisitsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessVisitsViewModel>().loadVisits();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final bool canPop = Navigator.canPop(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 5.h),
      child: Row(
        children: [
          if (canPop) ...[
            CustomBackButton(onTap: () => Navigator.pop(context)),
            SizedBox(width: 16.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  text: "CREATOO",
                  fontSize: 11.sp,
                  color: AppColor.premiumAccent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
                SizedBox(height: 2.h),
                AppTextWidget(
                  text: "Visit History",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.premiumTextPrimary,
                ),
              ],
            ),
          ),
          Consumer<BusinessVisitsViewModel>(
            builder: (context, vm, _) => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.premiumAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.premiumAccent.withOpacity(0.3)),
              ),
              child: Text(
                "${vm.totalVisits} total",
                style: GoogleFonts.montserrat(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.premiumAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search by user or card name...",
            hintStyle: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white30),
            prefixIcon: Icon(Icons.search, color: Colors.white30, size: 20.sp),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      context.read<BusinessVisitsViewModel>().setSearch('');
                    },
                    child: Icon(Icons.close, color: Colors.white30, size: 18.sp),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          ),
          onChanged: (val) {
            context.read<BusinessVisitsViewModel>().setSearch(val);
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<BusinessVisitsViewModel>(
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
                Text("Failed to load visits", style: TextStyle(color: Colors.white54)),
                SizedBox(height: 16.h),
                AppButton(text: "Retry", onTap: () => vm.loadVisits()),
              ],
            ),
          );
        }
        final byDate = vm.visitsByDate;
        if (byDate.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_outlined, color: Colors.white24, size: 64.sp),
                SizedBox(height: 16.h),
                Text("No visits found", style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white38)),
              ],
            ),
          );
        }
        final sortedDates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dayVisits = byDate[date]!;
            return _buildDateGroup(date, dayVisits);
          },
        );
      },
    );
  }

  Widget _buildDateGroup(String date, List<dynamic> dayVisits) {
    final displayDate = _formatDisplayDate(date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
          child: Text(
            displayDate,
            style: GoogleFonts.montserrat(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
            ),
          ),
        ),
        ...dayVisits.map((v) => _buildVisitCard(v as dynamic)),
      ],
    );
  }

  String _formatDisplayDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      final dt = DateTime(year, month, day);
      return "${days[dt.weekday - 1]}, ${months[month]} $day, $year";
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildVisitCard(dynamic visit) {
    final isPremium = visit.tier == 'premium';
    final isNew = visit.tier == 'new';
    final isElite = visit.tier == 'elite';
    Color tierColor = Colors.white38;
    String tierLabel = visit.tier;
    if (isPremium) { tierColor = AppColor.premiumAccent; tierLabel = "PREMIUM"; }
    else if (isElite) { tierColor = AppColor.mangoYellow; tierLabel = "ELITE"; }
    else if (isNew) { tierColor = AppColor.activeGreen; tierLabel = "NEW"; }
    else { tierColor = Colors.blueAccent; tierLabel = "CORE"; }

    final timeStr = _extractTime(visit.time);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: visit.userImage != null ? NetworkImage(visit.userImage!) : null,
            child: visit.userImage == null
                ? Icon(Icons.person, color: Colors.white38, size: 20.sp)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.userName ?? visit.cardName ?? "User",
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (visit.userMobile != null)
                  Text(
                    visit.userMobile!,
                    style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white38),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white38),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tierLabel,
                  style: TextStyle(color: tierColor, fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _extractTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length >= 2) {
        final timeParts = parts[1].split(':');
        if (timeParts.length >= 2) {
          int h = int.parse(timeParts[0]);
          final ampm = h >= 12 ? 'PM' : 'AM';
          if (h > 12) h -= 12;
          if (h == 0) h = 12;
          return "${h.toString().padLeft(2, '0')}:${timeParts[1]} $ampm";
        }
      }
      return timeStr;
    } catch (_) {
      return timeStr;
    }
  }
}
