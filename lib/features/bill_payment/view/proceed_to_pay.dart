import 'dart:ui';
import 'package:flutter/gestures.dart';
import '../../../core.dart';
import '../../../widgets/app_dotted_divider.dart';
import '../../../widgets/custom_back_button.dart';
import '../view_model/bill_payment_view_model.dart';

class ProceedToPay extends StatefulWidget {
  const ProceedToPay({super.key});

  @override
  State<ProceedToPay> createState() => _ProceedToPayState();
}

class _ProceedToPayState extends State<ProceedToPay>
    with SingleTickerProviderStateMixin {
  late BillPaymentViewModel viewModel;
  late AnimationController _animationController;
  late Animation<double> _oldAmountPosition;
  late Animation<double> _newAmountPosition;
  bool _showNewValue = false;
  bool _showStrikethrough = false;

  @override
  void initState() {
    viewModel = Provider.of<BillPaymentViewModel>(context, listen: false);
    viewModel.init();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _oldAmountPosition = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _newAmountPosition = Tween<double>(begin: -40, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _showNewValue = true;
          _showStrikethrough = true;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<BillPaymentViewModel>(context);

    switch (viewModel.businessDetailsResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.businessDetailsResponse.message.toString());
      case Status.completed:
        return _buildMobileBody();
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildMobileBody() {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100.h,
            right: -100.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 400.w,
                height: 400.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.15),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            left: -50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.1),
                ),
              ),
            ),
          ),

          // Custom App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    const CustomBackButton(),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.businessDescription?.businessName ?? '',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            viewModel.businessDescription?.businessArea ?? '',
                            style: GoogleFonts.montserrat(
                              color: AppColor.premiumTextSecondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 60.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bill Amount Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Total Amount",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  color: AppColor.premiumTextSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, _newAmountPosition.value),
                                        child: _showNewValue
                                            ? Text(
                                                "₹${viewModel.billSummary?.finalBillAmount.toCommaSeparated()}",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 42.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  letterSpacing: -1,
                                                ),
                                              )
                                            : const SizedBox(),
                                      );
                                    },
                                  ),
                                  if (viewModel.billSummary?.finalBillAmount != null &&
                                      viewModel.billSummary?.originalBill != null &&
                                      viewModel.billSummary!.finalBillAmount! <=
                                          viewModel.billSummary!.originalBill!)
                                    AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(0, _oldAmountPosition.value),
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 45.h),
                                            child: Text(
                                              "₹${viewModel.billSummary?.originalBill.toCommaSeparated()}",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white.withOpacity(0.3),
                                                decoration: _showStrikethrough
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                                decorationColor: Colors.white.withOpacity(0.3),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                              SizedBox(height: 30.h),
                              DottedDivider(
                                color: Colors.white.withOpacity(0.1),
                                height: 1,
                              ),
                              SizedBox(height: 20.h),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: AppColor.premiumAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Edit Amount",
                                    style: GoogleFonts.montserrat(
                                      color: AppColor.premiumAccent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Summary Sections
                    _buildSummaryCard(
                      title: "Bill Summary",
                      children: [
                        _buildBillRow(
                          label: "Original Bill",
                          price: "₹${viewModel.billSummary?.originalBill.toCommaSeparated()}",
                        ),
                        if (viewModel.billSummary?.discountApplied != null &&
                            viewModel.billSummary!.discountApplied! > 0)
                          _buildBillRow(
                            label: "Discount (${viewModel.billSummary?.discountPercentage}%)",
                            price: "-₹${(viewModel.billSummary!.originalBill! - viewModel.billSummary!.finalBillAmount!).toCommaSeparated()}",
                            priceColor: AppColor.premiumAccent,
                          ),
                        SizedBox(height: 8.h),
                        Text(
                          Constants.hiddenCharges,
                          style: GoogleFonts.montserrat(
                            fontSize: 10.sp,
                            color: AppColor.premiumTextSecondary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        const Divider(color: Colors.white10),
                        SizedBox(height: 12.h),
                        _buildBillRow(
                          label: "To be paid",
                          price: "₹${viewModel.billSummary?.finalBillAmount.toCommaSeparated()}",
                          isBold: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    _buildSummaryCard(
                      title: "Points Summary",
                      children: [
                        _buildBillRow(
                          label: "Total Points Available",
                          price: "${viewModel.billSummary?.totalPointsForBusiness.toCommaSeparated()}",
                        ),
                        _buildBillRow(
                          label: "Points Redeemed",
                          price: "${viewModel.billSummary?.pointsRedeemedHere.toCommaSeparated()}",
                        ),
                        _buildBillRow(
                          label: "Points You’ll Earn",
                          price: "+${viewModel.billSummary?.pointsYouWillEarn.toCommaSeparated()}",
                          priceColor: Colors.greenAccent,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Terms
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Terms & Conditions",
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.montserrat(
                                color: AppColor.premiumTextSecondary,
                                fontSize: 12.sp,
                              ),
                              children: [
                                const TextSpan(text: 'By proceeding, you agree to the '),
                                TextSpan(
                                  text: 'Terms & Conditions.',
                                  style: GoogleFonts.montserrat(
                                    color: AppColor.premiumAccent,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      Navigator.pushNamed(
                                        context,
                                        RoutesName.webView,
                                        arguments: WebViewData(
                                          "Terms & Conditions",
                                          "${AppUrl.host}/api/Terms-And-Conditions.html",
                                          enableAppBar: true,
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: AppButton(
          isIconEnabled: true,
          onTap: () async {
            try {
              if (viewModel.billSummary?.finalBillAmount != null) {
                await viewModel.processPaymentStatusApiCall();
                await viewModel.startPayment(
                  amount: viewModel.billSummary!.finalBillAmount!,
                  mobileNumber: user?.mobile,
                  orderId: viewModel.billSummary!.merchantTransactionId!,
                );
              }
            } catch (e) {
              debugPrint("Transaction Error: $e");
            }
          },
          text: "Proceed To Pay",
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow({
    required String label,
    required String price,
    Color? priceColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: isBold ? 15.sp : 13.sp,
              color: isBold ? Colors.white : AppColor.premiumTextSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            price,
            style: GoogleFonts.montserrat(
              fontSize: isBold ? 18.sp : 14.sp,
              color: priceColor ?? Colors.white,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
