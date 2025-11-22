import 'package:flutter/material.dart';
import 'package:creatoo/core.dart'; // For AppColor, SizeConfig

class VisitTabView extends StatelessWidget {
  const VisitTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Example list of visited restaurants
    final List<Map<String, String>> visitedRestaurants = [
      {'name': 'The Grand Bistro', 'date': '2025-10-26', 'icon': Icons.restaurant.codePoint.toString()},
      {'name': 'Pizza Palace', 'date': '2025-09-15', 'icon': Icons.local_pizza.codePoint.toString()},
      {'name': 'Sushi Express', 'date': '2025-08-01', 'icon': Icons.ramen_dining.codePoint.toString()},
      {'name': 'Cafe Delight', 'date': '2025-07-20', 'icon': Icons.local_cafe.codePoint.toString()},
      {'name': 'Burger Barn', 'date': '2025-06-05', 'icon': Icons.fastfood.codePoint.toString()},
    ];

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      itemCount: visitedRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = visitedRestaurants[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: Icon(
              IconData(int.parse(restaurant['icon']!), fontFamily: 'MaterialIcons'),
              color: AppColor.primary,
            ),
            title: Text(
              restaurant['name']!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            subtitle: Text(
              'Visited on: ${restaurant['date']!}',
              style: TextStyle(color: AppColor.darkGrey, fontSize: 12.sp),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColor.darkGrey),
            onTap: () {
              // Handle tap, e.g., navigate to restaurant details
            },
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
    );
  }
}
