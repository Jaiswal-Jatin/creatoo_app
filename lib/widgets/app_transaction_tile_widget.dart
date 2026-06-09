import 'package:creatoo/features/creator_wallet/model/transaction_details.dart';
import 'package:intl/intl.dart';

import '../core.dart';

class AppTransactionTileWidget extends StatelessWidget {
  final bool showPoints;
  final TransactionDetails item;

  const AppTransactionTileWidget({
    super.key,
    required this.item,
    this.showPoints = false,
  });

  String _formatDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate).toLocal();
    String formattedDate = DateFormat("dd-MMM-yyyy h:mm a").format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    if (item.paidTo == null && item.receivedFrom == null) {
      return SizedBox.shrink();
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        // margin: EdgeInsets.only(bottom: 8.h),
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColor.premiumAccent.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 45.h,
              width: 45.h,
              decoration: BoxDecoration(
                color: AppColor.premiumAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: roleId == Constants.businessUser
                  ? Icon(
                      Icons.arrow_downward,
                      color: AppColor.premiumAccent,
                    )
                  : Icon(
                      Icons.arrow_upward,
                      color: AppColor.premiumAccent,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (item.paidTo == null) ? 'Received from:' : 'Paid to:',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.premiumTextSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.45,
                        child: Text(
                          (item.paidTo == null)
                              ? '${item.receivedFrom}'
                              : '${item.paidTo}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.premiumTextPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        '₹${item.totalBill.toCommaSeparated()}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.premiumTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDate(item.dateTime.toString()),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColor.premiumTextSecondary,
                            ),
                          ),
                          if (item.orderId != null) ...[
                            SizedBox(height: 2.h),
                            Text(
                              'Id: ${item.orderId}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColor.premiumTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.finalBill != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${item.finalBill.toCommaSeparated()}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColor.activeGreen,
                              ),
                            ),
                            if (item.discountPercentage != null)
                              Text(
                                '${item.discountPercentage}% off',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.premiumTextSecondary,
                                ),
                              ),
                          ],
                        )
                      else if (item.discountPercentage != null)
                        Text(
                          '${item.discountPercentage}%',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.premiumTextSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
