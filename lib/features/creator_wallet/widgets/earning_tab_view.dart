import '../../../core.dart';
import '../model/transaction_details.dart';
import '../view_model/creator_wallet_view_model.dart';

class EarningTabView extends StatefulWidget {
  const EarningTabView({super.key});

  @override
  State<EarningTabView> createState() => _EarningTabViewState();
}

class _EarningTabViewState extends State<EarningTabView> {
  late CreatorWalletViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<CreatorWalletViewModel>(context, listen: false);
    viewModel.searchController.text = "";
    viewModel.fetchCreatorEarningWalletTransaction();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CreatorWalletViewModel>(context);
    switch (viewModel.earningTransactionResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.earningTransactionResponse.message!);
      case Status.completed:
        return Container(
          color: Colors.transparent,
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stack(
                //   children: [
                //     SvgPicture.asset(
                //       width: SizeConfig.screenWidth,
                //       AppIcon.walletBg,
                //     ),
                //       AppWalletCard(value: viewModel.walletBalance),
                // ),
                SizedBox(height: 10.h),
                Text(
                  'Recent transactions',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.premiumTextPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      buildSearchField(),
                    ],
                  ),
                ),
                // SizedBox(height: 20.h),
                Visibility(
                  visible: viewModel.earningTransactionResponse.data!.data!
                      .transactions!.isNotEmpty,
                  replacement: Container(
                    height: SizeConfig.screenHeight / 3,
                    width: SizeConfig.screenWidth,
                    alignment: Alignment.center,
                    child: Text('No Transaction data!'),
                  ),
                  child: ListView.separated(
                    itemCount: viewModel.earningTransactionResponse.data!.data!
                        .transactions!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10.h);
                    },
                    itemBuilder: (context, index) {
                      var item = viewModel.earningTransactionResponse.data!
                          .data!.transactions![index];
                      return AppTransactionTileWidget(
                        item: TransactionDetails(
                          paidTo: item.paidTo,
                          dateTime: item.dateTime,
                          finalBill: item.finalBill,
                          totalBill: item.totalBill,
                          orderId: item.referenceNumber,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        );
      default:
        return AppNoDataWidget();
    }
  }

  SizedBox buildSearchField() {
    return SizedBox(
      height: 50.h,
      child: TextFormField(
        controller: viewModel.searchController,
        onFieldSubmitted: (value) async {
          if (value.trim().isEmpty) {
            await viewModel.fetchCreatorEarningWalletTransaction();
          } else {
            await viewModel.fetchCreatorEarningWalletTransaction();
          }
        },
        onChanged: (value) async {
          if (value.trim().isEmpty) {
            viewModel.fetchCreatorEarningWalletTransaction();
          }
        },
        decoration: InputDecoration(
          fillColor: AppColor.premiumCardBg,
          filled: true,
          hintText: "Search by Order Id or Name...",
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColor.premiumTextSecondary,
          ),
          suffixIconConstraints:
              const BoxConstraints.tightForFinite(width: 40, height: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColor.premiumAccent.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColor.premiumAccent.withOpacity(0.6)),
          ),
          prefixIcon: Icon(Icons.search, color: AppColor.premiumAccent),
        ),
        style: TextStyle(color: AppColor.premiumTextPrimary),
      ),
    );
  }
}
