import '../../../core.dart';
import '../../../widgets/app_text_widget.dart';
import '../view_model/bill_payment_view_model.dart';

class ProceedToCart extends StatefulWidget {
  final int businessId;

  const ProceedToCart({
    super.key,
    required this.businessId,
  });

  @override
  State<ProceedToCart> createState() => _ProceedToCartState();
}

class _ProceedToCartState extends State<ProceedToCart> {
  late BillPaymentViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<BillPaymentViewModel>(context, listen: false);
    viewModel.amountController = TextEditingController();
    viewModel.referralCodeController = TextEditingController();
    viewModel.getBusinessDetailsApi(id: widget.businessId);
    super.initState();
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
        return _buildBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    return AppScaffold(
      appBar: AppBarWidget(
        centerTile: false,
        title: viewModel.businessDescription?.businessName ?? '',
        subtitle: viewModel.businessDescription?.businessArea ?? '',
        useCustomBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    offset: Offset(-2, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppTextWidget(
                      text: "ENTER BILL AMOUNT",
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColor.black,
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColor.moreLighterDd, width: 2),
                            ),
                          ),
                          child: AppTextWidget(
                            text: '₹',
                            fontSize: 35,
                            color: AppColor.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: 165,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColor.moreLighterDd, width: 2),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: AppTextField(
                                maxLines: 1,
                                controller: viewModel.amountController,
                                autofocus: viewModel.autoFocus,
                                cursorColor: AppColor.black,
                                textColor: AppColor.black,
                                textSize: 35,
                                fontWeight: FontWeight.w700,
                                backgroundColor: AppColor.transparent,
                                inputFormatters: [CommaTextInputFormatter()],
                                textInputType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                onChanged: (value) {
                                  final amount = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
                                  viewModel.setAmount(amount);
                                },
                                // inputFormatters: [
                                //   DecimalTextInputFormatter(decimalRange: 2),
                                // ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                    SizedBox(height: 30),
                    AppTextWidget(
                      text: "Proceed for all offers",
                      fontSize: 12,
                      color: AppColor.black,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Container(
              width: double.infinity,
              height: 115,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppTextWidget(
                          text: "Referral Code",
                          fontSize: 14,
                        ),
                        AppTextWidget(
                          text: " (Optional)",
                          fontSize: 14,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    AppTextField(
                      controller: viewModel.referralCodeController,
                      textSize: 14,
                      hintText: "Enter Referral Code",
                      borderRadius: 10,
                      borderColor: AppColor.dd.withOpacity(0.2),
                      disableBorder: false,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.h),
        child: AppButton(
          isIconEnabled: true,
          onTap: () async {
            debugPrint('=== Apply Offers & Pay Button Clicked ===');
            debugPrint('Amount entered: ${viewModel.amountController.text}');
            
            if (viewModel.amountController.text.trim().isEmpty) {
              final errorMsg = 'Amount is required';
              debugPrint('Validation Error: $errorMsg');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: AppTextWidget(text: errorMsg),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            final amount = double.tryParse(viewModel.amountController.text.trim().replaceAll(',', '')) ?? 0.0;
            final minOrder = viewModel.businessDescription?.minOrder?.toDouble();
            
            if (minOrder != null && amount < minOrder) {
              final errorMsg = 'Minimum Order amount is: $minOrder';
              debugPrint('Validation Error: $errorMsg. Entered amount: $amount');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: AppTextWidget(text: errorMsg),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            debugPrint('Proceeding with amount: $amount');
            viewModel.autoFocus = false;
            debugPrint('Calling applyOffersApi...');
            await viewModel.applyOffersApiCall();
            debugPrint('After applyOffersApi call');
          },
          text: "Apply Offers & Pay",
        ),
      ),
    );
  }
}
