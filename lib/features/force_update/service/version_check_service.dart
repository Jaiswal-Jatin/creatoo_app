import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../../resources/app_url.dart';
import '../model/version_check_response.dart';

class VersionCheckService {
  static Future<VersionCheckResponse?> checkAppVersion() async {
    try {
      // Get current app version from pubspec.yaml
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      print('[VersionCheck] Current app version: $currentVersion');

      // Prepare request body
      final body = jsonEncode({'version': currentVersion});

      print('[VersionCheck] Calling API: ${AppUrl.versionVerify}');
      print('[VersionCheck] Request body: $body');

      // Make API call
      final response = await http.post(
        Uri.parse(AppUrl.versionVerify),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 30));

      print('[VersionCheck] Response status: ${response.statusCode}');
      print('[VersionCheck] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return VersionCheckResponse.fromJson(jsonData);
      } else {
        print('[VersionCheck] API Error: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      print('[VersionCheck] Exception: $e');
      print('[VersionCheck] StackTrace: $stackTrace');
      return null;
    }
  }
}
