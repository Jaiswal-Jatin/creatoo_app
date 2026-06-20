import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/utils/routes/routes_name.dart';
import 'package:creatoo/features/user_payments/view_model/user_payments_view_model.dart';
import 'package:creatoo/core/services/upi_intent_service.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final int businessId;
  final String businessName;
  final double amount;
  final double? billAmount;
  final int? pointsRedeemed;
  final int? discountPercentage;
  final double? discountAmount;
  final String transactionRef;
  final Map<String, dynamic>? upiResponse;
  final String? upiApp;

  const PaymentProcessingScreen({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.amount,
    this.billAmount,
    this.pointsRedeemed,
    this.discountPercentage,
    this.discountAmount,
    this.transactionRef = '',
    this.upiResponse,
    this.upiApp,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _pulse;
  late Animation<double> _checkScale;
  Timer? _timer;
  bool _showCheck = false;

  late String _status;

  @override
  void initState() {
    super.initState();
    _status = UpiIntentService.parseStatus(widget.upiResponse?['Status']?.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 3));
      final vm = context.read<UserPaymentsViewModel>();
      await vm.submitPayment(
        businessId: widget.businessId,
        billAmount: widget.billAmount ?? widget.amount,
        pointsRedeemed: widget.pointsRedeemed ?? 0,
        pointsValue: (widget.pointsRedeemed ?? 0).toDouble(),
        finalAmount: widget.amount,
        discountPercentage: widget.discountPercentage,
        discountAmount: widget.discountAmount,
        transactionRef: widget.transactionRef,
        status: _status,
        paymentApp: widget.upiApp,
        upiResponse: widget.upiResponse,
      );
      final pid = vm.lastPaymentId;
      if (pid != null) {
        await vm.setPaymentPaidAt(pid);
      }
    });
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut),
    );
    _animCtrl.repeat(reverse: true);

    _timer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _showCheck = true);
      _animCtrl.stop();
      _animCtrl.reset();
      _animCtrl.forward();
      
      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, RoutesName.feedbackScreen, arguments: {
          'businessName': widget.businessName,
          'businessId': widget.businessId,
          'orderId': '',
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          Positioned(top: -100.h, right: -60.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(width: 350.w, height: 350.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.premiumAccent.withValues(alpha: 0.1))),
          )),
          Positioned(bottom: -80.h, left: -80.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(width: 300.w, height: 300.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.mangoYellow.withValues(alpha: 0.06))),
          )),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_showCheck) ...[
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) => Transform.scale(
                      scale: _pulse.value,
                      child: Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.premiumAccent.withValues(alpha: 0.12),
                          border: Border.all(color: AppColor.premiumAccent.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Icon(Icons.payment_rounded, color: AppColor.premiumAccent, size: 40.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text("Initiating Payment...",
                    style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  SizedBox(height: 8.h),
                  Text("Please wait while we submit\nyour payment details",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white70, height: 1.4),
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: 40.w, height: 40.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(AppColor.premiumAccent),
                    ),
                  ),
                ],
                if (_showCheck) ...[
                  AnimatedBuilder(
                    animation: _checkScale,
                    builder: (context, child) => Transform.scale(
                      scale: _checkScale.value,
                      child: Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _status == 'SUCCESS' 
                              ? Colors.green.withValues(alpha: 0.15)
                              : (_status == 'FAILED' || _status == 'CANCELLED')
                                  ? Colors.red.withValues(alpha: 0.15)
                                  : AppColor.mangoYellow.withValues(alpha: 0.15),
                          border: Border.all(
                            color: _status == 'SUCCESS' 
                                ? Colors.green.withValues(alpha: 0.4)
                                : (_status == 'FAILED' || _status == 'CANCELLED')
                                    ? Colors.red.withValues(alpha: 0.4)
                                    : AppColor.mangoYellow.withValues(alpha: 0.4), 
                            width: 2
                          ),
                        ),
                        child: Icon(
                          _status == 'SUCCESS' 
                              ? Icons.check_circle_rounded
                              : (_status == 'FAILED' || _status == 'CANCELLED')
                                  ? Icons.error_rounded
                                  : Icons.hourglass_top_rounded, 
                          color: _status == 'SUCCESS' 
                              ? Colors.green
                              : (_status == 'FAILED' || _status == 'CANCELLED')
                                  ? Colors.red
                                  : AppColor.mangoYellow, 
                          size: 44.sp
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(_status == 'SUCCESS' 
                          ? "Payment Successful" 
                          : (_status == 'FAILED' || _status == 'CANCELLED') 
                              ? "Payment Failed" 
                              : "Payment Pending",
                    style: GoogleFonts.montserrat(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  SizedBox(height: 8.h),
                  Text("₹${widget.amount.toStringAsFixed(0)} to ${widget.businessName}",
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp, 
                      fontWeight: FontWeight.w600, 
                      color: _status == 'SUCCESS' 
                          ? Colors.green
                          : (_status == 'FAILED' || _status == 'CANCELLED')
                              ? Colors.red
                              : AppColor.mangoYellow
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32.w),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.stars_rounded, color: AppColor.premiumAccent, size: 28.sp),
                        SizedBox(height: 12.h),
                        Text(
                          _status == 'SUCCESS'
                              ? "Your payment was automatically confirmed! You've earned loyalty points."
                              : (_status == 'FAILED' || _status == 'CANCELLED')
                                  ? "There was an issue with your payment. Please try again."
                                  : "The business will confirm your payment soon. Once confirmed, you will receive your loyalty points!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white70, height: 1.5, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text("Redirecting to feedback...",
                    style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white30),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
