import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core.dart';

enum Result { success, general, error }

class Utils {
  static double averageRating(List<int> rating) {
    var avgRating = 0;
    for (int i = 0; i < rating.length; i++) {
      avgRating = avgRating + rating[i];
    }
    return double.parse((avgRating / rating.length).toStringAsFixed(1));
  }

  static void fieldFocusChange(FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(navigatorKey.currentContext!).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColor.white,
      textColor: AppColor.primary,
    );
  }

  static void flushBar(String message,
      {Result result = Result.error, int duration = 2}) {
    showFlushbar(
      context: navigatorKey.currentContext!,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        message: message,
        duration: Duration(seconds: duration),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: getColor(result),
        reverseAnimationCurve: Curves.easeInOut,
        positionOffset: 20,
        icon: const Icon(
          Icons.error,
          size: 28,
          color: Colors.white,
        ),
      )..show(navigatorKey.currentContext!),
    );
  }

  static snackBar(String message,
      {Result result = Result.general, int duration = 3}) {
    return ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        backgroundColor: getColor(result),
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

  static String formatCurrency(num amount,
      {String locale = 'en_IN', String symbol = "₹ "}) {
    final format = NumberFormat.currency(locale: locale, symbol: symbol);
    return format.format(amount);
  }

  static Color getColor(Result result) {
    if (result == Result.general) {
      return AppColor.general;
    }
    if (result == Result.error) {
      return AppColor.error;
    }
    if (result == Result.success) {
      return AppColor.green;
    }
    return AppColor.primary;
  }

  static Color getTransactionColor(String creditDebit) {
    if (creditDebit.toLowerCase().contains(Amount.credit.name)) {
      return AppColor.green;
    } else {
      return AppColor.darkRed;
    }
  }

  static double getValueBasedOnIndex(int index, int listLength,
      {double padding = 8.0}) {
    if (listLength == 2 && index == 1) {
      return padding.h;
    }
    if (index == listLength - 1) {
      return 0.0;
    } else {
      return padding.h;
    }
  }

  static String abbreviateNumber(int number) {
    if (number.abs() >= 1000000000000000) {
      return '${(number / 1000000000000000).toStringAsFixed(1)} Q'; // Quadrillions
    } else if (number.abs() >= 1000000000000) {
      return '${(number / 1000000000000).toStringAsFixed(1)} T'; // Trillions
    } else if (number.abs() >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)} B'; // Billions
    } else if (number.abs() >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)} M'; // Millions
    } else if (number.abs() >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)} K'; // Thousands
    } else {
      return number.toString(); // For numbers less than 1000
    }
  }

  static convertBase64Image(String? path, {bool fromAssets = true}) async {
    if (path == null) return null;
    if (fromAssets) {
      // Load the image as ByteData from assets
      ByteData imageBytes = await rootBundle.load(path);
      // Convert ByteData to Uint8List
      Uint8List bytes = imageBytes.buffer.asUint8List();
      // Convert bytes to Base64 string
      String _base64Image = base64Encode(bytes);
      return _base64Image;
    } else {
      File _image = File(path);
      var _imageBytes = await _image.readAsBytes();
      var _base64Image = base64Encode(_imageBytes);
      return _base64Image;
    }
  }

  static Future<void> clearLocalData()async {
    SharedPreferencesService _prefs = SharedPreferencesService();
    await _prefs.deleteAll().then(
          (value) {
        Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!,
            RoutesName.startupView, (route) => false);
        return Left(SessionExpiry());
      },
    );
  }
}
