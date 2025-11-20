import 'package:creatoo/core.dart';

class Validator {
  String message = "";

  static bool validateMobile(String value) {
    String pattern = r'([6789][0-9]{9})';
    RegExp regExp = RegExp(pattern);

    return regExp.hasMatch(value);
  }

  static bool validatePassword(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  static bool validateEmail(String email) {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  static bool validateWebsiteUrl(String url) {
    String pattern = r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9\-]+\.)?[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}(\/[^\s]*)?$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(url);
  }

  static bool validateUPI(String upi) {
    String pattern = r'^[\w.-]+@[\w.-]+$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(upi);
  }

  static String? validate(String value, String fieldName) {
    if (fieldName.toLowerCase().contains("gst")) {
      if (value.isEmpty) {
        return null;
      }
    }

    if (fieldName.toLowerCase().contains("mail") && Constants.businessUser == roleId) {
      if (value.isEmpty) {
        return null;
      }
    }

    if (fieldName.toLowerCase().contains("url")) {
      if (value.isEmpty) {
        return null;
      }
    }
    if (fieldName.toLowerCase().contains("mail")) {
      if (!validateEmail(value)) {
        return "Enter a valid $fieldName.";
      }
    }

    if (fieldName.toLowerCase().contains("url")) {
      if (!validateWebsiteUrl(value)) {
        return "Enter a valid $fieldName.";
      }
    }

    if (fieldName.toLowerCase().contains("gst")) {
      if (value.length < 15 || value.length > 15) {
        return 'GSTIN number must be 15 digits';
      } else if (!validateStringNumber(value)) {
        return 'Enter a valid GST number';
      }
    }

    if (fieldName.toLowerCase().contains("mobile")) {
      if (value.isEmpty) {
        return 'Enter mobile number';
      } else if (!Validator.validateMobile(value)) {
        return 'Enter a valid mobile number';
      } else if (value.length < 10) {
        return 'Mobile number must be 10 digits';
      }
    }

    if (fieldName.toLowerCase().contains("number")) {
      if (value.isEmpty) {
        return 'Enter $fieldName';
      } else if (!Validator.validateMobile(value) && !fieldName.toLowerCase().contains("account")) {
        return 'Enter a valid $fieldName';
      }
    }

    if (fieldName.toLowerCase().contains("upi")) {
      if (!Validator.validateUPI(value)) {
        return 'Enter valid $fieldName';
      }
    }

    if (fieldName.toLowerCase().contains("amount")) {
      if (value.isEmpty) {
        return 'Enter amount';
      } else if (!Validator.validateAmount(value)) {
        return 'Enter a valid amount';
      } else if (double.parse(value).round() == 0) {
        return 'Amount cannot be 0';
      } else if (double.parse(value).round() <= 1) {
        return 'Amount cannot be less than 1';
      }
    }

    if (fieldName.toLowerCase().contains("day")) {
      if (value.isEmpty) {
        return 'Enter days';
      } else if (!Validator.validateNumber(value)) {
        return 'Enter a valid days';
      } else if (double.parse(value).round() == 0) {
        return 'Days cannot be 0';
      }
    }
    if (fieldName.toLowerCase().contains("min")) {
      if (!Validator.validateNumber(value)) {
        return 'Enter a valid min order value';
      }
    }
    if (fieldName.toLowerCase().contains("expiry")) {
      if (value.trim().isEmpty) {
        return 'Please Select Expiry Days';
      }
    }

    if (fieldName.toLowerCase().contains("time")) {
      if (value.trim().isEmpty) {
        return 'Time is required';
      }
    }

    if (value.trim().isEmpty) {
      return "$fieldName field is required";
    }
    return null;
  }

  static bool validateStringNumber(value) {
    String pattern = r'(^[a-zA-Z0-9]+$)';
    RegExp regExp = RegExp(pattern);

    return regExp.hasMatch(value);
  }

  static bool validateAmount(value) {
    String pattern = r'^\d+(\.\d{0,2})?$';
    RegExp regExp = RegExp(pattern);

    return regExp.hasMatch(value);
  }

  static bool validateNumber(value) {
    String pattern = r'^\d+$';
    RegExp regExp = RegExp(pattern);

    return regExp.hasMatch(value);
  }

  static bool validateDate(String value) {
    // Regular expression pattern to match dd/mm/yyyy format
    String pattern = r'^([0][1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}$';
    RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      return false;
    }

    // Extract day, month, and year from the string
    List<String> parts = value.split('/');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    // Check for valid day based on the month
    if (day < 1 || day > 31) {
      return false;
    }

    if (month == 2) {
      // February
      bool leapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (day > (leapYear ? 29 : 28)) {
        return false;
      }
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
      // April, June, September, November
      if (day > 30) {
        return false;
      }
    } else if (month > 12 || month < 1) {
      // Invalid month
      return false;
    }

    return true;
  }

  static String? validateInstagramUsername(String? username) {
    // Check for null or empty
    if (username == null || username.isEmpty) {
      return "Username cannot be empty.";
    }

    // Check length
    if (username.length < 1 || username.length > 30) {
      return "Username must be within 30 characters.";
    }

    // Regular expression to match valid username criteria
    final RegExp usernameRegExp = RegExp(r'^(?!\.)[A-Za-z0-9._]+(?!\.\.)[A-Za-z0-9._]+(?<!\.)$');

    // Validate against the regex
    if (!usernameRegExp.hasMatch(username)) {
      return "Enter valid username";
    }

    return null; // Valid username
  }
}
