import 'dart:async';

import 'package:creatoo/core.dart';
import 'package:creatoo/features/creator_wallet/model/transaction_details.dart';
import 'package:creatoo/features/wallet/view_model/wallet_view_model.dart';
import 'package:creatoo/features/wallet/widgets/wallet_calendar_dialog.dart';
import 'package:creatoo/features/wallet/model/business_wallet_transaction_response.dart';
import 'package:creatoo/widgets/app_text_widget.dart';

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
          useGradient: false,
          backgroundColor: Colors.transparent, // Inherits Home Gradient
          extendBody: true, 
          isSafe: false,
          body: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h),
            margin: EdgeInsets.all(16),
            child: RefreshIndicator(
              color: AppColor.premiumAccent,
              backgroundColor: AppColor.premiumCardBg,
              onRefresh: () async {
                await walletViewModel.fetchBusinessWalletTransactions();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                children: [
                  _buildPremiumHeader(),
                  SizedBox(height: 20.h),
                  Stack(
                    children: [
                      Container(
                        height: 180.h,
                        decoration: BoxDecoration(
                           color: AppColor.premiumCardBg,
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.2),
                           boxShadow: [
                             BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                             )
                           ]
                        ),
                      ),
                      AppWalletCard(
                        value: walletViewModel.selectedDate != null && walletViewModel.selectedEndDate != null
                          ? walletViewModel.getSettlementForDateRange(walletViewModel.selectedDate!, walletViewModel.selectedEndDate!)
                          : 0.0,
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),
                  Row(
                    children: [
                      Text(
                        'Transactions',
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.premiumTextPrimary,
                        ),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Tooltip(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColor.premiumCardBg,
                          border: Border.all(color: AppColor.premiumAccent.withOpacity(0.3)),
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
                            color: AppColor.premiumTextPrimary,
                            fontSize: 14.sp,
                          ),
                          children: [],
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: 20.h,
                          color: AppColor.premiumAccent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date Range',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColor.premiumTextSecondary),
                      ),
                      SizedBox(height: 10.h),

                      InkWell(
                        onTap: () => _selectDateRange(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColor.premiumCardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                walletViewModel.selectedEndDate != null &&
                                    walletViewModel.selectedDate !=
                                        walletViewModel.selectedEndDate
                                    ? '${_formatDateForDisplay(walletViewModel.selectedDate)} - ${_formatDateForDisplay(walletViewModel.selectedEndDate)}'
                                    : _formatDateForDisplay(walletViewModel.selectedDate),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.premiumTextPrimary,
                                ),
                              ),
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 20.h,
                                color: AppColor.premiumAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
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
                      child: Text('No Transaction data for selected date range!', style: TextStyle(color: AppColor.premiumTextSecondary)),
                    ),
                    child: Builder(
                      builder: (context) {
                        final transactions = walletViewModel.selectedDate != null && walletViewModel.selectedEndDate != null
                            ? walletViewModel.getTransactionsForDateRange(walletViewModel.selectedDate!, walletViewModel.selectedEndDate!)
                            : <Transaction>[];
                        return ListView.separated(
                          itemCount: transactions.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 100.h),
                          physics: NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 10.h);
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

  Widget _buildPremiumHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextWidget(
                text: "CREATOO",
                fontSize: 11.sp,
                color: AppColor.premiumAccent,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
              SizedBox(height: 2.h),
              AppTextWidget(
                text: "My Wallet",
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.premiumTextPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  SizedBox buildSearchField() {
    return SizedBox(
      height: 55.h,
      child: TextFormField(
        controller: walletViewModel.searchController,
        style: TextStyle(color: AppColor.premiumTextPrimary, fontSize: 14.sp),
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
          fillColor: AppColor.premiumCardBg,
          filled: true,
          hintText: "Search by Order Id...",
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColor.premiumTextSecondary,
          ),
          suffixIconConstraints: const BoxConstraints.tightForFinite(width: 40, height: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColor.premiumAccent.withOpacity(0.5)),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: AppColor.premiumAccent),
        ),
      ),
    );
  }
}
