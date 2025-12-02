import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:flutter/gestures.dart';

import '../../../core.dart';
import '../../../widgets/app_dotted_divider.dart';
import '../view_model/bill_payment_view_model.dart';

class ProceedToPay extends StatefulWidget {
  const ProceedToPay({super.key});

  @override
  State<ProceedToPay> createState() => _ProceedToPayState();
}

class _ProceedToPayState extends State<ProceedToPay> with SingleTickerProviderStateMixin {
  late BillPaymentViewModel viewModel;
  late ConfettiController _confettiLeftController;
  late ConfettiController _confettiRightController;
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _oldAmountPosition;
  late Animation<double> _newAmountPosition;
  bool _showNewValue = false;
  bool _showStrikethrough = false;

  @override
  void initState() {
    viewModel = Provider.of<BillPaymentViewModel>(context, listen: false);
    viewModel.init();

    _confettiLeftController = ConfettiController(duration: Duration(seconds: 1));
    _confettiRightController = ConfettiController(duration: Duration(seconds: 1));

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    // Shrinking & moving down animation for previous value
    _sizeAnimation = Tween<double>(begin: 30, end: 20).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _oldAmountPosition = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // New value enters from above (-30 pixels)
    _newAmountPosition = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation
    _animationController.forward().then((_) {
      setState(() {
        _showNewValue = true;
        _showStrikethrough = true;
      });
      _startCelebration();
    });

    super.initState();
  }

  @override
  void dispose() {
    _confettiLeftController.dispose();
    _confettiRightController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startCelebration() async {
    _confettiLeftController.play();
    _confettiRightController.play();

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _showNewValue = true;
    });

