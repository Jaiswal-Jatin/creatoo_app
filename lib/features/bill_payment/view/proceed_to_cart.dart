import 'dart:ui';
import '../../../core.dart';
import '../../../widgets/custom_back_button.dart';
import '../view_model/bill_payment_view_model.dart';

class ProceedToCart extends StatefulWidget {
  final int businessId;
  final double? prefilledAmount;

  const ProceedToCart({
    super.key,
    required this.businessId,
    this.prefilledAmount,
  });

  @override
  State<ProceedToCart> createState() => _ProceedToCartState();
}

class _ProceedToCartState extends State<ProceedToCart> {
  late BillPaymentViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<BillPaymentViewModel>(context, listen: false);
    viewModel.amountController = TextEditingController(
      text: widget.prefilledAmount != null ? widget.prefilledAmount!.toInt().toString() : ""
    );
    if (widget.prefilledAmount != null) {
      viewModel.setAmount(widget.prefilledAmount!);
    }
    viewModel.referralCodeController = TextEditingController();
    viewModel.getBusinessDetailsApi(id: widget.businessId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<BillPaymentViewModel>(context);

    switch (viewModel.businessDetailsResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.businessDetailsResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildBody() {
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
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    // Amount Entry Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(30.w),
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
                                "ENTER BILL AMOUNT",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.premiumTextSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 30.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '₹',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 32.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  IntrinsicWidth(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 100.w),
                                      child: TextField(
                                        controller: viewModel.amountController,
                                        autofocus: viewModel.autoFocus,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        textAlign: TextAlign.center,
                                        cursorColor: AppColor.premiumAccent,
                                        inputFormatters: [CommaTextInputFormatter()],
                                        style: GoogleFonts.montserrat(
                                          fontSize: 42.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "0",
                                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (value) {
                                          final amount = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
                                          viewModel.setAmount(amount);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                width: 150.w,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColor.premiumAccent.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 30.h),
                              Text(
                                "Proceed for all exclusive offers",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12.sp,
                                  color: AppColor.premiumTextSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Referral Code Section
                    Text(
                      "Referral Code (Optional)",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: TextField(
                            controller: viewModel.referralCodeController,
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14.sp),
                            decoration: InputDecoration(
                              hintText: "Enter Referral Code",
                              hintStyle: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.3)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
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
            if (viewModel.amountController.text.trim().isEmpty) {
              Utils.toastMessage('Amount is required');
              return;
            }
            
            final amount = double.tryParse(viewModel.amountController.text.trim().replaceAll(',', '')) ?? 0.0;
            final minOrder = viewModel.businessDescription?.minOrder?.toDouble();
            
            if (minOrder != null && amount < minOrder) {
              Utils.toastMessage('Minimum Order amount is: ₹$minOrder');
              return;
            }
            
            viewModel.autoFocus = false;
            await viewModel.applyOffersApiCall();
          },
          text: "Apply Offers & Pay",
        ),
      ),
    );
  }
}
