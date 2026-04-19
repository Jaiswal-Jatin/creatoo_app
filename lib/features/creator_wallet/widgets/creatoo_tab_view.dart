import 'package:intl/intl.dart';

import '../../../core.dart';
import '../model/creator_creatoo_transaction_response.dart';
import '../view_model/creator_wallet_view_model.dart';

class CreatooTabView extends StatefulWidget {
  const CreatooTabView({super.key});

  @override
  State<CreatooTabView> createState() => _CreatooTabViewState();
}

class _CreatooTabViewState extends State<CreatooTabView> {
  late CreatorWalletViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<CreatorWalletViewModel>(context, listen: false);
    viewModel.fetchCreatorCreatooWalletTransaction();
  }

  String _getTransactionLabel(String? creditDebit) {
    switch (creditDebit) {
      case "credit":
        return 'Earned';
      case "debit":
        return 'Redeemed';
      default:
        return 'Unknown';
    }
  }

  String _getTransactionSecondLabel(String? creditDebit) {
    switch (creditDebit) {
      case "credit":
        return 'CREDITED';
      case "debit":
        return 'DEBITED';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CreatorWalletViewModel>(context);

    switch (viewModel.creatooTransactionResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.creatooTransactionResponse.message!);
      case Status.completed:
        return _buildMobileBody();
      default:
        return AppNoDataWidget();
    }
  }

  String _formatDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate).toLocal();
    String formattedDate = DateFormat("dd-MMM-yyyy h:mm a").format(dateTime);
    return formattedDate;
  }

  Widget _buildMobileBody() {
    final businessTransactions =
        viewModel.creatooTransactionResponse.data!.data!.businessTransactions;

    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      viewModel.creatooWalletBalance.toDouble()),
                  showPoints: true,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Text(
                  'Recent transactions',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.premiumTextPrimary,
                  ),
                ),
                // SizedBox(
                //   width: 5.w,
                // ),
                Tooltip(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.premiumCardBg,
                    border: Border.all(
                        color: AppColor.premiumAccent.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enableTapToDismiss: true,
                  showDuration: Duration(seconds: 100),
                  enableFeedback: true,
                  triggerMode: TooltipTriggerMode.tap,
                  preferBelow: true,
                  richMessage: TextSpan(
                    text: Constants.walletInfo,
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
            SizedBox(height: 20.h),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: businessTransactions?.length ?? 0,
              itemBuilder: (context, index) {
                final businessTransaction = businessTransactions![index];
                return _buildBusinessTransactionCard(
                    index, businessTransaction);
              },
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessTransactionCard(
      int index, BusinessTransaction businessTransaction) {
    return AnimatedContainer(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      duration: Duration(milliseconds: 300),
      width: SizeConfig.screenWidth,
      decoration: BoxDecoration(
        color: AppColor.premiumCardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.premiumAccent.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            showTrailingIcon: false,
            tilePadding: EdgeInsets.zero,
            collapsedShape: Border.all(style: BorderStyle.none),
            shape: Border.all(style: BorderStyle.none),
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          businessTransaction.businessName ??
                              'Unknown Business',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColor.premiumTextPrimary),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.premiumTextSecondary),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${businessTransaction.totalPoints?.isNegative == true ? 0.0 : viewModel.roundToTwoDecimalPlaces(businessTransaction.totalPoints?.toDouble() ?? 0.0).toCommaSeparated()} Points',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.premiumTextPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: viewModel.expandedStates[index] == true ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColor.premiumAccent.withOpacity(0.2)),
                        shape: BoxShape.circle,
                        color: AppColor.premiumAccent.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColor.premiumAccent,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            textColor: AppColor.black,
            onExpansionChanged: (bool expanded) {
              viewModel.changeExpandedStates(expanded, index);
            },
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: businessTransaction.transactions?.length ?? 0,
                padding: EdgeInsets.only(top: 10.h),
                separatorBuilder: (context, index) => Divider(
                  thickness: 1.h,
                  indent: 15.w,
                  endIndent: 15.w,
                  color: AppColor.premiumAccent.withOpacity(0.1),
                ),
                itemBuilder: (context, index) {
                  if (businessTransaction.transactions == null) {
                    return SizedBox.shrink();
                  } else {
                    final transaction =
                        businessTransaction.transactions![index];
                    String status = _getTransactionLabel(
                        transaction.creditDebitRemainingStatus);
                    return _buildTransactionRow(
                      label1: status,
                      value1:
                          '${viewModel.roundToTwoDecimalPlaces(transaction.points?.toDouble() ?? 0.0).toCommaSeparated()} points',
                      label2: (status == "Earned")
                          ? ((transaction.expiryDate != null)
                              ? _formatDate(transaction.expiryDate.toString())
                              : '')
                          : ((transaction.createdAt != null)
                              ? _formatDate(transaction.createdAt.toString())
                              : ''),
                      value2: _getTransactionSecondLabel(
                          transaction.creditDebitRemainingStatus),
                      label3: (transaction.isExpired ?? false) ? "Expired" : "",
                      value3: 10,
                      isExpired: transaction.isExpired ?? false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow({
    required String label1,
    required String value1,
    required String label2,
    required String value2,
    String? label3,
    int? value3,
    bool isExpired = false,
  }) {
    final isEarned = label1 == 'Earned';
    final isRejected = label1 == 'Rejected';
    final isPending = label1 == 'Pending';

    String formattedExpirationDate = '';
    if (isEarned && value3 != null && value3 > 0) {
      final DateTime currentDate = DateTime.now();
      final DateTime expirationDate = currentDate.add(Duration(days: value3));
      formattedExpirationDate =
          DateFormat('dd-MMM-yyyy').format(expirationDate);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: (isEarned && label3 == "Expired")
            ? AppColor.lightGrey.withOpacity(0.4)
            : AppColor.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.15),
                ),
                child: Icon(
                  isEarned
                      ? Icons.arrow_downward
                      : isRejected
                          ? Icons.close
                          : isPending
                              ? Icons.access_time
                              : Icons.arrow_upward,
                  color: isEarned
                      ? (isExpired)
                          ? AppColor.premiumTextSecondary
                          : AppColor.premiumAccent
                      : isRejected
                          ? AppColor.darkRed
                          : isPending
                              ? AppColor.mangoYellow
                              : AppColor.premiumAccent,
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
                        Text(label1,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColor.premiumTextSecondary)),
                        Text(value1,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColor.premiumTextPrimary)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        if (isEarned)
                          Text("Valid Through:",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.premiumTextSecondary)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(label2,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.premiumTextSecondary)),
                            Text(value2,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.premiumTextSecondary)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    if (isEarned && label3 == 'Active')
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Valid till',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.premiumTextSecondary)),
                              Text(formattedExpirationDate,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.premiumTextSecondary)),
                            ],
                          ),
                        ],
                      )
                    else if (isExpired && value2 == "CREDITED")
                      Column(
                        children: [
                          SizedBox(height: 5),
                          Text('Expired',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.darkRed)),
                        ],
                      )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
