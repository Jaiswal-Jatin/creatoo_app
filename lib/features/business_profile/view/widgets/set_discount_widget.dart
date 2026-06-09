import 'dart:ui';
import '../../../../core.dart';
import '../../view_model/edit_business_profile_view_model.dart';

Widget setDiscountWidget(BuildContext context) {
  EditBusinessProfileViewModel viewModel = Provider.of<EditBusinessProfileViewModel>(context);

  return ClipRRect(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.premiumAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.local_offer_rounded, color: AppColor.premiumAccent, size: 16.sp),
                ),
                SizedBox(width: 10.w),
                Text("Set Discounts", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ],
            ),
            SizedBox(height: 14.h),
            Divider(color: Colors.white.withValues(alpha: 0.06)),
            SizedBox(height: 16.h),
            Text("First Time Discount", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
            SizedBox(height: 8.h),
            TextField(
              controller: viewModel.setFirstTimeDiscountController,
              keyboardType: TextInputType.number,
              readOnly: !viewModel.isEditing,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: "e.g. 20",
                suffixText: "% OFF",
                suffixStyle: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontSize: 13.sp, fontWeight: FontWeight.w600),
                hintStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 14.sp),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.03),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColor.premiumAccent, width: 1.5)),
              ),
            ),
            SizedBox(height: 20.h),
            Text("Regular Discount", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
            SizedBox(height: 8.h),
            TextField(
              controller: viewModel.setRegularDiscountController,
              keyboardType: TextInputType.number,
              readOnly: !viewModel.isEditing,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: "e.g. 10",
                suffixText: "% OFF",
                suffixStyle: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontSize: 13.sp, fontWeight: FontWeight.w600),
                hintStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 14.sp),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.03),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColor.premiumAccent, width: 1.5)),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text("First Time Discount should be higher than Regular Discount", style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white38)),
            ),
          ],
        ),
      ),
    ),
  );
}
