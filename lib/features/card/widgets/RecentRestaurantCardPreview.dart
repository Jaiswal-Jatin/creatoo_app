import 'package:flutter/material.dart';

import '../../../core.dart';
class RecentRestaurantCard extends StatelessWidget {
  final String name;
  final DateTime dateTime;
  final String tier;
  final String? imageUrl;
  final int? businessId;
  final VoidCallback? onTap;
  
  const RecentRestaurantCard({
    Key? key,
    required this.name,
    required this.dateTime,
    required this.tier,
    this.imageUrl,
    this.businessId,
    this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime dt) {    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';    
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  Color _tierColor(String t) {
    switch (t.toLowerCase()) {
      case 'premium':
      case 'gold':
      case 'new':
        return AppColor.gold;
      case 'elite':
      case 'silver':
        return AppColor.silver;
      case 'core':
      case 'bronze':
        return AppColor.bronze;
      default:
        return AppColor.darkGrey;
    }
  }

  IconData _tierIcon(String t) {
    switch (t.toLowerCase()) {
      case 'premium':
      case 'gold':
      case 'new':
        return Icons.workspace_premium_rounded;
      case 'elite':
      case 'silver':
        return Icons.stars_rounded;
      case 'core':
      case 'bronze':
        return Icons.star_half_rounded;
      default:
        return Icons.star;
    }
  }

  Color _tierIconColor(String t) {
    switch (t.toLowerCase()) {
      case 'premium':
      case 'gold':
      case 'new':
        return const Color(0xFFD4AF37);
      case 'elite':
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'core':
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return AppColor.darkGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;
    
    // Responsive values
    double cardPadding;
    double cardMargin;
    double imageSize;
    double imageBorderRadius;
    double nameFontSize;
    double timeFontSize;
    double timeIconSize;
    double tierPaddingH;
    double tierPaddingV;
    double tierFontSize;
    double tierIconSize;
    double tierBorderRadius;
    double cardBorderRadius;
    
    if (isVerySmall) {
      cardPadding = 8;
      cardMargin = 8;
      imageSize = 40;
      imageBorderRadius = 20;
      nameFontSize = 13;
      timeFontSize = 10;
      timeIconSize = 10;
      tierPaddingH = 8;
      tierPaddingV = 5;
      tierFontSize = 10;
      tierIconSize = 12;
      tierBorderRadius = 14;
      cardBorderRadius = 10;
    } else if (isSmall) {
      cardPadding = 10;
      cardMargin = 10;
      imageSize = 46;
      imageBorderRadius = 23;
      nameFontSize = 14;
      timeFontSize = 11;
      timeIconSize = 11;
      tierPaddingH = 9;
      tierPaddingV = 5;
      tierFontSize = 11;
      tierIconSize = 13;
      tierBorderRadius = 16;
      cardBorderRadius = 11;
    } else if (isMedium) {
      cardPadding = 11;
      cardMargin = 11;
      imageSize = 50;
      imageBorderRadius = 25;
      nameFontSize = 15;
      timeFontSize = 12;
      timeIconSize = 12;
      tierPaddingH = 9;
      tierPaddingV = 5;
      tierFontSize = 12;
      tierIconSize = 14;
      tierBorderRadius = 18;
      cardBorderRadius = 11;
    } else {
      cardPadding = 12;
      cardMargin = 12;
      imageSize = 56;
      imageBorderRadius = 28;
      nameFontSize = 16;
      timeFontSize = 13;
      timeIconSize = 14;
      tierPaddingH = 10;
      tierPaddingV = 6;
      tierFontSize = 13;
      tierIconSize = 15;
      tierBorderRadius = 20;
      cardBorderRadius = 12;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        padding: EdgeInsets.all(cardPadding + 4),
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Restaurant image or initials fallback
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _tierColor(tier).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(imageBorderRadius),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        height: imageSize,
                        width: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackAvatar(imageBorderRadius, nameFontSize),
                      )
                    : _buildFallbackAvatar(imageBorderRadius, nameFontSize),
              ),
            ),

            SizedBox(width: cardPadding + 4),

            // Middle: name + date/time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: nameFontSize,
                      color: AppColor.premiumTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: cardPadding * 0.5),

                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: timeIconSize, color: AppColor.premiumTextSecondary),
                      SizedBox(width: cardPadding * 0.4),
                      Text(
                        _formatTime(dateTime),
                        style: TextStyle(
                            fontSize: timeFontSize,
                            color: AppColor.premiumTextSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: cardPadding),
                      Icon(Icons.calendar_today_rounded,
                          size: timeIconSize, color: AppColor.premiumTextSecondary),
                      SizedBox(width: cardPadding * 0.4),
                      Flexible(
                        child: Text(
                          _formatDate(dateTime),
                          style: TextStyle(
                              fontSize: timeFontSize,
                              color: AppColor.premiumTextSecondary,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right: tier chip with Premium/Elite/Core styling
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: tierPaddingH, vertical: tierPaddingV),
              decoration: _getTierDecoration(tier, tierBorderRadius),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _tierIcon(tier),
                    size: tierIconSize,
                    color: _tierIconColor(tier),
                  ),
                  SizedBox(width: cardPadding * 0.4),
                  Text(
                    _getTierDisplayName(tier),
                    style: TextStyle(
                      color: _getTierTextColor(tier),
                      fontWeight: FontWeight.w800,
                      fontSize: tierFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(double radius, double fontSize) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _tierColor(tier).withOpacity(0.15),
      child: Text(
        (name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join())
            .toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize * 0.9,
          color: AppColor.premiumTextPrimary,
        ),
      ),
    );
  }

  String _getTierDisplayName(String tier) {
    switch (tier.toLowerCase()) {
      case 'premium':
      case 'gold':
      case 'new':
        return 'Premium';
      case 'elite':
      case 'silver':
        return 'Elite';
      case 'core':
      case 'bronze':
        return 'Core';
      default:
        return tier;
    }
  }

  BoxDecoration _getTierDecoration(String tier, double borderRadius) {
    List<Color> gradientColors;
    switch (tier.toLowerCase()) {
      case 'premium':
      case 'gold':
      case 'new':
        gradientColors = AppColor.goldGradient;
        break;
      case 'elite':
      case 'silver':
        gradientColors = AppColor.silverGradient;
        break;
      case 'core':
      case 'bronze':
        gradientColors = AppColor.bronzeGradient;
        break;
      default:
        gradientColors = [AppColor.darkGrey, AppColor.darkGrey];
    }
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: gradientColors.first.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Color _getTierTextColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'premium':
      case 'gold':
      case 'new':
        return Colors.black87;
      case 'elite':
      case 'silver':
        return Colors.black87;
      case 'core':
      case 'bronze':
        return Colors.black;
      default:
        return AppColor.white;
    }
  }
}