    _animationController.forward().then((_) {
      setState(() {
        _showStrikethrough = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<BillPaymentViewModel>(context);

    switch (viewModel.businessDetailsResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.businessDetailsResponse.message.toString());
      case Status.completed:
        return _buildMobileBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget _buildMobileBody() {
    return AppScaffold(
        appBar: AppBarWidget(
          centerTile: false,
          title: viewModel.businessDescription?.businessName ?? '',
          subtitle: viewModel.businessDescription?.businessArea ?? '',
          useCustomBackButton: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRect(
                //  clipBehavior: Clip.none,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20.0),
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(-2, 2), // Bottom shadow stronger
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // New amount (₹450) smoothly enters from top
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _newAmountPosition.value),
                                    child: _showNewValue
                                        ? Padding(
                                            padding: const EdgeInsets.only(bottom: 15.0),
                                            child: AppTextWidget(
                                              key: ValueKey(1),
                                              text: "\u20B9${viewModel.billSummary?.finalBillAmount.toCommaSeparated()}",
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.black,
                                              fontSize: 36,
                                            ),
                                          )
                                        : SizedBox(),
                                  );
                                },
                              ),
                              SizedBox(height: 30),
                              if (viewModel.billSummary?.finalBillAmount != null &&
                                  viewModel.billSummary?.originalBill != null &&
                                  viewModel.billSummary!.finalBillAmount! <= viewModel.billSummary!.originalBill!)
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _oldAmountPosition.value),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 30.0),
                                        child: AppTextWidget(
                                          key: ValueKey(2),
                                          text: "\u20B9${viewModel.billSummary?.originalBill.toCommaSeparated()}",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 30,
                                          color: AppColor.lighterDd,
                                          textDecoration: _showStrikethrough ? TextDecoration.lineThrough : TextDecoration.none,
                                          textDecorationColor: AppColor.lighterDd,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                          SizedBox(height: 55),
                          Container(
                            child: DottedDivider(color: AppColor.dd, height: 1),
                            margin: EdgeInsets.symmetric(horizontal: 6.w),
                          ),
                          SizedBox(
                            height: 14.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: AppTextWidget(
                              text: "Edit Amount",
                              color: AppColor.activeGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 20, // Slightly inside to avoid overflow
                      child: ConfettiWidget(
                        confettiController: _confettiLeftController,
                        blastDirection: pi / 4, // Straight up
                        emissionFrequency: 0.3,
                        numberOfParticles: 1,
                        gravity: 0.3,
                        maxBlastForce: 5, // Restrict height
                        minBlastForce: 1,
                        colors: [Colors.red, Colors.yellow, Colors.blue, Colors.green],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 20, // Slightly inside
                      child: ConfettiWidget(
                        confettiController: _confettiRightController,
                        blastDirection: (3 * pi) / 4,
                        emissionFrequency: 0.3,
                        numberOfParticles: 1,
                        gravity: 0.3,
                        maxBlastForce: 5, // Restrict height
                        minBlastForce: 1,
                        colors: [Colors.red, Colors.yellow, Colors.blue, Colors.green],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColor.moreLighterDd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          childrenPadding: EdgeInsets.zero,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: AppTextWidget(
                                  text: "Bill Summary",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Column(
                              children: [
                                _buildBillRowWidget(
                                  label: "Bill Amount",
                                  price: "\u20B9${viewModel.billSummary?.originalBill.toCommaSeparated()}",
                                ),
                                if (viewModel.billSummary?.discountApplied != null && viewModel.billSummary!.discountApplied! > 0)
                                  _buildBillRowWidget(
                                    label: "Discount",
                                    price: "${viewModel.billSummary?.discountPercentage}%",
                                    color: Colors.blue,
                                  ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  alignment: Alignment.centerLeft,
                                  child: AppTextWidget(
                                    text: Constants.hiddenCharges,
                                    fontSize: 9.sp,
                                    color: AppColor.grey,
                                  ),
                                ),
                                // _buildBillRowWidget(
                                //   label: "Convenience Fee & Charges",
                                //   price: "\u20B9${viewModel.billSummary?.convenienceFee}",
                                // ),
                                SizedBox(height: 10.0),
                                DottedDivider(color: Colors.grey, height: 1),
                                SizedBox(height: 10.0),
                                _buildBillRowWidget(
                                  label: "To be paid",
                                  labelFontSize: 16,
                                  priceFontSize: 16,
                                  price: "\u20B9${viewModel.billSummary?.finalBillAmount.toCommaSeparated()}",
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 10.0),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColor.moreLighterDd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          childrenPadding: EdgeInsets.zero,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: AppTextWidget(
                                  text: "Points Summary",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Column(
                              children: [
                                _buildBillRowWidget(
                                  label: "Total Points",
                                  price: "${viewModel.billSummary?.totalPointsForBusiness.toCommaSeparated()}",
                                ),
                                _buildBillRowWidget(
                                  label: "Points Redeemed Here",
                                  price: "${viewModel.billSummary?.pointsRedeemedHere.toCommaSeparated()}",
                                ),
                                _buildBillRowWidget(
                                  label: "Points You’ll Earn",
                                  price: "${viewModel.billSummary?.pointsYouWillEarn.toCommaSeparated()}",
                                ),
                                SizedBox(height: 10.0),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: AppTextWidget(
                        text: "Terms & Condition",
                        fontSize: 14,
                      ),
                    ),
                    // SizedBox(
                    //   height: 10.h,
                    // ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 8.h, left: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(color: Colors.black, fontSize: 12.0),
                              children: [
                                TextSpan(
                                  text: 'By using this app, you agree to the ',
                                  style: GoogleFonts.inter(),
                                ),
                                TextSpan(
                                  text: 'Terms & Conditions.',
                                  style: GoogleFonts.inter(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await Navigator.pushNamed(
                                        navigatorKey.currentContext!,
                                        RoutesName.webView,
                                        arguments: WebViewData(
                                          "",
                                          "${AppUrl.host}/api/Terms-And-Conditions.html",
                                          enableAppBar: true,
                                        ),
                                      );

                                      print('Terms & Conditions tapped');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 70.h,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.h),
          child: AppButton(
            isIconEnabled: true,
            // buttonColor: AppColor.buttonPay,
            onTap: () async {
              try {
                if (viewModel.billSummary?.finalBillAmount != null) {
                  await Future.wait([
                    viewModel.startPayment(
                      amount: viewModel.billSummary!.finalBillAmount!,
                      // amount: 1.00,
                      mobileNumber: user?.mobile,
                      orderId: viewModel.billSummary!.merchantTransactionId!,
                    ),
                    viewModel.processPaymentStatusApiCall(),
                  ]);
                }
              } catch (e) {
                debugPrint("Transaction Error: $e");
              }
            },
            text: "Proceed To Pay",
          ),
        ));
  }

  Widget _buildBillRowWidget({
    required String label,
    required String price,
    Color? color,
    FontWeight? fontWeight,
    double? labelFontSize, // Allow custom font size for label
    double? priceFontSize, // Allow custom font size for price
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppTextWidget(
            text: label,
            fontSize: labelFontSize ?? 12, // Default size if not provided
            color: color,
            fontWeight: fontWeight,
          ),
          AppTextWidget(
            text: price,
            fontSize: priceFontSize ?? 12, // Default size if not provided
            color: color,
            fontWeight: fontWeight,
          ),
        ],
      ),
    );
  }
}
