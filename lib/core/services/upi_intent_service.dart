import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class UpiIntentService {
  static const MethodChannel _channel = MethodChannel('com.creatoo/upi_payment');

  /// Launches the UPI app and waits for the result.
  /// Returns a Map containing 'Status' and other callback parameters.
  static Future<Map<String, String>> launchUpi(String uriString) async {
    try {
      final result = await _channel.invokeMethod('launchUpi', {'uri': uriString});
      
      if (result != null) {
        // MethodChannel maps are dynamic, cast to String map
        return Map<String, String>.from(result as Map);
      }
      return {'Status': 'APP_CLOSED_OR_NO_RESPONSE'};
    } on PlatformException catch (e) {
      debugPrint("UPI Intent Error: ${e.message}");
      return {'Status': 'FAILED', 'Error': e.message ?? 'Unknown error'};
    } catch (e) {
      debugPrint("UPI Intent Exception: $e");
      return {'Status': 'FAILED', 'Error': e.toString()};
    }
  }

  /// Parses the raw status string from the UPI app into our unified Backend status enum:
  /// SUCCESS, FAILED, PENDING, CANCELLED
  static String parseStatus(String? rawStatus) {
    if (rawStatus == null || rawStatus.isEmpty) return 'PENDING';

    final s = rawStatus.toLowerCase();

    if (s.contains('success')) {
      return 'SUCCESS';
    } else if (s.contains('fail') || s.contains('failure')) {
      return 'FAILED';
    } else if (s.contains('user_cancelled') || s.contains('cancel')) {
      return 'CANCELLED';
    } else if (s.contains('submitted') || s.contains('app_closed_or_no_response')) {
      return 'PENDING';
    }

    // Default to pending for any unknown status to trigger manual verification
    return 'PENDING';
  }
}
