import '../../../core.dart';
import '../widgets/business_creatoo_tabview.dart';
import 'wallet_view.dart';

final GlobalKey<_BusinessWalletViewState> businessWalletKey =
    GlobalKey<_BusinessWalletViewState>();

class BusinessWalletView extends StatefulWidget {
  final int index;
  const BusinessWalletView({super.key, this.index = 0});

  @override
  State<BusinessWalletView> createState() => _BusinessWalletViewState();
}

class _BusinessWalletViewState extends State<BusinessWalletView> {
  int _currentSelection = 0;

  final List<Widget> _widgetOptions = <Widget>[
    WalletView(),
    BusinessCreatooTabview(),
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.index == 1) _currentSelection = widget.index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeIndex(int index) {
    setState(() {
      _currentSelection = index;
    });
  }

  @override
  void didUpdateWidget(covariant BusinessWalletView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update _currentSelection if widget.index changes
    if (oldWidget.index != widget.index) {
      setState(() {
        _currentSelection = widget.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: AppSlidingSegmentController(
              name1: "Earning",
              name2: "Creatoo",
              index: widget.index,
              onTap: (index) {
                setState(() {
                  _currentSelection = index;
                });
              },
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(child: _widgetOptions[_currentSelection]),
        ],
      ),
    );
  }
}
