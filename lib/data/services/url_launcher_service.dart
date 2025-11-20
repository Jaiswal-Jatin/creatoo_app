import '../../core.dart';

class UrlLauncherService {
  /// Launches the given [url] in the default browser.
  /// Returns `true` if the URL was successfully launched, otherwise returns `false`.
  Future<bool> launchAppUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri);
        return true;
      } catch (e) {
        debugPrint('Could not launch $url: $e');
        return false;
      }
    } else {
      debugPrint('Could not launch $url: URL cannot be launched');
      return false;
    }
  }

  /// Launches the given [url] in the default browser as a web URL.
  /// Returns `true` if the URL was successfully launched, otherwise returns `false`.
  Future<bool> launchWebUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } catch (e) {
        debugPrint('Could not launch $url: $e');
        return false;
      }
    } else {
      debugPrint('Could not launch $url: URL cannot be launched');
      return false;
    }
  }

  /// Launches the given [url] as a telephone link.
  /// Returns `true` if the URL was successfully launched, otherwise returns `false`.
  Future<bool> launchTel(String url) async {
    final uri = Uri.parse('tel:$url');
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri);
        return true;
      } catch (e) {
        debugPrint('Could not launch $url: $e');
        return false;
      }
    } else {
      debugPrint('Could not launch $url: URL cannot be launched');
      return false;
    }
  }

  /// Launches the given [url] as an email link.
  /// Returns `true` if the URL was successfully launched, otherwise returns `false`.
  Future<bool> launchEmail(String url) async {
    final uri = Uri.parse('mailto:$url');
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri);
        return true;
      } catch (e) {
        debugPrint('Could not launch $url: $e');
        return false;
      }
    } else {
      debugPrint('Could not launch $url: URL cannot be launched');
      return false;
    }
  }
}
