import 'package:creatoo/core.dart';
import '../widgets/business_booking_transactions_tab.dart';
import '../widgets/business_wallet_payments_tab.dart';
import '../widgets/business_wallet_settlements_tab.dart';

class BusinessWalletView extends StatefulWidget {
  final int index;
  const BusinessWalletView({super.key, this.index = 0});

  @override
  State<BusinessWalletView> createState() => _BusinessWalletViewState();
}

class _BusinessWalletViewState extends State<BusinessWalletView> {
  int _currentSelection = 0;

  final List<Widget> _widgetOptions = const <Widget>[
    BusinessWalletPaymentsTab(),
    BusinessBookingTransactionsTab(),
    BusinessWalletSettlementsTab(),
  ];

  final List<String> _tabLabels = ["Payments", "Booking Transactions", "Settlements"];

  @override
  void initState() {
    super.initState();
    if (widget.index < _tabLabels.length) _currentSelection = widget.index;
  }

  void changeIndex(int index) {
    setState(() {
      _currentSelection = index;
    });
  }

  @override
  void didUpdateWidget(covariant BusinessWalletView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      if (widget.index < _tabLabels.length) _currentSelection = widget.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
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
                  SizedBox(height: 16.h),
                  Row(
                    children: List.generate(_tabLabels.length, (i) {
                      final sel = _currentSelection == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentSelection = i),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: sel ? AppColor.premiumAccent.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: sel ? AppColor.premiumAccent : Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Text(
                              _tabLabels[i],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: sel ? AppColor.premiumAccent : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(child: _widgetOptions[_currentSelection]),
          ],
        ),
      ),
    );
  }
}
