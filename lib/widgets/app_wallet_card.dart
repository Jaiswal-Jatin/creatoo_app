import '../core.dart';

class AppWalletCard extends StatelessWidget {
  final bool showPoints;
  final bool showInfo;
  final double value;
  const AppWalletCard({
    super.key,
    this.showPoints = false,
    required this.value,
    this.showInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      margin: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Text(
            'Wallet',
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Your ${(roleId == Constants.businessUser) ? "Earnings" : "Points"}",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColor.white,
            ),
          ),
          Text(
            showPoints ? "${value.toDouble().toCommaSeparated()} Points" : '\u20B9${value.toDouble().toCommaSeparated()}',
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.white,
            ),
          ),
        ],
      ),
    );
  }
}
