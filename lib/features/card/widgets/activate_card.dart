import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:creatoo/core.dart';

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
            TextFormField(
              style: const TextStyle(color: AppColor.black),
              decoration: _buildInputDecoration('Name', Icons.person_outline),
            ),
            SizedBox(height: 15.h),
            TextFormField(
              style: const TextStyle(color: AppColor.black),
              decoration:
                  _buildInputDecoration('Card Code', Icons.credit_card),
            ),
            SizedBox(height: 25.h),
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
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  'Activate Card',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColor.black.withOpacity(0.7)),
      prefixIcon: Icon(
        icon,
        color: AppColor.black.withOpacity(0.7),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: AppColor.black.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColor.black),
      ),
    );
  }
}
