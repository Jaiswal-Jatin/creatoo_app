import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import 'package:creatoo/widgets/app_text_widget.dart';
import '../model/booking_model.dart';
import '../view_model/booking_view_model.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RazorpayService _razorpayService;
  int? _payingBookingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<BookingViewModel>();
      vm.loadUserHistory();
      vm.fetchAdvancePaymentSettings();
    });
    _razorpayService = RazorpayService(
      _handlePaymentSuccess,
      _handlePaymentFailure,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_payingBookingId == null) return;
    final vm = context.read<BookingViewModel>();
    final success = await vm.verifyAdvancePayment(
      bookingId: _payingBookingId!,
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '🎉 Advance payment successful! Booking is now confirmed.'
              : (vm.error ?? 'Payment verification failed.'),
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: success ? AppColor.activeGreen : Colors.red.shade700,
      ),
    );
    _payingBookingId = null;
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    if (!mounted) return;
    _payingBookingId = null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '❌ Payment failed: ${response.message ?? "Unknown error"}',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  bool _isPastBooking(BookingModel booking) {
    try {
      final DateTime bookingDt = DateTime.parse('${booking.bookingDate} ${booking.bookingTime}:00');
      return bookingDt.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: false,
      backgroundColor: Colors.transparent,
      isSafe: false,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Align(
        alignment: Alignment.centerLeft,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppTextWidget(
                  text: "My Bookings",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.premiumTextPrimary,
                ),
                Consumer<BookingViewModel>(
                  builder: (_, vm, __) => IconButton(
                    icon: Icon(Icons.refresh_rounded, color: Colors.white38, size: 22.sp),
                    onPressed: () => vm.loadUserHistory(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        indicator: BoxDecoration(
          color: AppColor.premiumAccent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.premiumAccent.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white30,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('All'))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('Pending'))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('Confirmed'))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('Completed'))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('Cancelled'))),
        ],
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
            _buildBookingList(vm.userBookings),
            _buildBookingList(vm.userBookings.where((b) => b.status == 'pending').toList()),
            _buildBookingList(vm.userBookings.where((b) => b.status == 'accepted' && !_isPastBooking(b)).toList()),
            _buildBookingList(vm.userBookings.where((b) => b.status == 'accepted' && _isPastBooking(b)).toList()),
            _buildBookingList(vm.userBookings.where((b) => b.status == 'cancelled' || b.status == 'rejected').toList()),
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
            onPressed: () => vm.loadUserHistory(),
            child: Text('Retry', style: GoogleFonts.montserrat(color: AppColor.premiumAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, color: Colors.white24, size: 50.sp),
            SizedBox(height: 16.h),
            Text('No bookings found', style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white38, fontWeight: FontWeight.w600)),
            SizedBox(height: 6.h),
            Text('Explore businesses to make a request', style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white24)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColor.activeGreen;
      case 'rejected':
        return Colors.red.shade400;
      case 'cancelled':
        return Colors.grey.shade400;
      default:
        return AppColor.mangoYellow;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Confirmed';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
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

  Widget _buildBookingCard(BookingModel booking) {
    final status = booking.status;
    final statusColor = _statusColor(status);
    final isPast = _isPastBooking(booking);
    final canCancel = status == 'pending' && !isPast;
    final isAdvancePaid = booking.advancePaymentStatus == 'paid';
    final needsPayment = booking.needsAdvancePayment;

    // Border highlight for advance-pending bookings
    final borderColor = needsPayment
        ? AppColor.mangoYellow.withOpacity(0.5)
        : statusColor.withOpacity(0.2);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: needsPayment ? 1.5 : 1.2),
        boxShadow: [
          BoxShadow(
            color: needsPayment
                ? AppColor.mangoYellow.withOpacity(0.06)
                : statusColor.withOpacity(0.03),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Top Row: Business + Status ───
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: AppColor.premiumAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.premiumAccent.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      _categoryEmoji(booking.businessCategory),
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.business?.businessName ?? 'Business',
                        style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${booking.bookingDate} at ${_formatTime(booking.bookingTime)}',
                        style: GoogleFonts.montserrat(fontSize: 10.5.sp, color: Colors.white38, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status, statusColor),
              ],
            ),
          ),

          Divider(color: Colors.white.withOpacity(0.04), height: 1),

          // ─── Details Row ───
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (booking.serviceName != null)
                  _detailChip(Icons.spa_rounded, booking.serviceName!, AppColor.premiumAccent)
                else if (booking.sportName != null)
                  _detailChip(Icons.sports_rounded, booking.sportName!, AppColor.premiumAccent),
                if (booking.guestsCount != null)
                  _detailChip(Icons.people_rounded, '${booking.guestsCount} guests', AppColor.premiumAccent),
                if (booking.notes != null && booking.notes!.trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      '📝 ${booking.notes}',
                      style: GoogleFonts.montserrat(fontSize: 10.5.sp, color: Colors.white30, fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // ─── Rejection / Cancellation Reason ───
          if ((status == 'rejected' || status == 'cancelled') && booking.rejectionReason != null && booking.rejectionReason!.trim().isNotEmpty) ...[
            Divider(color: statusColor.withOpacity(0.1), height: 1),
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
                      '${status == 'cancelled' ? 'Cancellation' : 'Rejection'} Reason: "${booking.rejectionReason}"',
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

          // ─── Advance Payment Banner ───
          if (needsPayment) ...[
            Divider(color: AppColor.mangoYellow.withOpacity(0.15), height: 1),
            _buildAdvancePaymentCard(booking),
          ],

          // ─── Booking Active Confirmation ───
          if (booking.advancePaymentStatus == 'paid' && booking.isBookingActive) ...[
            Divider(color: AppColor.activeGreen.withOpacity(0.15), height: 1),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColor.activeGreen.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, color: AppColor.activeGreen, size: 14.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Advance paid • Booking fully confirmed',
                    style: GoogleFonts.montserrat(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.activeGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ─── Cancel Action Button ───
          if (canCancel && !needsPayment && !isAdvancePaid) ...[
            Divider(color: Colors.white.withOpacity(0.04), height: 1),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: InkWell(
                onTap: () => _showCancelDialog(booking),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 9.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade400.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_outlined, color: Colors.red.shade400, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Cancel Booking',
                        style: GoogleFonts.montserrat(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: Colors.red.shade400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Glassmorphic advance payment breakdown card
  Widget _buildAdvancePaymentCard(BookingModel booking) {
    final vm = context.read<BookingViewModel>();
    final base = booking.advanceAmount ?? 0;
    final platformFee = vm.advancePlatformFee;
    final gstPercent = vm.advanceGstPercent;
    // GST on platform fee, not on advance amount
    final gst = (platformFee * gstPercent / 100);
    final total = base + platformFee + gst;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.mangoYellow.withOpacity(0.08),
            Colors.deepOrange.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColor.mangoYellow.withOpacity(0.25),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ───
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColor.mangoYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.payment_rounded,
                        color: AppColor.mangoYellow,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Advance Payment Required',
                            style: GoogleFonts.montserrat(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColor.mangoYellow,
                            ),
                          ),
                          Text(
                            'Pay to confirm your booking',
                            style: GoogleFonts.montserrat(
                              fontSize: 10.sp,
                              color: Colors.white38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                Divider(color: AppColor.mangoYellow.withOpacity(0.15)),
                SizedBox(height: 8.h),

                // ─── Breakdown rows ───
                _breakdownRow('Advance Amount', '₹${base.toStringAsFixed(0)}', Colors.white70),
                SizedBox(height: 6.h),
                _breakdownRow('Platform Fee', '₹${platformFee.toStringAsFixed(0)}', Colors.white54),
                SizedBox(height: 6.h),
                _breakdownRow('GST (${gstPercent.toStringAsFixed(0)}%)', '₹${gst.toStringAsFixed(2)}', Colors.white54),
                SizedBox(height: 10.h),
                Divider(color: AppColor.mangoYellow.withOpacity(0.2)),
                SizedBox(height: 6.h),
                _breakdownRow(
                  'Total Payable',
                  '₹${total.toStringAsFixed(2)}',
                  AppColor.mangoYellow,
                  isBold: true,
                ),

                SizedBox(height: 14.h),

                // ─── Pay Button ───
                Consumer<BookingViewModel>(
                  builder: (_, vm, __) => GestureDetector(
                    onTap: vm.isCreatingAdvanceOrder
                        ? null
                        : () => _initiateAdvancePayment(booking, vm),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.mangoYellow,
                            Colors.deepOrange.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.mangoYellow.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: vm.isCreatingAdvanceOrder
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_rounded, color: Colors.white, size: 15.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Pay ₹${total.toStringAsFixed(0)} Securely',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11.sp,
            color: Colors.white54,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: isBold ? 13.sp : 11.sp,
            color: valueColor,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _initiateAdvancePayment(BookingModel booking, BookingViewModel vm) async {
    _payingBookingId = booking.id;
    debugPrint('🔄 Creating advance order for booking #${booking.id}...');
    debugPrint('🔍 [UI] Booking advanceAmount: ${booking.advanceAmount}, advancePaymentStatus: ${booking.advancePaymentStatus}');
    final order = await vm.createAdvanceOrder(booking.id);
    debugPrint('📦 Order response: orderId=${order?.razorpayOrderId}, amount=${order?.amount}, keyId=${order?.keyId}');
    if (order == null || order.razorpayOrderId == null) {
      debugPrint('❌ Order creation failed: "${vm.error}"');
      debugPrint('🔍 [UI] vm.isCreatingAdvanceOrder: ${vm.isCreatingAdvanceOrder}, vm.currentAdvanceOrder: ${vm.currentAdvanceOrder}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? 'Failed to create payment order.', style: GoogleFonts.montserrat()),
            backgroundColor: Colors.red.shade700,
            duration: Duration(seconds: 5),
          ),
        );
      }
      _payingBookingId = null;
      return;
    }

    debugPrint('🚀 Opening Razorpay checkout...');
    _razorpayService.openCheckout(
      amount: order.amount ?? 0,
      orderId: order.razorpayOrderId!,
      keyId: order.keyId,  // ← from backend, no .env needed
      paymentDescription: 'Advance for booking at ${booking.business?.businessName ?? "Business"}',
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), color: color, size: 11.sp),
          SizedBox(width: 4.w),
          Text(
            _statusLabel(status),
            style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 11.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.montserrat(fontSize: 10.5.sp, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BookingModel booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: AppColor.premiumCardBg.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          title: Text(
            'Cancel Booking',
            style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel this booking? Please specify a reason. The business will be notified instantly.',
                style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white60, height: 1.45, fontWeight: FontWeight.w500),
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
                    hintText: 'e.g., Change of plans, personal reason...',
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
              child: Text(
                'Go Back',
                style: GoogleFonts.montserrat(color: Colors.white38, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a reason', style: GoogleFonts.montserrat()),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);

                final vm = context.read<BookingViewModel>();
                final success = await vm.cancelBooking(bookingId: booking.id, reason: reason);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '✅ Booking cancelled successfully!' : (vm.error ?? 'Failed to cancel booking'),
                      style: GoogleFonts.montserrat(),
                    ),
                    backgroundColor: success ? AppColor.activeGreen : Colors.red.shade700,
                  ),
                );
              },
              child: Text(
                'Cancel Booking',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
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
