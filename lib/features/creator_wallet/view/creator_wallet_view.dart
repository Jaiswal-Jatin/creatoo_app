import 'package:creatoo/core.dart';

import '../view_model/creator_wallet_view_model.dart';
import '../widgets/creatoo_tab_view.dart';
import '../widgets/earning_tab_view.dart';

final GlobalKey<_CreatorWalletViewState> creatorWalletKey = GlobalKey<_CreatorWalletViewState>();

class CreatorWalletView extends StatefulWidget {
  int index;
  CreatorWalletView({Key? key, this.index = 0}) : super(key: key);

  @override
  State<CreatorWalletView> createState() => _CreatorWalletViewState();
}

class _CreatorWalletViewState extends State<CreatorWalletView> {
  late CreatorWalletViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CreatorWalletViewModel>(context);
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: AppSlidingSegmentController(
              name1: "Transaction",
              name2: "Creatoo",
              index: viewModel.currentSelection,
              onTap: (index) {
                viewModel.changeIndex(index);
              },
            ),
          ),
          SizedBox(height: 10.h),
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
    );
  }
}
