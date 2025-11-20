import 'package:intl/intl.dart';

class DateTimeHelper {
  static DateTime dateParser(String dateTime) {
    DateTime? parsedDate;

    // List of potential date formats to try
    List<String> formats = [
      "yyyy-MM-ddTHH:mm:ssZ", // ISO 8601 with timezone
      "yyyy-MM-ddTHH:mm:ss",  // ISO 8601 without timezone
      "yyyy-MM-dd",           // Basic date format
      "dd/MM/yyyy",           // European format
      "MM/dd/yyyy",           // US format
      "d MMMM yyyy",          // Full month name
      "d MMM yyyy",           // Abbreviated month name
      "yyyy/MM/dd",           // Alternative separator
      "dd-MM-yyyy",           // Alternative separator
      "MM-dd-yyyy",           // Alternative separator
      "MMM d, yyyy",          // Short format with abbreviated month
      "MMM d yyyy",           // Short format with abbreviated month and no comma
      "yyyy.MM.dd",           // Dot separator format
      "dd.MM.yyyy",           // Dot separator format
      "MM.dd.yyyy",           // Dot separator format
      "dd-MMM-yyyy",          // Abbreviated month name with dash
      "MM-MMM-yyyy",          // Abbreviated month name with dash
      "yyyyMMdd",             // Compact format without separators
      "yyyyMMddHHmmss",       // Compact format with time
    ];

    for (String format in formats) {
      try {
        // Try parsing the date string with each format
        DateFormat dateFormat = DateFormat(format);
        parsedDate = dateFormat.parseStrict(dateTime);
        break; // Exit loop if parsing is successful
      } catch (e) {
        // Continue to next format if parsing fails
      }
    }

    // If parsing fails, use the current date as a fallback
    if (parsedDate == null) {
      parsedDate = DateTime.now();
    }
    return parsedDate;
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss').format(dateTime);
  }

  static String formatDateToString(String dateTime) {
    return DateFormat('dd MMM yyyy').format(dateParser(dateTime));
  }
  static DateTime getFixedDate() {
    return DateTime(2025, 1, 10);
  }

  static String getFormattedFixedDate() {
    DateTime fixedDate = getFixedDate();
    return DateFormat('dd MMM yyyy').format(fixedDate);
  }


  static String estimatedDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }


  static DateTime convertStringToDatetime(String dateTime) {
    return DateFormat("yyyy-MM-dd hh:mm:ss").parse(dateTime);
  }

  static String dateStringMonthYear(DateTime? dateTime) {
    return DateFormat('d MMM,y').format(dateTime!);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime).toLocal();
  }

  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime.toLocal());
  }

  static String supportTicketDateFormat(DateTime dateTime) {
    return DateFormat('h:mm a dd MMM,yyyy').format(dateTime.toLocal());
  }

  static String localDateToIsoStringAMPMOrder(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, h:mm a ').format(dateTime.toLocal());
  }

  static String isoStringToLocalTimeOnly(String dateTime) {
    return DateFormat('HH:mm').format(DateTime.parse(dateTime));
  }

  String formatCurrentTime() {
    final DateTime now = DateTime.now().toUtc();
    final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'");
    return formatter.format(now);
  }

  static String isoStringToLocalDateOnly(String dateTime) {
    return DateFormat('dd:MM:yy').format(isoStringToLocalDate(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toLocal());
  }

  static String isoStringToLocalDateAndTime(String dateTime) {
    return DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.parse(dateTime));
  }

  static String dateFormatForWalletBonus(String dateTime) {
    return DateFormat('dd MMM, yyyy').format(isoStringToLocalDate(dateTime));
  }

  static String dateTimeStringToDateTime(String dateTime) {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateTime));
  }

  static String dateTimeStringToDateAndTime(String dateTime) {
    return DateFormat('hh:mm a, dd MMM yyyy')
        .format(DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dateTime));
  }

  static String refundDateTime(String dateTime) {
    return DateFormat('dd MMM yyyy')
        .format(DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dateTime));
  }

  static String estimatedDateYear(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  static String inboxLocalDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat('${_timeFormatter()} | dd-MMM-yyyy ')
        .format(dateTime.toLocal());
  }

  static String _timeFormatter() {
    return 'hh:mm a';
    // return Get.find<SplashController>().configModel.timeformat == '24' ? 'HH:mm' : 'hh:mm a';
  }
  static bool isDateEqualToFixedDate(DateTime dateTime) {
    DateTime fixedDate = getFixedDate();
    return dateTime.year == fixedDate.year &&
        dateTime.month == fixedDate.month &&
        dateTime.day == fixedDate.day;
  }
  static String daysUntilFixedDate(DateTime fromDate) {
    DateTime fixedDate = getFixedDate();
    int daysDifference = fixedDate.difference(fromDate).inDays;
    if (daysDifference > 0) {
      return '$daysDifference days until 10 Jan 2025';
    } else if (daysDifference == 0) {
      return 'Today is 10 Jan 2025';
    } else {
      return '${daysDifference.abs()} days since 10 Jan 2025';
    }
  }

  static String getDayNameForFixedDate() {
    DateTime fixedDate = getFixedDate();
    return DateFormat('EEEE').format(fixedDate); // e.g., "Friday"
  }

  static String customTime(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(const Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();

    if (!localDateTime.difference(justNow).isNegative) {
      return 'just now';
    }

    String roughTimeString = DateFormat('jm').format(dateTime);

    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }

    DateTime yesterday = now.subtract(const Duration(days: 1));

    if (localDateTime.day == yesterday.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'yesterday';
    }

    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(dateTime.toLocal());

      return weekday;
    }

    return localDateToIsoStringAMPM(dateTime);
  }

  static String timeAgo(String inputDate) {
    DateTime currentDate = DateTime.now();
    DateTime parsedDate = DateTime.parse(inputDate);

    Duration difference = currentDate.difference(parsedDate);
    int hoursDifference = difference.inHours;
    int minutesDifference = difference.inMinutes;
    int daysDifference = difference.inDays;

    if (daysDifference > 7) {
      // Show the date in a readable format if it's more than a week ago
      return DateFormat('MM/dd/yyyy').format(parsedDate);
    } else if (daysDifference >= 2) {
      return '$daysDifference days ago';
    } else if (daysDifference == 1) {
      return 'Yesterday';
    } else if (hoursDifference >= 1) {
      return '$hoursDifference${hoursDifference == 1 ? ' hour' : ' hours'} ago';
    } else if (minutesDifference >= 1) {
      return '$minutesDifference${minutesDifference == 1 ? ' minute' : ' minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
