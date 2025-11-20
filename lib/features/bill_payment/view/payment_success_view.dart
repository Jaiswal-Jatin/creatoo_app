import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/app_text_widget.dart';
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

  double _getFontSize(double amount) {
    return amount.toStringAsFixed(2).length > 7 ? 40.0 : 55.0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        child: AppScaffold(
          isSafe: false,
          // floatingActionButton: FloatingActionButton(onPressed: () {
          //   _confettiControllerTopLeft.play();
          //   _confettiControllerTopRight.play();
          // }),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF9759C4), Color(0xFF6A359C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: ClipPath(
                          clipper: TicketClipper(),
                          child: Container(
                            height: 600,
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            decoration: const BoxDecoration(
                              color: Colors.white, // Keep ticket white
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AppTextWidget(text: "Total Bill", fontSize: 16, fontWeight: FontWeight.w600),
                                const SizedBox(height: 15),
                                AppTextWidget(
                                  text: "₹${viewModel.paymentData?.totalBill?.toStringAsFixed(2) ?? '0.00'}",
                                  fontSize: _getFontSize((viewModel.paymentData?.totalBill ?? 0.0).toDouble()),
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 8),
                                Padding(padding: const EdgeInsets.only(left: 50.0, right: 50), child: DottedDivider()),
                                const SizedBox(height: 8),
                                const AppTextWidget(
                                  text: "You Paid",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 6),
                                AppTextWidget(
                                  text: "₹${viewModel.paymentData?.finalBill?.toStringAsFixed(2) ?? '0.00'}",
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 26),
                                const DottedDivider(
                                  height: 3,
                                  color: AppColor.kPrimary,
                                  dashWidth: 18,
                                  dashSpace: 10,
                                ),
                                const SizedBox(height: 25),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: AppTextWidget(
                                        text: (viewModel.businessDescription?.businessName != null || viewModel.businessName != null)
                                            ? "Paid to  ${viewModel.businessName}"
                                            : '---',
                                        fontSize: 14,
                                        maxLines: 4,
                                        fontWeight: FontWeight.w600,
                                        textOverflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                _buildReceiptDetail(
                                  "Date",
                                  viewModel.paymentData?.createdAt != null
                                      ? "${viewModel.paymentData!.createdAt!.day}/${viewModel.paymentData!.createdAt!.month}/${viewModel.paymentData!.createdAt!.year}"
                                      : '---',
                                ),
                                const SizedBox(height: 20),
                                _buildReceiptDetail(
                                  "Time",
                                  viewModel.paymentData?.createdAt != null
                                      ? DateFormat('hh:mm a').format(viewModel.paymentData!.createdAt!)
                                      : '---',
                                ),
                                const SizedBox(height: 20),
                                _buildReceiptDetail("Receipt Name", viewModel.paymentData?.receiptName ?? ''),
                                const SizedBox(height: 20),
                                _buildReceiptDetail("Order Id: ", viewModel.orderId ?? ''),
                                const SizedBox(height: 35),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const AppTextWidget(
                                        text: 'Note: ',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                      Flexible(
                                        child: AppTextWidget(
                                          text: "You can check the transaction in wallet tab",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: AppTextWidget(
                                          text: "To earn points tap on next and complete the review",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                AppRoundButton(
                                  title: 'Next',
                                  borderRadius: 16,
                                  onPress: () {
                                    Navigator.pushNamed(context, RoutesName.feedbackScreen, arguments: {
                                      'businessName': viewModel.businessName,
                                      'businessId': viewModel.businessId,
                                      'orderId': viewModel.orderId,
                                    });
                                  },
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
              Positioned(
                top: 30.h,
                left: 40.w,
                child: IgnorePointer(
                  child: ConfettiWidget(
                    confettiController: _confettiControllerTopLeft,
                    blastDirectionality: BlastDirectionality.directional,
                    blastDirection: -pi / 4,
                    shouldLoop: false,
                    emissionFrequency: 0.03,
                    numberOfParticles: 10,
                    maxBlastForce: 10,
                    minBlastForce: 5,
                    gravity: 0.3,
                  ),
                ),
              ),
              Positioned(
                top: 30.h,
                right: 40.w,
                child: IgnorePointer(
                  child: ConfettiWidget(
                    confettiController: _confettiControllerTopRight,
                    blastDirectionality: BlastDirectionality.explosive,
                    // blastDirectionality: BlastDirectionality.directional,
                    // blastDirection: -3 * pi / 4,
                    shouldLoop: false,
                    emissionFrequency: 0.03,
                    numberOfParticles: 10,
                    maxBlastForce: 10,
                    minBlastForce: 5,
                    gravity: 0.3,
                  ),
                ),
              ),
            ],
          ),
          // floatingActionButton: FloatingActionButton(onPressed: () {
          //   _confettiController.play();
          // }),
        ),
      ),
    );
  }

  Widget _buildReceiptDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                fontSize: 12,
              )),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12)),
        ],
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cutoutRadius = 30.0;
    double cutPosition = size.height * 0.35;

    Path path = Path();

    // Top left cut
    path.moveTo(0, cutoutRadius);
    path.quadraticBezierTo(cutoutRadius, cutoutRadius, cutoutRadius, 0);
    path.lineTo(size.width - cutoutRadius, 0);

    // Top right cut
    path.quadraticBezierTo(size.width - cutoutRadius, cutoutRadius, size.width, cutoutRadius);
    path.lineTo(size.width, cutPosition - cutoutRadius);

    // Right side cut (Shifted slightly upward)
    path.quadraticBezierTo(size.width - cutoutRadius, cutPosition, size.width, cutPosition + cutoutRadius);
    path.lineTo(size.width, size.height - cutoutRadius);

    // Bottom right cut
    path.quadraticBezierTo(size.width - cutoutRadius, size.height - cutoutRadius, size.width - cutoutRadius, size.height);
    path.lineTo(cutoutRadius, size.height);

    // Bottom left cut
    path.quadraticBezierTo(cutoutRadius, size.height - cutoutRadius, 0, size.height - cutoutRadius);
    path.lineTo(0, cutPosition + cutoutRadius);

    // Left side cut (Shifted slightly upward)
    path.quadraticBezierTo(cutoutRadius, cutPosition, 0, cutPosition - cutoutRadius);
    path.lineTo(0, cutoutRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
