import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import '../model/booking_model.dart';
import '../view_model/booking_view_model.dart';

class BusinessBookingsScreen extends StatefulWidget {
  const BusinessBookingsScreen({super.key});

  @override
  State<BusinessBookingsScreen> createState() => _BusinessBookingsScreenState();
}

class _BusinessBookingsScreenState extends State<BusinessBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingViewModel>().loadBusinessBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            _buildStats(),
            _buildTabs(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final bool canPop = Navigator.canPop(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (canPop) ...[
            CustomBackButton(onTap: () => Navigator.pop(context)),
            SizedBox(width: 14.w),
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
                  text: "Booking Requests",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.premiumTextPrimary,
                ),
              ],
            ),
          ),
          Consumer<BookingViewModel>(
            builder: (_, vm, __) => vm.pendingBookingsCount > 0
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColor.mangoYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.mangoYellow.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${vm.pendingBookingsCount} pending',
                      style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColor.mangoYellow),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(width: 6.w),
          Consumer<BookingViewModel>(
            builder: (_, vm, __) => IconButton(
              icon: Icon(Icons.refresh_rounded, color: Colors.white38, size: 22.sp),
              onPressed: () => vm.loadBusinessBookings(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Consumer<BookingViewModel>(
      builder: (context, vm, _) {
        final all = vm.businessBookings;
        final pending = all.where((b) => b.status == 'pending').length;
        final accepted = all.where((b) => b.status == 'accepted').length;
        final rejected = all.where((b) => b.status == 'rejected').length;
        final cancelled = all.where((b) => b.status == 'cancelled').length;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Row(
            children: [
              _statCard('Pending', '$pending', AppColor.mangoYellow),
              SizedBox(width: 6.w),
              _statCard('Confirmed', '$accepted', AppColor.activeGreen),
              SizedBox(width: 6.w),
              _statCard('Rejected', '$rejected', Colors.red.shade400),
              SizedBox(width: 6.w),
              _statCard('Cancelled', '$cancelled', Colors.grey.shade400),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w800, color: color)),
            SizedBox(height: 2.h),
            Text(label, style: GoogleFonts.montserrat(fontSize: 8.sp, color: color.withOpacity(0.7), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColor.premiumAccent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColor.premiumAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w500),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white30,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Rejected'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<BookingViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColor.premiumAccent));
        }
        if (vm.error != null) {
          return _buildError(vm);
        }
        return TabBarView(
          controller: _tabController,
          children: [
            _buildBookingList(vm.businessBookings.where((b) => b.status == 'pending').toList(), isPending: true),
            _buildBookingList(vm.businessBookings.where((b) => b.status == 'accepted').toList()),
            _buildBookingList(vm.businessBookings.where((b) => b.status == 'rejected').toList()),
            _buildBookingList(vm.businessBookings.where((b) => b.status == 'cancelled').toList()),
          ],
        );
      },
    );
  }

  Widget _buildError(BookingViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.white24, size: 48.sp),
          SizedBox(height: 16.h),
          Text('Failed to load bookings', style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 14.sp)),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => vm.loadBusinessBookings(),
            child: Text('Retry', style: GoogleFonts.montserrat(color: AppColor.premiumAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, {bool isPending = false}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_outlined, color: Colors.white24, size: 50.sp),
            SizedBox(height: 16.h),
            Text('No bookings found', style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white38, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _buildBookingCard(bookings[index], showActions: isPending),
    );
  }

  String _categoryEmoji(String cat) {
    switch (cat) {
      case 'salon':
        return '💇';
      case 'turf':
        return '⚽';
      default:
        return '🍽️';
    }
  }

  Color _categoryColor(String cat) {
    return AppColor.premiumAccent;
  }

  Widget _buildBookingCard(BookingModel booking, {bool showActions = false}) {
    final catColor = _categoryColor(booking.businessCategory);
    final user = booking.user;
    final statusColor = booking.status == 'accepted'
        ? AppColor.activeGreen
        : booking.status == 'rejected'
            ? Colors.red.shade400
            : booking.status == 'cancelled'
                ? Colors.grey.shade400
                : AppColor.mangoYellow;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showActions
              ? AppColor.mangoYellow.withOpacity(0.2)
              : statusColor.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── User + Date/Time ───
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
            child: Row(
              children: [
                _userAvatar(user),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Customer',
                        style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user?.mobile != null)
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(user!.mobile!, style: GoogleFonts.montserrat(fontSize: 10.5.sp, color: Colors.white38, fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      booking.bookingDate,
                      style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatTime(booking.bookingTime),
                      style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w800, color: AppColor.premiumAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.white.withOpacity(0.04), height: 1),

          // ─── Details ───
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                _infoChip(_categoryEmoji(booking.businessCategory), booking.businessCategory.toUpperCase(), catColor),
                if (booking.serviceName != null)
                  _infoChip('✂️', booking.serviceName!, AppColor.premiumAccent),
                if (booking.sportName != null)
                  _infoChip('🏃', booking.sportName!, AppColor.premiumAccent),
                if (booking.guestsCount != null)
                  _infoChip('👥', '${booking.guestsCount} people', Colors.white54),
              ],
            ),
          ),
          if (booking.notes != null && booking.notes!.trim().isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
              child: Text(
                '📝 ${booking.notes}',
                style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white30, fontStyle: FontStyle.italic),
              ),
            ),
            SizedBox(height: 8.h),
          ],

          // ─── Rejection / Cancellation Reason ───
          if ((booking.status == 'rejected' || booking.status == 'cancelled') && booking.rejectionReason != null && booking.rejectionReason!.trim().isNotEmpty) ...[
            Divider(color: Colors.white.withOpacity(0.04), height: 1),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              color: statusColor.withOpacity(0.02),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: statusColor,
                    size: 13.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${booking.status == 'cancelled' ? 'Cancellation' : 'Rejection'} Reason: "${booking.rejectionReason}"',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.sp,
                        color: statusColor.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ─── Advance Payment Pending Badge ───
          if (booking.needsAdvancePayment) ...[
            Divider(color: Colors.white.withOpacity(0.04), height: 1),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              color: AppColor.mangoYellow.withOpacity(0.02),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColor.mangoYellow.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '⏳ ADVANCE PENDING',
                      style: GoogleFonts.montserrat(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mangoYellow,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Advance of ₹${booking.advanceAmount!.toStringAsFixed(0)} requested — awaiting customer payment',
                      style: GoogleFonts.montserrat(
                        fontSize: 10.sp,
                        color: Colors.white54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ─── Action Buttons (pending only, hide if advance requested) ───
          if (showActions && !booking.needsAdvancePayment) ...[
            Divider(color: Colors.white.withOpacity(0.04), height: 1),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      label: 'Reject',
                      icon: Icons.close_rounded,
                      color: Colors.red.shade400,
                      onTap: () => _showRejectDialog(booking),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _actionButton(
                      label: 'Accept',
                      icon: Icons.check_rounded,
                      color: AppColor.activeGreen,
                      onTap: () => _showAcceptDialog(booking),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(height: 4.h),
          ],
        ],
      ),
    );
  }

  Widget _userAvatar(BookingUser? user) {
    return CircleAvatar(
      radius: 20.w,
      backgroundColor: Colors.white.withOpacity(0.04),
      backgroundImage: user?.userImage != null ? NetworkImage(user!.userImage!) : null,
      child: user?.userImage == null
          ? Icon(Icons.person_rounded, color: Colors.white38, size: 18.sp)
          : null,
    );
  }

  Widget _infoChip(String emoji, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Text(
        '$emoji $label',
        style: GoogleFonts.montserrat(fontSize: 10.5.sp, color: Colors.white70, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14.sp),
            SizedBox(width: 6.w),
            Text(label, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptBooking(BookingModel booking, {double? advanceAmount}) async {
    final vm = context.read<BookingViewModel>();
    final success = await vm.updateBookingStatus(
      bookingId: booking.id,
      status: 'accepted',
      advanceAmount: advanceAmount,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (advanceAmount != null && advanceAmount > 0
                  ? '✅ Booking confirmed! Advance of ₹${advanceAmount.toStringAsFixed(0)} requested.'
                  : '✅ Booking confirmed!')
              : (vm.error ?? 'Failed'),
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: success ? AppColor.activeGreen : Colors.red.shade700,
      ),
    );
  }

  void _showAcceptDialog(BookingModel booking) {
    final amountController = TextEditingController();
    bool withAdvance = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColor.premiumCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          title: Text(
            'Accept Booking',
            style: GoogleFonts.montserrat(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Would you like to request an advance payment from the customer?',
                style: GoogleFonts.montserrat(
                  fontSize: 12.5.sp,
                  color: Colors.white60,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 10.h),
              // ─── Tip Banner ───
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: AppColor.mangoYellow.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColor.mangoYellow.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColor.mangoYellow,
                      size: 14.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Tip: Request only a partial advance (e.g. 20–30% of the expected bill) as a booking deposit — not the full amount. This builds trust and encourages customers to confirm.',
                        style: GoogleFonts.montserrat(
                          fontSize: 10.5.sp,
                          color: AppColor.mangoYellow.withOpacity(0.85),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // ─── Option Buttons ───
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => withAdvance = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                        decoration: BoxDecoration(
                          color: !withAdvance
                              ? AppColor.activeGreen.withOpacity(0.12)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !withAdvance
                                ? AppColor.activeGreen.withOpacity(0.5)
                                : Colors.white.withOpacity(0.07),
                            width: !withAdvance ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: !withAdvance ? AppColor.activeGreen : Colors.white24,
                              size: 20.sp,
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Without\nAdvance',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: !withAdvance ? AppColor.activeGreen : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => withAdvance = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                        decoration: BoxDecoration(
                          color: withAdvance
                              ? AppColor.mangoYellow.withOpacity(0.12)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: withAdvance
                                ? AppColor.mangoYellow.withOpacity(0.5)
                                : Colors.white.withOpacity(0.07),
                            width: withAdvance ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.currency_rupee_rounded,
                              color: withAdvance ? AppColor.mangoYellow : Colors.white24,
                              size: 20.sp,
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'With\nAdvance',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: withAdvance ? AppColor.mangoYellow : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // ─── Advance Amount Input ───
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: withAdvance
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: EdgeInsets.only(top: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advance Amount (₹)',
                        style: GoogleFonts.montserrat(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.mangoYellow,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColor.mangoYellow.withOpacity(0.3),
                          ),
                        ),
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.montserrat(
                            fontSize: 15.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. 500',
                            hintStyle: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              color: Colors.white24,
                            ),
                            prefixIcon: Icon(
                              Icons.currency_rupee_rounded,
                              color: AppColor.mangoYellow,
                              size: 18.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 14.h,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.activeGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
              onPressed: () async {
                double? advance;
                if (withAdvance) {
                  advance = double.tryParse(amountController.text.trim());
                  if (advance == null || advance <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter a valid advance amount.',
                          style: GoogleFonts.montserrat(),
                        ),
                        backgroundColor: Colors.orange.shade700,
                      ),
                    );
                    return;
                  }
                }
                Navigator.pop(ctx);
                await _acceptBooking(booking, advanceAmount: advance);
              },
              child: Text(
                'Confirm',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BookingModel booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.premiumCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: Text('Reject Booking', style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for rejection. This will be shown to the user.',
              style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white60, height: 1.4),
            ),
            SizedBox(height: 14.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextField(
                controller: reasonController,
                maxLines: 3,
                style: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Fully booked on that date',
                  hintStyle: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a reason', style: GoogleFonts.montserrat()), backgroundColor: Colors.red.shade700),
                );
                return;
              }
              Navigator.pop(ctx);
              final vm = context.read<BookingViewModel>();
              final success = await vm.updateBookingStatus(
                bookingId: booking.id,
                status: 'rejected',
                rejectionReason: reasonController.text.trim(),
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '❌ Booking rejected.' : (vm.error ?? 'Failed'), style: GoogleFonts.montserrat()),
                  backgroundColor: success ? Colors.red.shade700 : Colors.grey.shade700,
                ),
              );
            },
            child: Text('Reject', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTime(String t) {
    try {
      final parts = t.split(':');
      int h = int.parse(parts[0]);
      final ampm = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '${h.toString().padLeft(2, '0')}:${parts[1]} $ampm';
    } catch (_) {
      return t;
    }
  }
}
