import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/constants/app_colors.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import 'package:ramo_photo_editor/providers/draft_provider.dart';
import 'package:image_cropper/image_cropper.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);

    // Get the current draft's image path
    final String imagePath = draftProvider.currentDraft?.imagePath ?? "";
    final String originalImagePath =
        draftProvider.currentDraft?.originalImagePath ?? "";
    final Uint8List originalImageData =
        draftProvider.currentDraft?.originalImageData ?? Uint8List(0);
    final Uint8List imageData =
        draftProvider.currentDraft?.imageData ?? Uint8List(0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.mintGreen),
        ),
        actions: [
          IconButton(
            onPressed: () async {

                await _cropImage(context, originalImagePath, draftProvider);

            },
            icon: Icon(Icons.crop, color: AppColors.mintGreen),
          ),
          IconButton(
            onPressed: () {
              draftProvider.updateCurrentDraftImage(
                  originalImageData, originalImagePath);
            },
            icon: Icon(Icons.undo, color: AppColors.mintGreen),
          )
        ],
      ),
      body: Center(
        child: imageData.isNotEmpty
            ? Image.memory(
                imageData,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : Text(
                AppLocalizations.of(context)!.translate("no_crop_image"),
                style: AppTextStyles.normalTextStyle
                    .copyWith(color: AppColors.mintGreen),
              ),
      ),
    );
  }

  Future<void> _cropImage(
    BuildContext context,
    String imagePath,
    DraftProvider draftProvider,
  ) async {
    // Open the image cropper
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppLocalizations.of(context)!.translate('crop'),
          activeControlsWidgetColor: Colors.red,
          toolbarColor: Colors.black,
          toolbarWidgetColor: AppColors.mintGreen,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: AppLocalizations.of(context)!.translate('crop'),
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      // Update the current draft with the cropped image
      final croppedImageData = await croppedFile.readAsBytes();

      draftProvider.updateCurrentDraftImage(
        croppedImageData,
        croppedFile.path,
      );
    }
  }
}
