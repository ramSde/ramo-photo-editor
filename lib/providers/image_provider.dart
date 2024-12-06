import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/providers/draft_provider.dart';
import 'package:ramo_photo_editor/screens/editing_screen_home.dart';

import '../constants/app_colors.dart';
import '../helpers/localization_helper.dart';

class ImageProviderForFirstScreen extends ChangeNotifier {
  // To store the selected file path
  String? selectedFilePath;

  /// Function to handle permission and select image or video
  Future<void> selectMedia({
    required BuildContext context,
    required bool fromCamera, // true for camera, false for gallery
  }) async {
    // Check and handle permissions
    bool permissionGranted = await _handlePermission(context, fromCamera);
    if (!permissionGranted) return;

    final ImagePicker picker = ImagePicker();
    final ImageSource source =
        fromCamera ? ImageSource.camera : ImageSource.gallery;

    try {
      // Pick the media (image or video)
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        // User canceled the picker
        return;
      }

      // Save the selected file path and notify listeners
      selectedFilePath = pickedFile.path;
      final Uint8List imageData = await File(pickedFile.path).readAsBytes();

      // Update the current draft in DraftProvider with the selected image
      final draftProvider = Provider.of<DraftProvider>(context, listen: false);
      if (draftProvider.currentDraft == null) {
        // If no current draft exists, create a new one
        draftProvider.createNewDraft();
      }
      draftProvider.updateCurrentDraftImage(imageData,selectedFilePath);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditingScreenHome(),
        ),
      );

      notifyListeners();
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('media_select_error'),
            style: AppTextStyles.normalTextStyle
                .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  /// Private function to handle camera or gallery permissions
  Future<bool> _handlePermission(BuildContext context, bool isCamera) async {
    final Permission permission =
        isCamera ? Permission.camera : Permission.photos;
    final PermissionStatus status = await permission.status;

    if (status.isGranted) {
      // Permission already granted
      return true;
    } else if (status.isDenied || status.isLimited) {
      // Request permission
      final PermissionStatus newStatus = await permission.request();
      if (newStatus.isGranted) {
        return true;
      } else {
        // Permission denied, show dialog
        _showPermissionDialog(context, isCamera);
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, show dialog to open settings
      _showPermissionDialog(context, isCamera, openSettings: true);
      return false;
    }
    return false;
  }

  /// Show a dialog to explain why permission is needed
  void _showPermissionDialog(BuildContext context, bool isCamera,
      {bool openSettings = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.translate(isCamera
                ? 'camera_permission_needed'
                : 'gallery_permission_needed'),
            style: AppTextStyles.normalTextStyle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.translate(isCamera
                ? 'camera_permission_description'
                : 'gallery_permission_description'),
            style: AppTextStyles.normalTextStyle,
          ),
          actions: [
            if (openSettings)
              TextButton(
                onPressed: () {
                  openAppSettings(); // Open app settings to enable permission
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('open_settings'),
                  style: AppTextStyles.normalTextStyle.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.translate('cancel'),
                style: AppTextStyles.normalTextStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}
