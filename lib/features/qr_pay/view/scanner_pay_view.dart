import 'package:flutter/services.dart';

import '../../../core.dart';
import '../view_model/qr_pay_view_model.dart';

class ScannerPayView extends StatefulWidget {
  const ScannerPayView({super.key});

  @override
  State<ScannerPayView> createState() => _ScannerPayViewState();
}

class _ScannerPayViewState extends State<ScannerPayView> {
  late QrPayViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<QrPayViewModel>(context, listen: false);
    viewModel.amountController?.clear();
    viewModel.pointsController.clear();
    viewModel.init();
  }

  // Method to handle back navigation
  Future<bool> _onBackPressed() async {
    viewModel.pointsController.clear();
    Navigator.pop(context);
    Navigator.pop(context);
    return false; // Prevents the default back navigation
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<QrPayViewModel>(context);

    switch (viewModel.businessResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.businessResponse.message.toString());
      case Status.completed:
        return buildMobileBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget buildMobileBody() {
    return WillPopScope(
      onWillPop: _onBackPressed, // Add WillPopScope to handle back navigation
      child: AppScaffold(
        appBar: AppBarWidget(
          onPop: () {
            _onBackPressed();
          },
        ),
        body: Container(
          width: SizeConfig.screenWidth,
          margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AppImageWidget(
                    imageUrl: viewModel.businessData?.businessImage ?? '',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  'Paying to',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Text(
                    viewModel.businessData?.businessName ?? '',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text(
                      viewModel.businessData?.businessAddress ?? '',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  height: 15.h,
                ),
                Container(
                  width: SizeConfig.screenWidth,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Amount(INR)',
                              style: TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                            SizedBox(
                              width: 4.h,
                            ),
                            Tooltip(
                              margin: EdgeInsets.symmetric(horizontal: 40),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                border: Border.all(color: AppColor.lightGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enableTapToDismiss: true,
                              showDuration: Duration(seconds: 100),
                              enableFeedback: true,
                              triggerMode: TooltipTriggerMode.tap,
                              preferBelow: true,
                              richMessage: TextSpan(
                                text: Constants.amountToolTip,
                                style: TextStyle(
                                  color: AppColor.black,
                                  fontSize: 14.sp,
                                ),
                                children: [],
                              ),
                              child: Icon(
                                Icons.info_outline,
                                size: 20.h,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: SizeConfig.screenWidth / 3,
                                child: Text(
                                  'Enter Total Bill Amount',
                                  style: TextStyle(fontSize: 16, color: Color(0xFF26278D), fontWeight: FontWeight.w700),
                                )),
                            Container(
                              width: 130,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: viewModel.amountController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    double amount = double.tryParse(value) ?? 0;
                                    // double percentageDecimal = (viewModel.discount ?? 0) / 100;
                                    // viewModel.percentageAmount = amount * percentageDecimal;
                                    // viewModel.pointsController.text = (viewModel.percentageAmount == 0)
                                    //     ? '0.0'
                                    //     : viewModel.roundToTwoDecimalPlaces(viewModel.percentageAmount).toString();
                                    viewModel.notify();
                                  } else {
                                    viewModel.percentageAmount = 0;
                                    viewModel.notify();
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(38, 39, 141, 1),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(AppIcon.upDownArrow),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              'Creatoo Points Redeem',
                              style: TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Tooltip(
                              margin: EdgeInsets.symmetric(horizontal: 40),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                border: Border.all(color: AppColor.lightGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enableTapToDismiss: true,
                              showDuration: Duration(seconds: 100),
                              enableFeedback: true,
                              triggerMode: TooltipTriggerMode.tap,
                              preferBelow: true,
                              richMessage: TextSpan(
                                text: Constants.pointsToolTip,
                                style: TextStyle(
                                  color: AppColor.black,
                                  fontSize: 14.sp,
                                ),
                                children: [],
                              ),
                              child: Icon(
                                Icons.info_outline,
                                size: 20.h,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: SizeConfig.screenWidth / 3,
                                child: Text(
                                  'Points to Pay',
                                  style: TextStyle(fontSize: 16, color: Color(0xFF26278D), fontWeight: FontWeight.w700),
                                )),
                            Container(
                                width: 130,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: viewModel.pointsController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                SizedBox(
                  height: 80.h,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // if (viewModel.amountController?.text != null &&
            //     viewModel.amountController!.text.isNotEmpty &&
            //     double.parse(viewModel.amountController?.text ?? "0") >= viewModel.minOrderValue!) {
            //   Navigator.pushNamed(context, RoutesName.payTransferView);
            // } else {
            //   Utils.snackBar("Minimum Bill Amount should be ${viewModel.minOrderValue}", result: Result.error);
            // }
          },
          child: Icon(
            Icons.arrow_forward,
            size: 25,
          ),
        ),
      ),
    );
  }
}
