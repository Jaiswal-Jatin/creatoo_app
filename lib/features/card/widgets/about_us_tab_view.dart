import 'package:flutter/material.dart';
import 'package:creatoo/core.dart'; // For AppColor, SizeConfig

class AboutUsTabView extends StatelessWidget {
  const AboutUsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;
    
    // Responsive values
    double horizontalPadding;
    double verticalPadding;
    double sectionSpacing;
    double subSectionSpacing;
    double titleFontSize;
    double subTitleFontSize;
    double bodyFontSize;
    double bulletPadding;
    
    if (isVerySmall) {
      horizontalPadding = 12;
      verticalPadding = 8;
      sectionSpacing = 14;
      subSectionSpacing = 8;
      titleFontSize = 14;
      subTitleFontSize = 12;
      bodyFontSize = 11;
      bulletPadding = 12;
    } else if (isSmall) {
      horizontalPadding = 14;
      verticalPadding = 9;
      sectionSpacing = 16;
      subSectionSpacing = 10;
      titleFontSize = 15;
      subTitleFontSize = 13;
      bodyFontSize = 12;
      bulletPadding = 14;
    } else if (isMedium) {
      horizontalPadding = 15;
      verticalPadding = 10;
      sectionSpacing = 18;
      subSectionSpacing = 11;
      titleFontSize = 16;
      subTitleFontSize = 14;
      bodyFontSize = 13;
      bulletPadding = 15;
    } else {
      horizontalPadding = 16;
      verticalPadding = 10;
      sectionSpacing = 20;
      subSectionSpacing = 12;
      titleFontSize = 18;
      subTitleFontSize = 16;
      bodyFontSize = 14;
      bulletPadding = 16;
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About – Creatoo Universal Loyalty Card', titleFontSize),
          _buildBodyText(
            'The Creatoo Universal Loyalty Card is your all-in-one membership card that gives you special experiences every time you visit a Creatoo partner outlet. The card focuses on rewarding your visits and frequency, creating a warm, experience-first connection between you and the places you love. The more often you visit, the better your membership level becomes. You enjoy special perks and unique experiences that each business personally decides for you.',
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          
          _buildSectionTitle('How to Activate Your Creatoo Card', titleFontSize),
          _buildNumberedList([
            'Get the Card at Any Partner Outlet\n   • When you visit a partner business, simply ask for the Creatoo Card.',
            'Open the Creatoo App\n   • Go to the "Card" section and tap "Activate Card".',
            'Scan the QR on the Card\n   • Scan the QR printed on the card using the app.',
            'Your Card is Now Active\n   • The card gets linked to your mobile number and is ready for use at all partner outlets.',
          ], bodyFontSize),
          SizedBox(height: sectionSpacing),
          
          _buildSectionTitle('How to Use the Creatoo Card', titleFontSize),
          _buildNumberedList([
            'Carry the Card When You Visit\n   • Bring the physical Creatoo Card whenever you visit any partner outlet, or simply show your digital card in the Creatoo app. Both work the same way.',
            'Ask Staff to Mark Your Visit\n   • The staff will enter your card number in their Creatoo Business App.\n   • Your visit is instantly recorded.',
            'Enjoy Rewards Based on Your Level\n   • The app updates your membership level and shows you the perks you are eligible for.',
            'Track Everything Inside the App\n   • Check your visit count, level, rewards, and history anytime.',
          ], bodyFontSize),
          SizedBox(height: sectionSpacing),
          
          _buildSectionTitle('How the Membership Levels Work (Premium, Elite, Core)', titleFontSize),
          _buildBodyText(
            'We don\'t call them "tiers" instead, you move between Premium, Elite, and Core levels based on how quickly you come back after your last visit.\n\nHere\'s the simplest way to understand it:',
            bodyFontSize,
          ),
          SizedBox(height: subSectionSpacing * 0.8),
          
          _buildSubSectionTitle('1. Premium Level (Visit Again Within 7 Days)', subTitleFontSize),
          _buildBodyText(
            'If you visit the same outlet again on or before the 7th day from your first visit, you enter the Premium level the highest level with the best perks.',
            bodyFontSize,
          ),
          SizedBox(height: subSectionSpacing),
          
          _buildSubSectionTitle('2. Elite Level (Visit After 7 Days but Before 15 Days)', subTitleFontSize),
          _buildBodyText(
            'If your next visit happens after 7 days but before 15 days, you enter the Elite level.',
            bodyFontSize,
          ),
          SizedBox(height: subSectionSpacing),
          
          _buildSubSectionTitle('3. Core Level (Visit After 15 Days)', subTitleFontSize),
          _buildBodyText(
            'If you visit after 15 days, you enter the Core level.',
            bodyFontSize,
          ),
          SizedBox(height: subSectionSpacing),
          
          _buildSubSectionTitle('4. You Can Move Back Up Anytime', subTitleFontSize),
          _buildBodyText(
            'Even if you fall to Elite or Core, the moment you start visiting more frequently again, you will upgrade back to Premium.\n\nExample:',
            bodyFontSize,
          ),
          _buildBulletList([
            'Visit on Day 1',
            'Next visit on Day 10 → Elite',
            'Next visit on Day 13 → Premium again (because it\'s within 7 days)',
          ], bodyFontSize, bulletPadding),
          SizedBox(height: subSectionSpacing * 0.8),
          _buildBodyText(
            'Simple Rule:\nThe faster you return, the better your level. The better your level, the better your benefits.',
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          
          _buildSectionTitle('Choose Offers Based on Your Level', titleFontSize),
          _buildBodyText(
            'Inside the app, whenever you visit an outlet and your level (Premium / Elite / Core) is updated, you can browse a variety of offers or perks available for your level on the business\'s profile.\n\nEach business decides its own:',
            bodyFontSize,
          ),
          _buildBulletList([
            'Perks & Offers',
            'Exclusive items',
            'Priority experiences',
            'Special services',
            'Surprise perks',
          ], bodyFontSize, bulletPadding),
          _buildBodyText(
            'You can view and redeem level-specific offerings directly from the app.',
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          
          _buildSectionTitle('Benefits of the Creatoo Card', titleFontSize),
          SizedBox(height: subSectionSpacing * 0.8),
          
          _buildSubSectionTitle('1. One Card for Many Places', subTitleFontSize),
          _buildBodyText(
            'Use a single membership card at cafés, restaurants, salons, clothing stores, gaming zones, and more. (You can browse our partners in the Creatoo mobile app).',
            bodyFontSize,
          ),
          SizedBox(height: subSectionSpacing),
          
          _buildSubSectionTitle('2. Easy Visit Tracking', subTitleFontSize),
          _buildBodyText(
            'Just hand over your card, no OTP, no confusion.',
            bodyFontSize,
          ),
          SizedBox(height: subSectionSpacing),
          
          _buildSubSectionTitle('3. Levels that Upgrade With Your Frequency', subTitleFontSize),
          _buildBodyText(
            'Premium → Elite → Core based on how often you visit. Faster visits mean better rewards.',
            bodyFontSize,
          ),
          SizedBox(height: subSectionSpacing),
          
          _buildSubSectionTitle('4. Full Transparency in the App', subTitleFontSize),
          _buildBodyText(
            'Track your visits, levels, perks, and benefits in real time.',
            bodyFontSize,
          ),
          SizedBox(height: subSectionSpacing),
          
          _buildSubSectionTitle('5. One Card for Every Partner Outlet', subTitleFontSize),
          _buildBodyText(
            'Use the same Creatoo Card across all partnered businesses, no multiple memberships, no separate cards.',
            bodyFontSize,
          ),
          SizedBox(height: subSectionSpacing),
          
          _buildBodyText(
            'Note: All benefits, offers, perks, and experience-based rewards depend entirely on each business\'s policies and may change anytime based on their terms and conditions.',
            bodyFontSize,
            isItalic: true,
          ),
          SizedBox(height: sectionSpacing),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: fontSize * 0.5),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColor.black,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title, double fontSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: fontSize * 0.4),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: AppColor.black,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text, double fontSize, {bool isItalic = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: fontSize * 0.5),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.6,
          color: AppColor.darkGrey,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildNumberedList(List<String> items, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: fontSize * 0.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: fontSize * 1.5,
                child: Text(
                  '${entry.key + 1}.',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                    height: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: fontSize,
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

  Widget _buildBulletList(List<String> items, double fontSize, double bulletPadding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: fontSize * 0.4, left: bulletPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppColor.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: fontSize,
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
