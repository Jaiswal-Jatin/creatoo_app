import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:creatoo/core.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../widgets/app_dotted_divider.dart';
import '../view_model/bill_payment_view_model.dart';

class PaymentSuccessView extends StatefulWidget {
  const PaymentSuccessView({super.key});

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
  late BillPaymentViewModel viewModel;
  late ConfettiController _confettiControllerTopLeft;
  late ConfettiController _confettiControllerTopRight;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<BillPaymentViewModel>(context, listen: false);

    _confettiControllerTopLeft = ConfettiController(duration: const Duration(seconds: 3));
    _confettiControllerTopRight = ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiControllerTopLeft.play();
      _confettiControllerTopRight.play();
    });
  }

  @override
  void dispose() {
    _confettiControllerTopLeft.dispose();
    _confettiControllerTopRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: AppScaffold(
          useGradient: true,
          backgroundColor: AppColor.premiumBg,
          isSafe: false,
          body: Stack(
            children: [
              // Background Glows
              Positioned(
                top: -150.h,
                left: -100.w,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: Container(
                    width: 400.w,
                    height: 400.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.premiumAccent.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100.h,
                right: -50.w,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    width: 350.w,
                    height: 350.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withOpacity(0.15),
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        // Success Icon with Glow
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.greenAccent.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.greenAccent,
                            size: 64.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Payment Successful!",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        
                        // Ticket Section
                        Expanded(
                          child: Center(
                            child: ClipPath(
                              clipper: TicketClipper(),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 30.h),
                                      Text(
                                        "Total Bill Amount",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14.sp,
                                          color: AppColor.premiumTextSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "₹${viewModel.paymentData?.totalBill?.toStringAsFixed(2) ?? '0.00'}",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 36.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 60.w),
                                        child: const DottedDivider(color: Colors.white24),
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        "You Paid",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12.sp,
                                          color: AppColor.premiumTextSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "₹${viewModel.paymentData?.finalBill?.toStringAsFixed(2) ?? '0.00'}",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20.sp,
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 30.h),
                                      // Dash line for ticket cutout
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                                        child: Row(
                                          children: List.generate(
                                            20,
                                            (index) => Expanded(
                                              child: Container(
                                                height: 1.5,
                                                margin: EdgeInsets.symmetric(horizontal: 2.w),
                                                color: Colors.white.withOpacity(0.1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 30.h),
                                      
                                      // Transaction Details
                                      Expanded(
                                        child: SingleChildScrollView(
                                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                                          child: Column(
                                            children: [
                                              _buildDetailRow("Paid to", viewModel.businessName ?? '---', isTitle: true),
                                              _buildDetailRow("Date", viewModel.paymentData?.createdAt != null
                                                  ? DateFormat('dd MMM yyyy').format(viewModel.paymentData!.createdAt!)
                                                  : '---'),
                                              _buildDetailRow("Time", viewModel.paymentData?.createdAt != null
                                                  ? DateFormat('hh:mm a').format(viewModel.paymentData!.createdAt!)
                                                  : '---'),
                                              _buildDetailRow("Receipt Name", viewModel.paymentData?.receiptName ?? '---'),
                                              _buildDetailRow("Order ID", viewModel.orderId ?? '---'),
                                              SizedBox(height: 24.h),
                                              
                                              // Info Note
                                              Container(
                                                padding: EdgeInsets.all(12.w),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.03),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.info_outline_rounded, color: AppColor.premiumAccent, size: 16.sp),
                                                    SizedBox(width: 8.w),
                                                    Expanded(
                                                      child: Text(
                                                        "You can check this transaction in your wallet",
                                                        style: GoogleFonts.montserrat(
                                                          fontSize: 10.sp,
                                                          color: AppColor.premiumTextSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      
                                      // Bottom Message
                                      Padding(
                                        padding: EdgeInsets.all(24.w),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Tap next to complete review and earn points!",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11.sp,
                                                color: Colors.white.withOpacity(0.6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 16.h),
                                            AppButton(
                                              text: "Next",
                                              onTap: () async {
                                                Navigator.pop(context);
                                                Navigator.pushNamed(
                                                  context, 
                                                  RoutesName.feedbackScreen, 
                                                  arguments: {
                                                    'businessName': viewModel.businessName,
                                                    'businessId': viewModel.businessId,
                                                    'orderId': viewModel.orderId,
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiControllerTopLeft,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTitle = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12.sp,
              color: AppColor.premiumTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: isTitle ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cutoutRadius = 20.0;
    double cutoutY = size.height * 0.35;
    Path path = Path();

    path.moveTo(24, 0);
    path.lineTo(size.width - 24, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 24);
    
    // Right side cutout
    path.lineTo(size.width, cutoutY - cutoutRadius);
    path.arcToPoint(
      Offset(size.width, cutoutY + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    
    path.lineTo(size.width, size.height - 24);
    path.quadraticBezierTo(size.width, size.height, size.width - 24, size.height);
    path.lineTo(24, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 24);
    
    // Left side cutout
    path.lineTo(0, cutoutY + cutoutRadius);
    path.arcToPoint(
      Offset(0, cutoutY - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    
    path.lineTo(0, 24);
    path.quadraticBezierTo(0, 0, 24, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
