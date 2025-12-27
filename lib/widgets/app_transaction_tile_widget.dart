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
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          height: 50.h,
          width: 50.h,
          decoration: BoxDecoration(
            color: AppColor.lightGrey,
            shape: BoxShape.circle,
          ),
          child: roleId == Constants.businessUser
              ? Icon(
                  Icons.arrow_downward,
                  color: AppColor.green,
                )
              : Icon(
                  Icons.arrow_upward,
                  color: AppColor.darkRed,
                ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (item.paidTo == null) ? 'Received from:' : 'Paid to:',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  child: Text(
                    (item.paidTo == null) ? '${item.receivedFrom}' : '${item.paidTo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '₹${item.totalBill.toCommaSeparated()}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Container(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_formatDate(item.dateTime.toString())}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.darkGrey,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  if (item.orderId != null)
                    Text(
                      'Order ID: ${item.orderId}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColor.darkGrey,
                      ),
                    ),
                ],
              ),
              if (roleId == Constants.creatorUser && item.finalBill != null)
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    '₹${item.finalBill.toCommaSeparated()}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.darkGrey,
                    ),
                  ),
                )
              else if (item.discountPercentage != null)
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    '${item.discountPercentage}%',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.darkGrey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }
}
