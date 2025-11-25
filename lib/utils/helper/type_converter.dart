/// Helper function to safely convert dynamic values to int
/// Handles bool, int, String, and null values
int? toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}
