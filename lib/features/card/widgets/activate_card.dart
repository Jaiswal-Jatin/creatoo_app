import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/app_button.dart';
import 'package:creatoo/widgets/app_textfield.dart';

class ActivateCardModal extends StatelessWidget {
  const ActivateCardModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.lightButtonGrey,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: AppColor.black,
                ),
              ),
            ),
            Text(
              'Activate Your Card',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 25.h),
            AppTextField(
              hintText: 'Name',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 15, right: 10),
                child: Icon(Icons.person_outline, color: AppColor.black.withOpacity(0.7)),
              ),
              disableBorder: false,
              borderColor: AppColor.black.withOpacity(0.5),
              textColor: AppColor.black,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 15.h),
            AppTextField(
              hintText: 'Card Code',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 15, right: 10),
                child: Icon(Icons.credit_card, color: AppColor.black.withOpacity(0.7)),
              ),
              disableBorder: false,
              borderColor: AppColor.black.withOpacity(0.5),
              textColor: AppColor.black,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
              textInputType: TextInputType.number,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 25.h),
            AppButton(
              text: 'Activate Card',
              onTap: () {
                // TODO: Implement card activation logic
                Navigator.pop(context); // Close modal
              },
              buttonColor: AppColor.primary,
              height: 50,
              isIconEnabled: false,
            ),
          ],
        ),
      ),
    );
  }

}
