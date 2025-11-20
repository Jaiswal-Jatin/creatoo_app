import 'package:creatoo/core.dart';
import 'package:creatoo/features/payment_details/view_model/payment_detail_view_model.dart';
import 'package:flutter/services.dart';

class PaymentDetailView extends StatefulWidget {
  const PaymentDetailView({super.key});

  @override
  State<PaymentDetailView> createState() => _PaymentDetailViewState();
}

class _PaymentDetailViewState extends State<PaymentDetailView> {
  late PaymentDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<PaymentDetailViewModel>(context, listen: false);
    viewModel.init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<PaymentDetailViewModel>(context);
    switch (viewModel.apiResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.apiResponse.message.toString());
      case Status.completed:
        return AppScaffold(
          appBar: AppBarWidget(
            title: "Bank Details",
          ),
          body: Container(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Default Payment Method",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildPaymentMethodSelection(
                          label: PaymentMethod.bank.name.capitalizeFirst,
                          method: PaymentMethod.bank,
                        ),
                        buildPaymentMethodSelection(
                          label: PaymentMethod.upi.name.toUpperCase(),
                          method: PaymentMethod.upi,
                        ),
                        buildPaymentMethodSelection(
                          label: "GPay/PhonePe",
                          method: PaymentMethod.phone,
                        ),
                      ],
                    ),
                    Divider(
                      color: AppColor.darkGrey,
                    ),
                    // SizedBox(height: 20.h),
                    viewModel.paymentMethod == PaymentMethod.bank
                        ? Column(
                            children: [
                              buildForm(
                                title: "Bank Name",
                                hint: "Bank Name",
                                controller: viewModel.bankNameController,
                                textCapitalization: TextCapitalization.words,
                                textInputFormatter: [TextFieldUtils.onlyTextWithSpaces],
                                readOnly: viewModel.isReadOnly,
                              ),
                              buildForm(
                                title: "Branch Name",
                                hint: "Branch Name",
                                controller: viewModel.branchNameController,
                                textCapitalization: TextCapitalization.words,
                                textInputFormatter: [TextFieldUtils.onlyTextAndNumberWithSpaces],
                                readOnly: viewModel.isReadOnly,
                              ),
                              buildForm(
                                title: "Account Number",
                                hint: "Account Number",
                                controller: viewModel.accountController,
                                textInputType: TextInputType.number,
                                textInputFormatter: [TextFieldUtils.onlyDigitsWithSpaces],
                                readOnly: viewModel.isReadOnly,
                              ),
                              // buildForm(
                              //   title: "Confirm Account Number",
                              //   hint: "Confirm Account Number",
                              //   controller: viewModel.confirmAccountController,
                              //   textInputType: TextInputType.number,
                              //   textInputFormatter: [TextFieldUtils.onlyDigits],
                              //   readOnly: viewModel.isReadOnly,
                              // ),
                              buildForm(
                                title: "IFSC Code",
                                hint: "IFSC Code",
                                maxLength: 11,
                                controller: viewModel.ifscController,
                                // textInputType: TextInputType.text,
                                textCapitalization: TextCapitalization.characters,
                                textInputFormatter: [TextFieldUtils.ifscCodeFormatter],
                                readOnly: viewModel.isReadOnly,
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    viewModel.paymentMethod == PaymentMethod.upi
                        ? buildForm(
                            title: "UPI ID",
                            hint: "UPI ID",
                            textInputType: TextInputType.text,
                            textCapitalization: TextCapitalization.none,
                            controller: viewModel.upiController,
                            textInputFormatter: [TextFieldUtils.upiIdFormatter],
                            readOnly: viewModel.isReadOnly,
                          )
                        : SizedBox.shrink(),
                    viewModel.paymentMethod == PaymentMethod.phone
                        ? buildForm(
                            title: "GPay/PhonePe Number",
                            hint: "Number",
                            textInputType: TextInputType.number,
                            textCapitalization: TextCapitalization.none,
                            controller: viewModel.phoneController,
                            textInputFormatter: [TextFieldUtils.onlyDigitsWithSpaces],
                            readOnly: viewModel.isReadOnly,
                            maxLength: 10,
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: AppButton(
              isIconEnabled: false,
              text: viewModel.isReadOnly ? "Edit" : "Submit",
              isLoading: viewModel.isLoading,
              onTap: () async {
                if (viewModel.isReadOnly) {
                  viewModel.toggleReadOnly();
                  return;
                }
                if (viewModel.formKey.currentState!.validate()) {
                  await viewModel.submitPaymentDetails();
                }
              },
            ),
          ),
        );
      default:
        return AppNoDataWidget();
    }
  }

  Row buildPaymentMethodSelection({required PaymentMethod method, required String label}) {
    return Row(
      children: [
        Radio<PaymentMethod>(
          value: method,
          groupValue: viewModel.paymentMethod,
          onChanged: (PaymentMethod? value) => viewModel.selectPaymentMethod(value!),
        ),
        Text(label),
      ],
    );
  }

  Widget buildForm({
    required String title,
    required String hint,
    TextEditingController? controller,
    TextInputType textInputType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    List<TextInputFormatter>? textInputFormatter,
    int? maxLength,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF191D23),
            ),
          ),
          SizedBox(height: 8.h),
          AppTextField(
            controller: controller,
            hintText: "Enter $hint",
            textInputType: textInputType,
            inputFormatters: textInputFormatter,
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            disableBorder: false,
            readOnly: readOnly,
            maxLength: maxLength,
            capitaliseText: textCapitalization,
            onChanged: (value) {},
            validator: (value) => Validator.validate(value.trim(), hint),
          ),
        ],
      ),
    );
  }
}
