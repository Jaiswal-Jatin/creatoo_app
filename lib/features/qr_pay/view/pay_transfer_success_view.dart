import 'package:intl/intl.dart';

import '../../../core.dart';
import '../view_model/qr_pay_view_model.dart';

class PayTransferSuccessView extends StatefulWidget {
  const PayTransferSuccessView({super.key});

  @override
  State<PayTransferSuccessView> createState() => _PayTransferSuccessViewState();
}

class _PayTransferSuccessViewState extends State<PayTransferSuccessView> with SingleTickerProviderStateMixin {
  late QrPayViewModel viewModel;
  late String currentDateTime;

  @override
  void initState() {
    super.initState();

    currentDateTime = DateFormat('d MMMM yyyy, h:mm a').format(DateTime.now());
  }

  // Function to handle the back button press or done button press
  void _navigateToHome() {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<QrPayViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        _navigateToHome();
        return false;
      },
      child: AppScaffold(
        body: Container(
          width: SizeConfig.screenWidth,
          margin: EdgeInsets.symmetric(vertical: 40.h, horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  AppIcon.successfullyDone,
                  height: 200.h,
                  width: 200.h,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  "${viewModel.transferredPoints}",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 40),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  'Creatoo points',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  'Paid to',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      textAlign: TextAlign.center,
                      viewModel.businessData?.businessName ?? '',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Container(
                    width: 190,
                    child: Text(
                      viewModel.businessData?.businessAddress ?? '',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100),
                      textAlign: TextAlign.center,
                    )),
                SizedBox(height: 30.h),
                Text(
                  currentDateTime,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Transaction ID: ${viewModel.transactionId} ',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          // margin: const EdgeInsets.all(30.0),
          padding: const EdgeInsets.all(30.0),
          child: AppButton(
              text: 'Go to Home',
              isLoading: false,
              isDisabled: false,
              onTap: () {
                _navigateToHome();
              }),
        ),
      ),
    );
  }
}
