import 'dart:async';

import 'package:creatoo/core.dart';
import 'package:creatoo/features/creator_wallet/model/transaction_details.dart';
import 'package:creatoo/features/wallet/view_model/wallet_view_model.dart';
import 'package:creatoo/features/wallet/widgets/wallet_calendar_dialog.dart';
import 'package:creatoo/features/wallet/model/business_wallet_transaction_response.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  late WalletViewModel walletViewModel;

  @override
  void initState() {
    super.initState();
    walletViewModel = Provider.of<WalletViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      walletViewModel.init();
    });
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return "Select Date";
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')}-${months[date.month - 1]}-${date.year}';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => WalletCalendarDialog(
        viewModel: walletViewModel,
        onDateRangeSelected: (startDate, endDate) async {
          walletViewModel.selectedDate = startDate;
          walletViewModel.selectedEndDate = endDate;
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    walletViewModel = Provider.of<WalletViewModel>(context);
    switch (walletViewModel.walletResponse.status) {
      case Status.loading:
        return AppLoadingWidget();

      case Status.error:
        return AppErrorWidget(message: walletViewModel.walletResponse.message.toString());
      case Status.completed:
        return AppScaffold(
          appBar: AppBarWidget(
            title: "Earning View",
            disableLeadingButton: true,
          ),
          isSafe: true,
          body: Container(
            margin: EdgeInsets.all(16),
            child: RefreshIndicator(
              onRefresh: () async {
                await walletViewModel.fetchBusinessWalletTransactions();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Stack(
                    children: [
                      SvgPicture.asset(
                        width: SizeConfig.screenWidth,
                        AppIcon.walletBg,
                      ),
                      AppWalletCard(
                        value: walletViewModel.selectedDate != null && walletViewModel.selectedEndDate != null
                          ? walletViewModel.getSettlementForDateRange(walletViewModel.selectedDate!, walletViewModel.selectedEndDate!)
                          : 0.0,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text(
                        'Transactions',
                        style: AppTextStyles.body(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Tooltip(
                        margin: EdgeInsets.symmetric(horizontal: 20),
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
                          text: Constants.walletInfo2,
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
                  SizedBox(height: 10.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date Range',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 5.w),
                      Spacer(),
                      InkWell(
                        onTap: () => _selectDateRange(context),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 3.5.h),
                              child: Text(
                                walletViewModel.selectedEndDate != null && 
                                    walletViewModel.selectedDate != walletViewModel.selectedEndDate
                                  ? '${_formatDateForDisplay(walletViewModel.selectedDate)} - ${_formatDateForDisplay(walletViewModel.selectedEndDate)}'
                                  : _formatDateForDisplay(walletViewModel.selectedDate),
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 20.h,
                              color: AppColor.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        buildSearchField(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Visibility(
                    visible: walletViewModel.selectedDate != null && walletViewModel.selectedEndDate != null && 
                             walletViewModel.getTransactionsForDateRange(walletViewModel.selectedDate!, walletViewModel.selectedEndDate!).isNotEmpty,
                    replacement: Container(
                      height: SizeConfig.screenHeight / 5,
                      width: SizeConfig.screenWidth,
                      alignment: Alignment.center,
                      child: Text('No Transaction data for selected date range!'),
                    ),
                    child: Builder(
                      builder: (context) {
                        final transactions = walletViewModel.selectedDate != null && walletViewModel.selectedEndDate != null
                            ? walletViewModel.getTransactionsForDateRange(walletViewModel.selectedDate!, walletViewModel.selectedEndDate!)
                            : <Transaction>[];
                        return ListView.separated(
                          itemCount: transactions.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
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
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );

      default:
        return const AppNoDataWidget();
    }
  }

  SizedBox buildSearchField() {
    return SizedBox(
      height: 50.h,
      child: TextFormField(
        controller: walletViewModel.searchController,
        onFieldSubmitted: (value) async {
          if (value.trim().isEmpty) {
            await walletViewModel.fetchBusinessWalletTransactions();
          } else {
            await walletViewModel.fetchBusinessWalletTransactions();
          }
        },
        onChanged: (value) async {
          if (value.trim().isEmpty) {
            // await viewModel.init(viewModel.userRole);
          }
        },
        decoration: InputDecoration(
          fillColor: AppColor.white,
          filled: true,
          hintText: "Search by Order Id...",
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          suffixIconConstraints: const BoxConstraints.tightForFinite(width: 40, height: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
          ),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
