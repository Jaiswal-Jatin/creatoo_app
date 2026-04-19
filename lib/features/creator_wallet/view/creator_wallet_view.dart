import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/app_text_widget.dart';

import '../view_model/creator_wallet_view_model.dart';
import '../widgets/creatoo_tab_view.dart';
import '../widgets/earning_tab_view.dart';

final GlobalKey<_CreatorWalletViewState> creatorWalletKey =
    GlobalKey<_CreatorWalletViewState>();

class CreatorWalletView extends StatefulWidget {
  final int index;
  const CreatorWalletView({super.key, this.index = 0});

  @override
  State<CreatorWalletView> createState() => _CreatorWalletViewState();
}

class _CreatorWalletViewState extends State<CreatorWalletView> {
  late CreatorWalletViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CreatorWalletViewModel>(context);
    return AppScaffold(
      useGradient: false,
      backgroundColor: Colors.transparent, // Inherit HomePage Gradient
      isSafe: false,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumHeader(),
            SizedBox(height: 15.h),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: AppSlidingSegmentController(
                name1: "Transaction",
                name2: "Creatoo",
                index: viewModel.currentSelection,
                onTap: (index) {
                  viewModel.changeIndex(index);
                },
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: IndexedStack(
                index: viewModel.currentSelection,
                children: [
                  EarningTabView(),
                  CreatooTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Row(
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
      ),
    );
  }
}
