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
    viewModel.percentageAmount = 0.0;
    viewModel.init();
    
    // Fetch user's current points balance for this business on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.validatePointsApiCall();
    });
  }

  // Method to handle back navigation
  void _onBackPressed() {
    viewModel.pointsController.clear();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<QrPayViewModel>(context);

    switch (viewModel.businessResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.businessResponse.message.toString());
      case Status.completed:
        return buildMobileBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget buildMobileBody() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed();
      },
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
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w100),
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
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
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
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF26278D),
                                      fontWeight: FontWeight.w700),
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
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    // double amount = double.tryParse(value) ?? 0;
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
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
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
                        if (viewModel.creatooBalance != null) ...[
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFF26278D).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF26278D).withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF26278D),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Note: You can redeem a maximum of 60% of your total Creatoo points for this payment (Max: ${(viewModel.creatooBalance! * 0.60).floor()} Points).\nYour Total Points: ${viewModel.creatooBalance} Points.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF26278D),
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(
                          height: 14,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: SizeConfig.screenWidth / 3,
                                child: Text(
                                  'Points to Pay',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF26278D),
                                      fontWeight: FontWeight.w700),
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
                                    readOnly: false,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        double points = double.tryParse(value) ?? 0.0;
                                        double maxRedeemable = (viewModel.creatooBalance ?? 0.0) * 0.60;
                                        if (points > maxRedeemable) {
                                          viewModel.percentageAmount = maxRedeemable;
                                          viewModel.pointsController.text = maxRedeemable.floor().toString();
                                          viewModel.pointsController.selection = TextSelection.fromPosition(
                                            TextPosition(offset: viewModel.pointsController.text.length),
                                          );
                                          Utils.toastMessage("You can redeem a maximum of 60% of your total points.");
                                        } else {
                                          viewModel.percentageAmount = points;
                                        }
                                      } else {
                                        viewModel.percentageAmount = 0.0;
                                      }
                                      viewModel.notify();
                                    },
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
          backgroundColor: Color(0xFF26278D),
          onPressed: () async {
            if (viewModel.amountController?.text != null &&
                viewModel.amountController!.text.isNotEmpty) {
              
              double points = double.tryParse(viewModel.pointsController.text) ?? 0.0;
              double maxRedeemable = (viewModel.creatooBalance ?? 0.0) * 0.60;
              if (points > maxRedeemable) {
                Utils.toastMessage("You can redeem a maximum of 60% of your total points.");
                return;
              }
              
              Navigator.pushNamed(context, RoutesName.payTransferView);
            } else {
              Utils.toastMessage("Please enter the total bill amount.");
            }
          },
          child: Icon(
            Icons.arrow_forward,
            size: 25,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
