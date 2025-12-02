import 'package:creatoo/features/add_post_payment_summary/view_model/add_post_payment_summary_view_model.dart';

import '../../../core.dart';
import '../../add_post/model/add_post_model.dart';

class AddPostPaymentSummaryView extends StatefulWidget {
  final AddPostModel data;

  const AddPostPaymentSummaryView({super.key, required this.data});

  @override
  State<AddPostPaymentSummaryView> createState() =>
      _AddPostPaymentSummaryViewState();
}

class _AddPostPaymentSummaryViewState extends State<AddPostPaymentSummaryView> {
  late AddPostSummaryViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<AddPostSummaryViewModel>(context, listen: false);
    viewModel.init(widget.data);
    setState(() {});
  }

  @override
  void dispose() {
    viewModel.disposeData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<AddPostSummaryViewModel>(context);
    switch (viewModel.settingResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
            message: viewModel.settingResponse.message.toString());
      case Status.completed:
        return AppScaffold(
          appBar: AppBarWidget(
            title: "Payments",
          ),
          body: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      "Hello Business Owners!\n\nTo enhance the security of our collaboration, please add funds to your wallet. This allows for a smooth transaction process and ensures that both creators and you are protected. Rest assured, you can easily refund any unused balance later. Your cooperation helps us create a successful partnership.\n\nEnjoy a seamless experience with Creatoo",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Divider(),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Budget',
                            style: AppTextStyles.body(),
                          ),
                          Text(
                            '${Utils.formatCurrency(viewModel.model.getBudget())}',
                            style: AppTextStyles.body(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Platform fees @${viewModel.model.setting!.platformFeePercent}%',
                            style: AppTextStyles.body(),
                          ),
                          Text(
                            '${Utils.formatCurrency(viewModel.model.getPlatformFees())}',
                            style: AppTextStyles.body(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GST @${viewModel.model.getTotalGst()}%',
                            style: AppTextStyles.body(),
                          ),
                          Text(
                            '${Utils.formatCurrency(viewModel.model.getTotalAppliedGst())}',
                            style: AppTextStyles.body(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTextStyles.body(
                                fontSize: 18.sp, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${Utils.formatCurrency(viewModel.model.calculateTotalAmount())}',
                            style: AppTextStyles.body(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          navigatorKey.currentContext!,
                          RoutesName.webView,
                          arguments: WebViewData(
                            "",
                            "${AppUrl.host}/api/terms-conditions.html",
                            enableAppBar: true,
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "By clicking “Payment”, you accept the ",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColor.darkGrey,
                              ),
                            ),
                            TextSpan(
                              text: "terms.",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B4EFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AppButton(
                      text: "Make Payment",
                      isLoading: viewModel.isLoading,
                      onTap: () async {
                        await viewModel.makePayment();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      default:
        return const AppNoDataWidget();
    }
  }
}
