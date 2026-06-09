import 'dart:ui';
import 'package:creatoo/features/user_payments/repository/user_payments_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:creatoo/core.dart';
import '../../user_payments/view_model/user_payments_view_model.dart';

class _UpiApp {
  final String name;
  final String url;
  const _UpiApp(this.name, this.url);
}

class UserPaymentSubmitScreen extends StatefulWidget {
  final int businessId;
  final String businessName;
  final String? businessImage;
  final double? prefilledAmount;

  const UserPaymentSubmitScreen({
    super.key,
    required this.businessId,
    required this.businessName,
    this.businessImage,
    this.prefilledAmount,
  });

  @override
  State<UserPaymentSubmitScreen> createState() => _UserPaymentSubmitScreenState();
}

class _UserPaymentSubmitScreenState extends State<UserPaymentSubmitScreen> {
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _pointsCtrl = TextEditingController();
  double _rawFinalAmount = 0;
  int _availablePoints = 0;
  bool _showCalculation = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledAmount != null && widget.prefilledAmount! > 0) {
      _amountCtrl.text = widget.prefilledAmount!.toStringAsFixed(0);
      _rawFinalAmount = widget.prefilledAmount!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<UserPaymentsViewModel>();
      vm.loadBusinessPoints(widget.businessId);
      vm.loadTodayVisitCount(widget.businessId);
      vm.clearCalculation();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    final bill = double.tryParse(_amountCtrl.text) ?? 0;
    final pts = int.tryParse(_pointsCtrl.text) ?? 0;
    setState(() {
      _rawFinalAmount = (bill - pts).clamp(0, double.infinity);
    });
  }

  Future<void> _proceedToCalculation() async {
    final billAmount = double.tryParse(_amountCtrl.text);
    if (billAmount == null || billAmount <= 0) {
      Utils.toastMessage("Please enter a valid bill amount");
      return;
    }
    final pts = int.tryParse(_pointsCtrl.text) ?? 0;
    final maxRedeemable = (_availablePoints * 0.60).floor();
    if (pts > maxRedeemable) {
      Utils.toastMessage("You can only redeem up to 60% of your total points (Max: $maxRedeemable points)");
      return;
    }
    if (pts > _availablePoints) {
      Utils.toastMessage("You only have $_availablePoints points available");
      return;
    }

    final vm = context.read<UserPaymentsViewModel>();
    final success = await vm.calculatePayment(
      businessId: widget.businessId,
      billAmount: billAmount,
      pointsRedeemed: pts,
    );

    if (!mounted) return;
    if (success) {
      setState(() => _showCalculation = true);
    } else {
      Utils.toastMessage(vm.error ?? "Failed to calculate payment");
    }
  }

  Future<void> _payViaUpi() async {
    final vm = context.read<UserPaymentsViewModel>();
    final calc = vm.calculation;
    if (calc == null || calc.upiId.isEmpty) {
      Utils.toastMessage("UPI ID not configured for this business");
      return;
    }

    if (Platform.isIOS) {
      await _showUpiAppPicker(calc);
    } else {
      final uri = Uri.parse(
        "upi://pay?pa=${calc.upiId}&am=${calc.finalAmount.toStringAsFixed(0)}&tn=Payment+to+${widget.businessName}&cu=INR",
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Utils.toastMessage("No UPI app found. Please install GPay/PhonePe.");
      }
      if (!mounted) return;
      _navigateToPaymentProcessing(calc);
    }
  }

  Future<void> _showUpiAppPicker(PaymentCalculation calc) async {
    final upiParams =
        "pa=${calc.upiId}"
        "&pn=${Uri.encodeComponent(widget.businessName)}"
        "&am=${calc.finalAmount.toStringAsFixed(0)}"
        "&tn=Payment+to+${Uri.encodeComponent(widget.businessName)}"
        "&cu=INR";

    final upiApps = [
      _UpiApp("Google Pay", "tez://upi/pay?$upiParams"),
      _UpiApp("PhonePe", "phonepe://pay?$upiParams"),
      _UpiApp("Paytm", "paytmmp://upi/pay?$upiParams"),
      _UpiApp("CRED", "credpay://upi/pay?$upiParams"),
      _UpiApp("BHIM", "bhim://upi/pay?$upiParams"),
      _UpiApp("Amazon Pay", "amazonpay://upi/pay?$upiParams"),
      _UpiApp("MobiKwik", "mobikwik://upi/pay?$upiParams"),
      _UpiApp("Freecharge", "freecharge://upi/pay?$upiParams"),
      _UpiApp("WhatsApp", "whatsapp://upi/pay?$upiParams"),
      _UpiApp("PayZapp", "payzapp://upi/pay?$upiParams"),
      _UpiApp("Navi", "navi://upi/pay?$upiParams"),
      _UpiApp("Kiwi", "kiwi://upi/pay?$upiParams"),
      _UpiApp("Jupiter", "jupiter://upi/pay?$upiParams"),
      _UpiApp("SBI Yono", "sbiyono://upi/pay?$upiParams"),
      _UpiApp("MyJio", "myjio://upi/pay?$upiParams"),
      _UpiApp("BOB UPI", "bobupi://upi/pay?$upiParams"),
      _UpiApp("ICICI ICash", "icici://upi/pay?$upiParams"),
      _UpiApp("Slice", "slice-upi://upi://pay?$upiParams"),
      _UpiApp("OMNI Card", "omnicard://upi/pay?$upiParams"),
      _UpiApp("Shriram One", "shriramone://upi/pay?$upiParams"),
      _UpiApp("Indus Mobile", "indusmobile://upi/pay?$upiParams"),
    ];

    final availableApps = <_UpiApp>[];
    for (final app in upiApps) {
      final uri = Uri.parse(app.url);
      if (await canLaunchUrl(uri)) {
        availableApps.add(app);
      }
    }

    if (!mounted) return;

    if (availableApps.isEmpty) {
      Utils.toastMessage("No UPI app found. Please install GPay/PhonePe.");
      _navigateToPaymentProcessing(calc);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.premiumCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Pay via",
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ...availableApps.map(
              (app) => GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  launchUrl(Uri.parse(app.url), mode: LaunchMode.externalApplication);
                  _navigateToPaymentProcessing(calc);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: AppColor.premiumLightCardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.h,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: AppColor.premiumAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            app.name[0],
                            style: GoogleFonts.montserrat(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.premiumAccent,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        app.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.white38),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPaymentProcessing(PaymentCalculation calc) {
    Navigator.pushReplacementNamed(context, RoutesName.paymentProcessingView, arguments: {
      'businessId': widget.businessId,
      'businessName': widget.businessName,
      'amount': calc.finalAmount,
      'billAmount': calc.billAmount,
      'pointsRedeemed': calc.pointsRedeemed,
      'discountPercentage': calc.discountPercentage,
      'discountAmount': calc.discountAmount,
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserPaymentsViewModel>();
    _availablePoints = vm.businessPoints;
    final calc = vm.calculation;

    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          Positioned(top: -100.h, right: -50.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(width: 350.w, height: 350.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.premiumAccent.withValues(alpha: 0.12))),
          )),
          Positioned(bottom: 50.h, left: -80.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(width: 300.w, height: 300.w, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withValues(alpha: 0.08))),
          )),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.w),
              child: Column(
                children: [
                  Align(alignment: Alignment.centerLeft, child: CustomBackButton(onTap: () {
                    if (_showCalculation) {
                      setState(() => _showCalculation = false);
                    } else {
                      Navigator.pop(context);
                    }
                  })),
                  SizedBox(height: 20.h),

                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.premiumAccent.withValues(alpha: 0.3), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundImage: widget.businessImage != null
                                ? NetworkImage(widget.businessImage!)
                                : null,
                            child: widget.businessImage == null
                                ? Icon(Icons.store, size: 32.sp, color: Colors.white38)
                                : null,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          widget.businessName,
                          style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        SizedBox(height: 4.h),
                        Text(_showCalculation ? "Review your payment" : "Pay & redeem your points",
                          style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  if (!_showCalculation) ..._buildInputSection(),
                  if (_showCalculation && calc != null) ..._buildCalculationSection(calc),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInputSection() {
    return [
      Consumer<UserPaymentsViewModel>(
        builder: (context, vm, _) {
          final tierColors = {
            'premium': const Color(0xFFFFD700),
            'elite': const Color(0xFFC0C0C0),
            'core': const Color(0xFFCD7F32),
            'new': const Color(0xFFFFD700),
          };
          final tierLabels = {
            'premium': 'Premium',
            'elite': 'Elite',
            'core': 'Core',
            'new': 'New',
          };
          final tierIcons = {
            'premium': Icons.diamond_rounded,
            'elite': Icons.stars_rounded,
            'core': Icons.favorite_rounded,
            'new': Icons.fiber_new_rounded,
          };
          final tierColor = tierColors[vm.todayVisitTier] ?? Colors.grey;
          final tierLabel = tierLabels[vm.todayVisitTier] ?? 'New';
          final tierIcon = tierIcons[vm.todayVisitTier] ?? Icons.fiber_new_rounded;

          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tierColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tierColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(tierIcon, color: tierColor, size: 16.sp),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Today's Visit",
                                  style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                if (vm.todayVisitCount > 0) ...[
                                  SizedBox(width: 4.w),
                                  Text("#${vm.todayVisitCount}",
                                    style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: tierColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(tierLabel,
                                    style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.w700, color: tierColor),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text("at ${widget.businessName}",
                                  style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                Text("Enter Bill Amount",
                  style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white54),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontSize: 36.sp, fontWeight: FontWeight.w800, color: Colors.white),
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    prefixStyle: GoogleFonts.montserrat(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Colors.white38),
                    hintText: "0",
                    hintStyle: GoogleFonts.montserrat(fontSize: 36.sp, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.1)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColor.premiumAccent.withValues(alpha: 0.3), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColor.premiumAccent, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  ),
                  onChanged: (_) => _recalculate(),
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(height: 16.h),
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColor.mangoYellow.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColor.mangoYellow.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.mangoYellow.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.monetization_on_rounded, color: AppColor.mangoYellow, size: 16.sp),
                    ),
                    SizedBox(width: 10.w),
                    Text("Your Points",
                      style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white60),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Points",
                            style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.white38),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _availablePoints.toString(),
                            style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 35.h,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Redeemable (60%)",
                            style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColor.mangoYellow.withValues(alpha: 0.8)),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            (_availablePoints * 0.60).floor().toString(),
                            style: GoogleFonts.montserrat(fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppColor.mangoYellow),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text("1 point = ₹1",
                  style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white24),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColor.mangoYellow.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.mangoYellow.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColor.mangoYellow,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          "Note: You can redeem a maximum of 60% of your total Creatoo points for this payment (Max: ${(_availablePoints * 0.60).floor()} Points).",
                          style: GoogleFonts.montserrat(
                            fontSize: 11.sp,
                            color: AppColor.mangoYellow,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Divider(color: Colors.white.withValues(alpha: 0.06)),
                SizedBox(height: 12.h),
                TextField(
                  controller: _pointsCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColor.mangoYellow),
                  decoration: InputDecoration(
                    hintText: "Enter points to redeem",
                    hintStyle: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColor.mangoYellow.withValues(alpha: 0.2), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColor.mangoYellow, width: 1.5),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    suffixText: "Max ${(_availablePoints * 0.60).floor()}",
                    suffixStyle: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white24),
                  ),
                  onChanged: (val) {
                    final pts = int.tryParse(val) ?? 0;
                    final maxRedeemable = (_availablePoints * 0.60).floor();
                    if (pts > maxRedeemable) {
                      _pointsCtrl.text = maxRedeemable.toString();
                      _pointsCtrl.selection = TextSelection.fromPosition(
                        TextPosition(offset: _pointsCtrl.text.length),
                      );
                      Utils.toastMessage("You can redeem a maximum of 60% of your total points.");
                    }
                    _recalculate();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(height: 24.h),

      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                _buildSummaryRow("Bill Amount", double.tryParse(_amountCtrl.text) ?? 0, Colors.white),
                _buildSummaryRow("Points Discount", (-(int.tryParse(_pointsCtrl.text) ?? 0)).toDouble(), AppColor.mangoYellow),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 24.h),
                _buildSummaryRow("Final Amount", _rawFinalAmount, AppColor.premiumAccent),
              ],
            ),
          ),
        ),
      ),
      SizedBox(height: 24.h),

      Consumer<UserPaymentsViewModel>(
        builder: (context, vm, _) => AppButton(
          onTap: vm.isLoading ? null : _proceedToCalculation,
          text: vm.isLoading ? "Calculating..." : "Proceed",
          icon: vm.isLoading ? null : Icons.arrow_forward_rounded,
        ),
      ),
    ];
  }

  List<Widget> _buildCalculationSection(PaymentCalculation calc) {
    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.premiumAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.receipt_long_rounded, color: AppColor.premiumAccent, size: 16.sp),
                    ),
                    SizedBox(width: 10.w),
                    Text("Payment Summary",
                      style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                if (calc.isFirstVisit)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColor.premiumAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("First-time visit! ${calc.discountPercentage}% off applied",
                      style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColor.premiumAccent),
                    ),
                  )
                else if (calc.discountPercentage > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("Regular customer! ${calc.discountPercentage}% off applied",
                      style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.blueAccent),
                    ),
                  ),
                SizedBox(height: 16.h),

                _buildSummaryRow("Bill Amount", calc.billAmount, Colors.white),
                if (calc.discountPercentage > 0)
                  _buildSummaryRow("Discount (${calc.discountPercentage}%)", -calc.discountAmount, AppColor.premiumAccent),
                if (calc.pointsRedeemed > 0)
                  _buildSummaryRow("Points Redeemed", (-calc.pointsRedeemed).toDouble(), AppColor.mangoYellow),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 24.h),
                _buildSummaryRow("You Pay", calc.finalAmount, const Color(0xFF4CAF50)),

                if (calc.upiId.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Text("UPI not configured. Contact business.",
                      style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(height: 16.h),

      Text(
        "You will be redirected to your UPI app to complete the payment",
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white38),
      ),
      SizedBox(height: 8.h),

      Text(
        "Amount is pre-filled and cannot be edited in the UPI app",
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white24),
      ),
      SizedBox(height: 24.h),

      Consumer<UserPaymentsViewModel>(
        builder: (context, vm, _) => AppButton(
          onTap: (vm.isLoading || calc.upiId.isEmpty) ? null : _payViaUpi,
          text: vm.isLoading ? "Processing..." : "Pay ₹${calc.finalAmount.toStringAsFixed(0)} via UPI",
          icon: vm.isLoading ? null : Icons.payments_rounded,
        ),
      ),
    ];
  }

  Widget _buildSummaryRow(String label, double amount, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white60)),
          Text(
            amount < 0 ? "-₹${(-amount).toStringAsFixed(0)}" : "₹${amount.toStringAsFixed(0)}",
            style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
