// Data model for a single visit
class Visit {
  final String restaurantName;
  final DateTime date;
  final String tier;
  final String imageUrl;

  Visit({
    required this.restaurantName,
    required this.date,
    required this.tier,
    required this.imageUrl,
  });
}
