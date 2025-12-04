import 'package:flutter/services.dart';

import '../core.dart';
import '../features/register_creator/model/user_insta_response.dart';

class AppDialog {
  static Future<bool?> showConfirmationDialog({
    String title = "Confirm Action",
    String content = "Are you sure you want to perform this action?",
    String cancel = "Cancel",
    String confirm = "Confirm",
  }) async {
    return await showDialog<bool>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Container(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.appBarTitleTextStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(confirm),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static void showAmountDialog(
      {required TextEditingController controller, String? Function(dynamic)? validator, required VoidCallback onConfirm}) {
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: SizeConfig.screenWidth,
            // height: 220.h,
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  'Withdraw Amount',
                  textAlign: TextAlign.left,
                  style: AppTextStyles.appBarTitleTextStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                Form(
                  key: _formKey,
                  child: AppTextField(
                    controller: controller,
                    validator: validator,
                    disableBorder: false,
                    hintText: "Enter amount",
                    maxLines: 1,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                    textInputType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        child: Text('Cancel'),
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size.fromHeight(50.h)),
                          backgroundColor: WidgetStateProperty.all(AppColor.lightGrey),
                          foregroundColor: WidgetStateProperty.all(AppColor.black),
                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w)),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          elevation: WidgetStateProperty.all(2),
                          textStyle: WidgetStateProperty.all(
                            TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ElevatedButton(
                        child: Text('Confirm'),
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size.fromHeight(50.h)),
                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w)),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          elevation: WidgetStateProperty.all(2),
                          textStyle: WidgetStateProperty.all(
                            TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: () {
                          final formState = _formKey.currentState;
                          if (formState != null && formState.validate()) {
                            final amount = controller.text;
                            print('Amount entered: $amount');
                            onConfirm();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showFullScreenDialog(Item item) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: true,
      // Allows the user to dismiss the dialog by tapping outside of it
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: SizeConfig.screenHeight * 0.4,
            width: SizeConfig.screenWidth * 0.8,
            child: Stack(
              children: [
                Positioned.fill(
                  // top: 25,
                  // right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50.h,
                          backgroundColor: AppColor.transparent,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: item.image != null
                                ? AppImageWidget(
                                    height: 100.h,
                                    width: 100.h,
                                    imageUrl: item.image!,
                                  )
                                : Image.asset(
                                    Images.appLogo,
                                    height: 100.h,
                                    width: 100.h,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Divider(),
                        Container(
                          height: SizeConfig.screenWidth / 2.3,
                          width: SizeConfig.screenWidth,
                          // color: AppColor.primary,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // width: 120.w,
                                child: Text(
                                  '${item.name}',
                                  maxLines: 2,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  // overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    // color: Color(0xFF666666),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              if (item.address != null)
                                Container(
                                  // width: 120.w,
                                  child: Text(
                                    '${item.address}',
                                    maxLines: 2,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    // overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w300,
                                      // color: Color(0xFF666666),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 30),
                              if (item.isActive != null)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: item.isActive! ? AppColor.green : AppColor.lightGrey,
                                  ),
                                  child: Text(
                                    item.isActive! ? 'Active' : "In-Active",
                                    style: TextStyle(
                                      color: AppColor.white,
                                    ),
                                  ),
                                ),
                              if (item.id != null && roleId == 3)
                                Padding(
                                  padding: const EdgeInsets.only(right: 30.0, left: 30),
                                  child: AppButton(
                                      isIconEnabled: false,
                                      text: "Tap to know more",
                                      onTap: () {
                                        Navigator.pushNamed(context, RoutesName.businessDescriptionView, arguments: item.id);
                                      }),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 40.h,
                      width: 40.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.darkRed,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColor.white,
                        size: 25.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<bool?> showInstagramConfirmationDialog(
      {String title = "Confirm Account",
      String cancel = "Cancel",
      String confirm = "Confirm",
      required UserInsta user,
      required void Function()? onPressed}) async {
    return await showDialog<bool>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              title,
              style: AppTextStyles.appBarTitleTextStyle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(user.profilePicUrl!),
              ),
              title: Text(
                user.fullName!,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                user.username!,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text(
                    'Cancel',
                    // style: TextStyle(color: AppColor.orange),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                SizedBox(
                  height: 15,
                  child: VerticalDivider(),
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: onPressed,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static showImageTextDialog({required Function(String username, String path) onPressed}) {
    showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) => ImageTextDialog(),
    ).then((result) {
      if (result != null) {
        // Handle the submitted result (text and image)
        print('Submitted text: ${result['text']}');
        print('Submitted image: ${result['image']}');
        onPressed(result['text'], result['image']);
      }
    });
  }

  static Future<bool?> showBusinessInfoIncompleteDialog(
      {String title = "Complete Your Registration!",
      String content = "You haven't finished setting up your business. Complete the process to start attracting customers!",
      String mandatoryFields = "",
      String buttonLabel = "Proceed To Finish",
      VoidCallback? onClicked}) async {
    return await showDialog<bool>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Container(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.appBarTitleTextStyle.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                content,
                textAlign: TextAlign.center,
                style: AppTextStyles.appBarTitleTextStyle.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w200,
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Text(
                "Mandatory Fields: $mandatoryFields",
                textAlign: TextAlign.center,
                style: AppTextStyles.appBarTitleTextStyle.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Material(
              child: Container(
                margin: EdgeInsets.all(12),
                child: AppButton(
                  text: buttonLabel,
                  onTap: onClicked,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  static Future<bool?> showPricingDialog({
    String title = "Pricing",
    String content =
        "Unlock exclusive discounts at your favorite restaurants, cafes, and businesses for as low as 200. No hidden fees-just great savings on every purchase! Terms and conditions apply. Prices may vary by business.",
    String confirm = "Ok",
  }) async {
    return await showDialog<bool>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Container(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.appBarTitleTextStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(
            content,
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text(confirm),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showSubscriptionRequiredDialog() async {
    return showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColor.kPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_membership,
                  size: 40.sp,
                  color: AppColor.kPrimary,
                ),
              ),
              SizedBox(height: 20.h),
              
              // Title
              Text(
                'Subscription Required',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 12.h),
              
              // Content
              Text(
                'You need an active subscription to access this feature. Please purchase a subscription to continue.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.darkGrey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 24.h),
              
              // Button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Buy fromBusiness Admin Dashboard',
                  isIconEnabled: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to subscription purchase screen
                    // Navigator.pushNamed(context, RoutesName.subscriptionView);
                  },
                  buttonColor: AppColor.kPrimary,
                  textColor: AppColor.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Item {
  int? id;
  String? name;
  String? image;
  String? address;
  String? role;
  bool? isActive;

  Item({this.id, this.name, this.image, this.address, this.role, this.isActive});
}
