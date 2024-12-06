import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/helpers/api_manager.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import '../providers/draft_provider.dart';
import 'package:ramo_photo_editor/constants/app_colors.dart';

class BackgroundRemovalScreen extends StatefulWidget {
  const BackgroundRemovalScreen({Key? key}) : super(key: key);

  @override
  State<BackgroundRemovalScreen> createState() =>
      _BackgroundRemovalScreenState();
}

class _BackgroundRemovalScreenState extends State<BackgroundRemovalScreen> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isLoading = false;

  /// Function to remove the background from the image
  Future<void> _removeBackground(BuildContext context) async {
    final draftProvider = Provider.of<DraftProvider>(context, listen: false);
    final imagePath = draftProvider.currentDraft?.imagePath;

    if (imagePath == null || draftProvider.currentDraft?.imageData == null) {
      _showError(context, AppLocalizations.of(context)!.translate('No image available to process.'));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API call to remove the background
      final response =
      await APIService.instance.removeBackground(File(imagePath));

      if (response != null && response.data != null) {
        final imageString = response.data;

        // Decode the response to Uint8List
        Uint8List newImageData;
        if (_isBase64(imageString)) {
          newImageData = base64Decode(imageString);
        } else {
          newImageData = Uint8List.fromList(imageString.codeUnits);
        }

        // Update the image in the provider
        draftProvider.updateCurrentDraftImage(newImageData, '');
      } else {
        _showError(context, 'Failed to process the image.');
      }
    } catch (e) {
      print('Error during background removal: $e');
      _showError(context, 'Error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Check if a string is Base64 encoded
  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Show error messages using SnackBar
  void _showError(BuildContext context, String message) {
    print(message);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Convert the widget to an image
  Future<void> _convertWidgetToImage(BuildContext context) async {
    try {
      final RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      Provider.of<DraftProvider>(context, listen: false)
          .updateCurrentDraftImage(pngBytes, '');
    } catch (e) {
      print('Error during image conversion: $e');
      _showError(context, 'Failed to save the image.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final imageData = draftProvider.currentDraft?.imageData ?? Uint8List(0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.mintGreen),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.mintGreen),
            onPressed: () {
              // Add any required refresh logic here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: Center(
                child: ClipRect(
                  child: imageData.isNotEmpty
                      ? Image.memory(
                    imageData,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                      : const Icon(
                    Icons.image,
                    color: AppColors.mintGreen,
                    size: 200,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (imageData.isNotEmpty)
                  _bottomNavItem('Remove Background', Icons.edit, () {
                    if (!_isLoading) _removeBackground(context);
                  }),
                if (imageData.isNotEmpty)
                  _bottomNavItem('save', Icons.save, () {
                    _convertWidgetToImage(context);
                  }),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  /// Create a bottom navigation item widget
  Widget _bottomNavItem(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.mintGreen),
            const SizedBox(height: 4.0),
            Text(
              AppLocalizations.of(context)!.translate(label),
              style:  AppTextStyles.normalTextStyle.copyWith(color: AppColors.mintGreen,),
            ),
          ],
        ),
      ),
    );
  }
}
