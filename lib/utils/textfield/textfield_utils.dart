import 'package:flutter/services.dart';

class TextFieldUtils {
  static TextInputFormatter onlyTextWithSpaces = FilteringTextInputFormatter.allow(
    RegExp(r'^[a-zA-Z ]*$'),
  );

  static TextInputFormatter onlyTextAndNumberWithSpaces = FilteringTextInputFormatter.allow(
    RegExp(r'^[a-zA-Z0-9 ]*$'),
  );

  static TextInputFormatter onlyDigitsWithSpaces = FilteringTextInputFormatter.allow(
    RegExp(r'^\d* ?$'),
  );

  static TextInputFormatter ifscCodeFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^[A-Z0-9 ]*$'),
  );

  static TextInputFormatter upiIdFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^[a-zA-Z0-9._-]*@?[a-zA-Z]*$'),
  );

  static getTextInputFormatter() {}
}
