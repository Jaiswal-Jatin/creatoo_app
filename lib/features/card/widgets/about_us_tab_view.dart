import 'package:flutter/material.dart';
import 'package:creatoo/core.dart'; // For AppColor, SizeConfig

class AboutUsTabView extends StatelessWidget {
  const AboutUsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About – Creatoo Universal Loyalty Card'),
          _buildBodyText(
            'The Creatoo Universal Loyalty Card is your all-in-one membership card that gives you special experiences every time you visit a Creatoo partner outlet. The card focuses on rewarding your visits and frequency, creating a warm, experience-first connection between you and the places you love. The more often you visit, the better your membership level becomes. You enjoy special perks and unique experiences that each business personally decides for you.',
          ),
          SizedBox(height: 20.h),
          
          _buildSectionTitle('How to Activate Your Creatoo Card'),
          _buildNumberedList([
            'Get the Card at Any Partner Outlet\n   • When you visit a partner business, simply ask for the Creatoo Card.',
            'Open the Creatoo App\n   • Go to the "Card" section and tap "Activate Card".',
            'Scan the QR on the Card\n   • Scan the QR printed on the card using the app.',
            'Your Card is Now Active\n   • The card gets linked to your mobile number and is ready for use at all partner outlets.',
          ]),
          SizedBox(height: 20.h),
          
          _buildSectionTitle('How to Use the Creatoo Card'),
          _buildNumberedList([
            'Carry the Card When You Visit\n   • Bring the physical Creatoo Card whenever you visit any partner outlet, or simply show your digital card in the Creatoo app. Both work the same way.',
            'Ask Staff to Mark Your Visit\n   • The staff will enter your card number in their Creatoo Business App.\n   • Your visit is instantly recorded.',
            'Enjoy Rewards Based on Your Level\n   • The app updates your membership level and shows you the perks you are eligible for.',
            'Track Everything Inside the App\n   • Check your visit count, level, rewards, and history anytime.',
          ]),
          SizedBox(height: 20.h),
          
          _buildSectionTitle('How the Membership Levels Work (Premium, Elite, Core)'),
          _buildBodyText(
            'We don\'t call them "tiers" instead, you move between Premium, Elite, and Core levels based on how quickly you come back after your last visit.\n\nHere\'s the simplest way to understand it:',
          ),
          SizedBox(height: 10.h),
          
          _buildSubSectionTitle('1. Premium Level (Visit Again Within 7 Days)'),
          _buildBodyText(
            'If you visit the same outlet again on or before the 7th day from your first visit, you enter the Premium level the highest level with the best perks.',
          ),
          SizedBox(height: 12.h),
          
          _buildSubSectionTitle('2. Elite Level (Visit After 7 Days but Before 15 Days)'),
          _buildBodyText(
            'If your next visit happens after 7 days but before 15 days, you enter the Elite level.',
          ),
          SizedBox(height: 12.h),
          
          _buildSubSectionTitle('3. Core Level (Visit After 15 Days)'),
          _buildBodyText(
            'If you visit after 15 days, you enter the Core level.',
          ),
          SizedBox(height: 12.h),
          
          _buildSubSectionTitle('4. You Can Move Back Up Anytime'),
          _buildBodyText(
            'Even if you fall to Elite or Core, the moment you start visiting more frequently again, you will upgrade back to Premium.\n\nExample:',
          ),
          _buildBulletList([
            'Visit on Day 1',
            'Next visit on Day 10 → Elite',
            'Next visit on Day 13 → Premium again (because it\'s within 7 days)',
          ]),
          SizedBox(height: 10.h),
          _buildBodyText(
            'Simple Rule:\nThe faster you return, the better your level. The better your level, the better your benefits.',
          ),
          SizedBox(height: 20.h),
          
          _buildSectionTitle('Choose Offers Based on Your Level'),
          _buildBodyText(
            'Inside the app, whenever you visit an outlet and your level (Premium / Elite / Core) is updated, you can browse a variety of offers or perks available for your level on the business\'s profile.\n\nEach business decides its own:',
          ),
          _buildBulletList([
            'Perks & Offers',
            'Exclusive items',
            'Priority experiences',
            'Special services',
            'Surprise perks',
          ]),
          _buildBodyText(
            'You can view and redeem level-specific offerings directly from the app.',
          ),
          SizedBox(height: 20.h),
          
          _buildSectionTitle('Benefits of the Creatoo Card'),
          SizedBox(height: 10.h),
          
          _buildSubSectionTitle('1. One Card for Many Places'),
          _buildBodyText(
            'Use a single membership card at cafés, restaurants, salons, clothing stores, gaming zones, and more. (You can browse our partners in the Creatoo mobile app).',
          ),
          SizedBox(height: 12.h),
          
          _buildSubSectionTitle('2. Easy Visit Tracking'),
          _buildBodyText(
            'Just hand over your card, no OTP, no confusion.',
          ),
          SizedBox(height: 12.h),
          
          _buildSubSectionTitle('3. Levels that Upgrade With Your Frequency'),
          _buildBodyText(
            'Premium → Elite → Core based on how often you visit. Faster visits mean better rewards.',
          ),
          SizedBox(height: 12.h),
          
          _buildSubSectionTitle('4. Full Transparency in the App'),
          _buildBodyText(
            'Track your visits, levels, perks, and benefits in real time.',
          ),
          SizedBox(height: 12.h),
          
          _buildSubSectionTitle('5. One Card for Every Partner Outlet'),
          _buildBodyText(
            'Use the same Creatoo Card across all partnered businesses, no multiple memberships, no separate cards.',
          ),
          SizedBox(height: 12.h),
          
          _buildBodyText(
            'Note: All benefits, offers, perks, and experience-based rewards depend entirely on each business\'s policies and may change anytime based on their terms and conditions.',
            isItalic: true,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.black,
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.black,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text, {bool isItalic = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.5,
          color: AppColor.darkGrey,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            '${entry.key + 1}. ${entry.value}',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: AppColor.darkGrey,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 6.h, left: 16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.darkGrey,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: AppColor.darkGrey,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
