import 'package:flutter/material.dart';

import '../../../core.dart';
class RecentRestaurantCard extends StatelessWidget {
  final String name;
  final DateTime dateTime;
  final String tier;
  final String? imageUrl;
  
  const RecentRestaurantCard({
    Key? key,
    required this.name,
    required this.dateTime,
    required this.tier,
    this.imageUrl,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Left: Restaurant image or initials fallback
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? AppImageWidget(
                        imageUrl: imageUrl!,
                        height: 56,
                        width: 56,
                        iconSize: 56,
                      )
                    : CircleAvatar(
                        radius: 28,
                        backgroundColor: _tierColor(tier).withOpacity(0.15),
                        child: Text(
                          (name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join()).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
      
              const SizedBox(width: 12),
      
              // Middle: name + date/time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
      
                    const SizedBox(height: 6),
      
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14),
                        const SizedBox(width: 6),
                        Text(_formatTime(dateTime), style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 6),
                        Text(_formatDate(dateTime), style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
      
              // Right: tier chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: _getTierDecoration(tier),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: _getTierTextColor(tier),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tier,
                      style: TextStyle(
                          color: _getTierTextColor(tier),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _getTierDecoration(String tier) {
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
      borderRadius: BorderRadius.circular(20),
    );
  }

  Color _getTierTextColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'premium':
      case 'gold':
      case 'new':
        return AppColor.black;
      default:
        return AppColor.white;
    }
  }
}
