import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange}) : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text == '.') {
      return TextEditingValue(
        text: '0.',
        selection: newValue.selection.copyWith(
          baseOffset: 2,
          extentOffset: 2,
        ),
      );
    }

    if (text.contains('.') && text.substring(text.indexOf('.') + 1).length > decimalRange) {
      return oldValue;
    }

    return newValue;
  }
}
