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
        return AppErrorWidget(message: viewModel.earningTransactionResponse.message!);
      case Status.completed:
        return AppScaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 0),
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
                  //   ],
                  // ),
                  SizedBox(height: 20.h),
                  Text(
                    'Recent transactions',
                    style: AppTextStyles.body(fontWeight: FontWeight.w700),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        buildSearchField(),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Visibility(
                    visible: viewModel.earningTransactionResponse.data!.data!.transactions!.isNotEmpty,
                    replacement: Container(
                      height: SizeConfig.screenHeight / 3,
                      width: SizeConfig.screenWidth,
                      alignment: Alignment.center,
                      child: Text('No Transaction data!'),
                    ),
                    child: ListView.separated(
                      itemCount: viewModel.earningTransactionResponse.data!.data!.transactions!.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (context, index) {
                        var item = viewModel.earningTransactionResponse.data!.data!.transactions![index];
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
          fillColor: AppColor.white,
          filled: true,
          hintText: "Search by Order Id or Name...",
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
