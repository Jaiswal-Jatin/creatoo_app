import 'package:flutter/material.dart';
import 'package:creatoo/core.dart'; // For AppColor, SizeConfig

class ActivateCardModal extends StatelessWidget {
  const ActivateCardModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.w,
        right: 16.w,
        top: 20.h,
      ),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'Activate Your Card',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.black,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 15.h),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Card Code',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement card activation logic
                Navigator.pop(context); // Close modal
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.h),
                elevation: 5,
                shadowColor: AppColor.primary.withOpacity(0.5),
              ),
              child: Text(
                'Activate Card',
                style: TextStyle(fontSize: 16.sp, color: AppColor.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: TextButton(
              onPressed: () {
                // TODO: Implement secondary action
              },
              child: Text(
                'Learn more about cards',
                style: TextStyle(color: AppColor.darkGrey, fontSize: 12.sp),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
