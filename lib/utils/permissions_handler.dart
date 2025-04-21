import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class PermissionsHandler {
  static Future<bool> checkStoragePermissions() async {
    if (kIsWeb) {
      // For web, we'll just return true for now
      // In a real app, you would implement web-specific permission handling
      return true;
    }

    final permissionStatus = await PhotoManager.requestPermissionExtend();
    return permissionStatus.isAuth;
  }

  static Future<bool> requestStoragePermissions() async {
    if (kIsWeb) {
      // For web, we'll just return true for now
      // In a real app, you would implement web-specific permission handling
      return true;
    }

    // First try with PhotoManager
    final photoPermission = await PhotoManager.requestPermissionExtend();
    if (photoPermission.isAuth) {
      return true;
    }

    // If that doesn't work, try with permission_handler
    // Request storage permissions for Android
    if (await Permission.storage.request().isGranted) {
      return true;
    }

    // For Android 10+ we need media location permission as well
    if (await Permission.accessMediaLocation.request().isGranted) {
      return true;
    }

    // For Android 13+, we need to request specific permissions
    final photos = await Permission.photos.request();
    return photos.isGranted;
  }
}
