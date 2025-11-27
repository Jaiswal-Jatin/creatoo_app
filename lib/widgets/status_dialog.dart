import 'package:flutter/material.dart';
import 'package:creatoo/core.dart'; // Assuming core.dart exports necessary utilities like AppColor, etc.

enum DialogStatus { success, error }

class StatusDialog extends StatelessWidget {
  final DialogStatus status;
  final String message;
  final String? title;

  const StatusDialog({
    Key? key,
    required this.status,
    required this.message,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _contentBox(context),
    );
  }

  Widget _contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 20, top: 45 + 20, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: AppColor.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title ?? (status == DialogStatus.success ? "Success" : "Error"),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: status == DialogStatus.success ? AppColor.green : AppColor.darkRed,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                message,
                style: TextStyle(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Okay",
                    style: TextStyle(fontSize: 18.sp, color: AppColor.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: status == DialogStatus.success ? AppColor.referralCard : AppColor.darkRed,
            radius: 45,
            child: status == DialogStatus.success
                ? Icon(
                    Icons.check,
                    color: AppColor.white,
                    size: 50.h,
                  )
                : Icon(
                    Icons.close,
                    color: AppColor.white,
                    size: 50.h,
                  ),
          ),
        ),
      ],
    );
  }
}

// Helper function to show the dialog
void showStatusDialog(BuildContext context, DialogStatus status, String message, {String? title}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatusDialog(
        status: status,
        message: message,
        title: title,
      );
    },
  );
}
