import 'package:creatoo/core.dart';

class AppDecorations {
  static BoxDecoration roundedContainerDecoration = BoxDecoration(
    color: AppColor.primary,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    // boxShadow: [
    //   BoxShadow(
    //     color: Colors.grey.withOpacity(0.5),
    //     spreadRadius: 2,
    //     blurRadius: 7,
    //     offset: Offset(0, 3),
    //   ),
    // ],
  );

  // Primary button decoration
  static BoxDecoration primaryButtonDecoration = BoxDecoration(
    color: AppColor.primary,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 7,
        offset: Offset(0, 3),
      ),
    ],
  );

  // Secondary button decoration
  static BoxDecoration secondaryButtonDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    border: Border.all(color: AppColor.primary, width: 1),
  );

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 7,
        offset: Offset(0, 3),
      ),
    ],
  );

  // Error text field decoration
  static InputDecoration errorTextFieldDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.black54, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
    fillColor: Colors.white,
    filled: true,
    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    errorMaxLines: 2,
  );
}
