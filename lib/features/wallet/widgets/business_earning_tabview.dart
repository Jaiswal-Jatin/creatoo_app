import 'package:creatoo/features/wallet/model/business_wallet_transaction_response.dart';

import '../../../core.dart';
import '../../creator_wallet/model/transaction_details.dart';
import '../view_model/business_wallet_earning_view_model.dart';
import '../widgets/business_wallet_calendar.dart';
import 'package:intl/intl.dart';

class BusinessEarningTabview extends StatefulWidget {
  const BusinessEarningTabview({super.key});

  @override
  State<BusinessEarningTabview> createState() => _BusinessEarningTabviewState();
}

class _BusinessEarningTabviewState extends State<BusinessEarningTabview> {
  late BusinessWalletEarningViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<BusinessWalletEarningViewModel>(context, listen: false);
    viewModel.init();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SvgPicture.asset(
                        width: SizeConfig.screenWidth,
                        AppIcon.walletBg,
                      ),
                      AppWalletCard(
                        value: viewModel.selectedDate != null
                            ? viewModel.getSettlementForDate(viewModel.selectedDate!)
                            : viewModel.walletBalance.toDouble(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  
                  // Calendar Widget
                  BusinessWalletCalendar(viewModel: viewModel),
                  
                  SizedBox(height: 10.h),
                  
                  // Filter indicator and clear button
                  if (viewModel.selectedDate != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.filter_alt, color: Colors.blue, size: 18),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${DateFormat('dd MMM yyyy').format(viewModel.selectedDate!)}',
                                    style: AppTextStyles.body(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => viewModel.clearDateFilter(),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.clear, color: Colors.red, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        viewModel.selectedDate != null 
                            ? 'Transactions' 
                            : 'Daily Settlements',
                        style: AppTextStyles.body(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      if (viewModel.selectedDate != null)
                        Text(
                          '₹${viewModel.getSettlementForDate(viewModel.selectedDate!).toStringAsFixed(2)}',
                          style: AppTextStyles.body(
                            fontWeight: FontWeight.w700, 
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  
                  // Show grouped settlements or filtered transactions
                  Visibility(
                    visible: viewModel.groupedTransactions.isNotEmpty,
                    replacement: Container(
                      height: SizeConfig.screenHeight / 3,
                      width: SizeConfig.screenWidth,
                      alignment: Alignment.center,
                      child: Text('No Transaction data!'),
                    ),
                    child: viewModel.selectedDate != null
                        ? _buildTransactionList()
                        : _buildDailySettlementList(),
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: AppButton(
              text: "Withdraw",
              onTap: () async {
                if (viewModel.paymentDetail == null) {
                  return Utils.flushBar(
                    "Please add the bank details to proceed with the withdrawal request.",
                    duration: 5,
                  );
                }

                AppDialog.showAmountDialog(
                  controller: viewModel.amountController,
                  onConfirm: () async {},
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

  // Build list of transactions for selected date
  Widget _buildTransactionList() {
    DateTime selectedDate = viewModel.selectedDate!;
    List<Transaction> transactions = viewModel.groupedTransactions[selectedDate] ?? [];
    
    return ListView.separated(
      itemCount: transactions.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        var item = transactions[index];
        return AppTransactionTileWidget(
          item: TransactionDetails(
            receivedFrom: item.receivedFrom,
            totalBill: item.totalBill,
            dateTime: item.created_at,
            orderId: item.referenceNumber,
            discountPercentage: item.discountPercentage,
          ),
        );
      },
    );
  }

  // Build list of daily settlement amounts
  Widget _buildDailySettlementList() {
    var dates = viewModel.groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Latest first
    
    return ListView.separated(
      itemCount: dates.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        DateTime date = dates[index];
        double settlement = viewModel.getSettlementForDate(date);
        int transactionCount = viewModel.groupedTransactions[date]!.length;
        
        return ListTile(
          leading: Icon(Icons.calendar_today, color: Colors.green),
          title: Text(
            DateFormat('dd MMM yyyy').format(date),
            style: AppTextStyles.body(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('$transactionCount transactions'),
          trailing: Text(
            '₹${settlement.toStringAsFixed(2)}',
            style: AppTextStyles.body(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
          onTap: () {
            viewModel.selectDate(date);
          },
        );
      },
    );
  }
}
