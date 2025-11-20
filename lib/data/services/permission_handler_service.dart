import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  final BuildContext context;

  PermissionHandlerService(this.context);

  // Add more permissions and their descriptions as needed
  final Map<Permission, bool> permissionMap = {
    Permission.camera: false,
    Permission.photos: false,
    Permission.microphone: false,
    Permission.mediaLibrary: false,
    Permission.notification: true,
  };

  /// Requests permission based on the flag provided.
  Future<void> requestPermission(Permission permission, bool flag) async {
    if (flag) {
      final status = await permission.request();
      if (status.isGranted) {
        print('${permission.toString()} permission granted');
      } else if (status.isDenied) {
        print('${permission.toString()} permission denied');
        // Handle permission denied
        await _handleDeniedPermission(permission);
      } else if (status.isPermanentlyDenied) {
        print('${permission.toString()} permission permanently denied');
        // Handle permanently denied permission
        await _handlePermanentlyDeniedPermission(permission);
      }
    } else {
      print('${permission.toString()} permission not requested due to flag being false');
    }
  }

  /// Checks if the permission is granted.
  Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Request permissions for multiple types if needed.
  Future<void> requestMultiplePermissions() async {
    for (var entry in permissionMap.entries) {
      await requestPermission(entry.key, entry.value);
    }
  }

  /// Handle permission denied scenario
  Future<void> _handleDeniedPermission(Permission permission) async {
    // Optionally show a dialog explaining why the permission is needed
    print('Please grant ${permission.toString()} permission from settings.');
  }

  /// Handle permanently denied permission scenario
  Future<void> _handlePermanentlyDeniedPermission(Permission permission) async {
    // Show dialog to open app settings
    await _showOpenSettingsDialog(permission);
  }

  /// Show a dialog prompting the user to open app settings
  Future<void> _showOpenSettingsDialog(Permission permission) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Allows dialog to be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text('Permission Required'),
          content: Text('The ${permission.toString()} permission is required. Please grant it from the app settings.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Open Settings'),
              onPressed: () async {
                await openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
