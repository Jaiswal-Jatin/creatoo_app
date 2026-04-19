import 'package:intl/intl.dart';

import '../../../core.dart';
import '../model/business_wallet_transaction_point_response.dart';
import '../view_model/businees_wallet_creatoo_view_model.dart';

class BusinessCreatooTabview extends StatefulWidget {
  const BusinessCreatooTabview({super.key});

  @override
  State<BusinessCreatooTabview> createState() => _BusinessCreatooTabviewState();
}

class _BusinessCreatooTabviewState extends State<BusinessCreatooTabview> {
  late BusinessWalletCreatooViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel =
        Provider.of<BusinessWalletCreatooViewModel>(context, listen: false);
    viewModel.init();
  }

  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return "Select Date";
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')}-${months[date.month - 1]}-${date.year}';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });

      await viewModel.getTransactionPointRange(_fromDate!, _toDate!);

      // navigatorKey.currentContext;
    }
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<BusinessWalletCreatooViewModel>(context);
    switch (viewModel.transactionCreatorResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.transactionCreatorResponse.message!);
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
                      AppWalletCard(
                        value: viewModel.roundToTwoDecimalPlaces(
                            viewModel.walletBalanceCreato?.toDouble() ?? 0.0),
                        showPoints: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date Range',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (_fromDate != null)
                                    Row(
                                      children: [
                                        Text(
                                          _formatDateForDisplay(_fromDate),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        if (_formatDateForDisplay(_fromDate) !=
                                            _formatDateForDisplay(_toDate))
                                          Text(
                                            " - ",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                      ],
                                    ),
                                  if (_toDate != null &&
                                      _formatDateForDisplay(_fromDate) !=
                                          _formatDateForDisplay(_toDate))
                                    Text(
                                      _formatDateForDisplay(_toDate),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                ],
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
                  SizedBox(height: 20.h),
                  Visibility(
                    visible: viewModel.transactions.isNotEmpty,
                    replacement: Container(
                      height: SizeConfig.screenHeight / 3,
                      width: SizeConfig.screenWidth,
                      alignment: Alignment.center,
                      child: Text('No Transaction data!'),
                    ),
                    child: ListView.separated(
                      itemCount: viewModel.transactions.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        final transaction = viewModel.transactions[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        );
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildTransactionCard(Transactions transaction) {
    DateTime createdAt = transaction.createdAt!.toLocal();
    String formattedTime = DateFormat('hh:mm a').format(createdAt);

    return Container(
      width: SizeConfig.screenWidth,
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Circle with icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: transaction.status == 'Debited'
                  ? AppColor.lightButtonGrey
                  : AppColor.darkButtonGrey,
            ),
            child: Icon(
              transaction.status == 'Debited'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: transaction.status == 'Debited'
                  ? AppColor.darkRed
                  : AppColor.green,
              size: 24,
            ),
          ),

          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      child: Text(
                        transaction.status == 'Debited'
                            ? 'Released to ${transaction.instagramUsername ?? transaction.creatorName}'
                            : 'Redeemed by ${transaction.instagramUsername ?? transaction.creatorName}',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                    Text(
                      '${viewModel.roundToTwoDecimalPlaces(transaction.points?.toDouble() ?? 0.0)} Points',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: transaction.status == 'Debited'
                            ? AppColor.darkRed
                            : AppColor.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColor.darkGrey,
                      ),
                    ),
                    Text(
                      '${transaction.status}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColor.darkGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
