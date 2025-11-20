import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

extension CapitalizeFirst on String {
  String get capitalizeFirst {
    return isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DateTimeExtensions on DateTime {
  String get dateOnly {
    return DateTime(day, month, year).toString().split(" ").first;
  }
}

extension NullableDoubleFormatter on double? {
  /// Format the double value into Indian currency style with comma separators
  /// Example: 100000.0 => "1,00,000.00"
  String toCommaSeparated({int decimalDigits = 2}) {
    if (this == null) return '0.00';

    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: decimalDigits,
    );

    return format.format(this);
  }
}

extension CommaSeparatedString on String? {
  /// Converts a numeric string into Indian-style comma-separated format
  /// Example: "100000.50" => "1,00,000.50"
  String toCommaSeparated({int decimalDigits = 2}) {
    if (this == null || this!.isEmpty) return '0.00';

    try {
      final number = double.parse(this!);
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '',
        decimalDigits: decimalDigits,
      );
      return formatter.format(number);
    } catch (e) {
      return this!;
    }
  }
}

class CommaTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('en_IN');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digit characters except .
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double? value = double.tryParse(newText);
    if (value == null) return oldValue;

    String formatted = _formatter.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
