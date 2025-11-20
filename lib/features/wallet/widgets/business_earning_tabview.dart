import '../../../core.dart';
import '../view_model/business_wallet_earning_view_model.dart';

class BusinessEarningTabview extends StatefulWidget {
  const BusinessEarningTabview({super.key});

  @override
  State<BusinessEarningTabview> createState() => _BusinessEarningTabviewState();
}

class _BusinessEarningTabviewState extends State<BusinessEarningTabview> {
  late BusinessWalletEarningViewModel viewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    viewModel = Provider.of<BusinessWalletEarningViewModel>(context, listen: false);
    // viewModel.init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<BusinessWalletEarningViewModel>(context);
    switch (viewModel.transactionResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.transactionResponse.message!);
      case Status.completed:
        return AppScaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SvgPicture.asset(
                        width: SizeConfig.screenWidth,
                        AppIcon.walletBg,
                      ),
                      AppWalletCard(value: viewModel.walletBalance.toDouble()),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Recent transactions',
                    style: AppTextStyles.body(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 20.h),
                  Visibility(
                    visible: viewModel.transactionResponse.data!.data!.transactions!.isNotEmpty,
                    replacement: Container(
                      height: SizeConfig.screenHeight / 3,
                      width: SizeConfig.screenWidth,
                      alignment: Alignment.center,
                      child: Text('No Transaction data!'),
                    ),
                    child: ListView.separated(
                      itemCount: viewModel.transactionResponse.data!.data!.transactions!.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (context, index) {
                        return null;

                        // var item = viewModel.transactionResponse.data!.data!.transactions![index];
                        // return AppTransactionTileWidget(
                        //   item: Transaction(
                        //     id: item.id,
                        //     remark: item.remark,
                        //     value: item.amount,
                        //     createdAt: item.createdAt.toString(),
                        //     creditDebit: item.creditDebit,
                        //   ),
                        // );
                      },
                    ),
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: AppButton(
              text: "Withdraw",
              //  isLoading: (viewModel.withdrawResponse.status == Status.loading ||
              //    viewModel.isLoading),
              onTap: () async {
                if (viewModel.paymentDetail == null) {
                  return Utils.flushBar(
                    "Please add the bank details to proceed with the withdrawal request.",
                    duration: 5,
                  );
                }

                AppDialog.showAmountDialog(
                  controller: viewModel.amountController,
                  onConfirm: () async {
                    //  await viewModel.withdrawBalance();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Please enter a valid number';
                    }
                    if (number == 0) {
                      return 'Amount cannot be 0';
                    }
                    if (number < 0) {
                      return 'You must enter positive amount';
                    }
                    if (number > viewModel.walletBalance) {
                      return "Amount cannot be greater than wallet balance";
                    }
                    return null;
                  },
                );
              },
            ),
          ),
        );
      default:
        return AppNoDataWidget();
    }
  }
}
