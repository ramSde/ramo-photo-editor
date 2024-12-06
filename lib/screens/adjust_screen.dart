import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/constants/app_colors.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import '../providers/draft_provider.dart';

class AdjustScreen extends StatefulWidget {
  const AdjustScreen({super.key});

  @override
  State<AdjustScreen> createState() => _AdjustScreenState();
}

class _AdjustScreenState extends State<AdjustScreen> {
  double _brightness = 1.0;
  double _saturation = 1.0;
  double _contrast = 1.0;
  double _hue = 0.0;
  double _sepia = 0.0;

  bool _showBrightnessSlider = false;
  bool _showSaturationSlider = false;
  bool _showContrastSlider = false;
  bool _showHueSlider = false;
  bool _showSepiaSlider = false;

  bool _isAdjusted = false; // Flag to track if any adjustments were made

  Uint8List? _adjustedImage;
  final _globalKey = GlobalKey();

  // Function to build a custom slider
  Widget _buildSlider(String label, double value, Function(double) onChanged,
      double min, double max,) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.translate(label),
              style: AppTextStyles.normalTextStyle
                  .copyWith(color: AppColors.mintGreen)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  onChanged: onChanged,
                  min: min,
                  max: max,
                  activeColor: AppColors.mintGreen,
                ),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    // Reset slider value and corresponding adjustment
                    if (label == 'brightness') {
                      _brightness = 1.0;
                    } else if (label == 'saturation') {
                      _saturation = 1.0;
                    } else if (label == 'contrast') {
                      _contrast = 1.0;
                    } else if (label == 'hue') {
                      _hue = 0.0;
                    } else if (label == 'sepia') {
                      _sepia = 0.0;
                    }
                    _isAdjusted = false; // Mark adjustments as not done
                  });
                },
                child: Text(AppLocalizations.of(context)!.translate('reset'),
                    style: AppTextStyles.normalTextStyle
                        .copyWith(color: AppColors.mintGreen)),
              )
            ],
          ),
        ],
      ),
    );
  }

  // Generate the adjusted image using ColorFilter
  ColorFilter get _colorFilter {
    if (!_isAdjusted) {
      return ColorFilter.mode(
          Colors.transparent, BlendMode.multiply); // No effect initially
    }

    // Brightness matrix
    final brightnessMatrix = <double>[
      1,
      0,
      0,
      0,
      (_brightness - 1) * 255,
      0,
      1,
      0,
      0,
      (_brightness - 1) * 255,
      0,
      0,
      1,
      0,
      (_brightness - 1) * 255,
      0,
      0,
      0,
      1,
      0,
    ];

    // Saturation matrix
    final saturation = _saturation;
    final saturationMatrix = <double>[
      0.213 + 0.787 * saturation,
      0.715 - 0.715 * saturation,
      0.072 - 0.072 * saturation,
      0,
      0,
      0.213 - 0.213 * saturation,
      0.715 + 0.285 * saturation,
      0.072 - 0.072 * saturation,
      0,
      0,
      0.213 - 0.213 * saturation,
      0.715 - 0.715 * saturation,
      0.072 + 0.928 * saturation,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    // Contrast matrix
    final contrast = _contrast;
    final contrastMatrix = <double>[
      contrast,
      0,
      0,
      0,
      (1 - contrast) * 128,
      0,
      contrast,
      0,
      0,
      (1 - contrast) * 128,
      0,
      0,
      contrast,
      0,
      (1 - contrast) * 128,
      0,
      0,
      0,
      1,
      0,
    ];

    // Hue rotation matrix
    final hue = _hue * 3.1415926535897932; // Convert to radians
    final cosValue = cos(hue);
    final sinValue = sin(hue);
    final hueMatrix = <double>[
      0.213 + cosValue * 0.787 - sinValue * 0.213,
      0.715 - cosValue * 0.715 - sinValue * 0.715,
      0.072 - cosValue * 0.072 + sinValue * 0.928,
      0,
      0,
      0.213 - cosValue * 0.213 + sinValue * 0.143,
      0.715 + cosValue * 0.285 + sinValue * 0.140,
      0.072 - cosValue * 0.072 - sinValue * 0.283,
      0,
      0,
      0.213 - cosValue * 0.213 - sinValue * 0.787,
      0.715 - cosValue * 0.715 + sinValue * 0.715,
      0.072 + cosValue * 0.928 + sinValue * 0.072,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    // Sepia matrix
    final sepiaMatrix = <double>[
      0.393 + 0.607 * (1 - _sepia),
      0.769 - 0.769 * (1 - _sepia),
      0.189 - 0.189 * (1 - _sepia),
      0,
      0,
      0.349 - 0.349 * (1 - _sepia),
      0.686 + 0.314 * (1 - _sepia),
      0.168 - 0.168 * (1 - _sepia),
      0,
      0,
      0.272 - 0.272 * (1 - _sepia),
      0.534 - 0.534 * (1 - _sepia),
      0.131 + 0.869 * (1 - _sepia),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    // Combine all adjustments into a single matrix
    final combinedMatrix = List.generate(20, (index) {
      return brightnessMatrix[index] +
          saturationMatrix[index] +
          contrastMatrix[index] +
          hueMatrix[index] +
          sepiaMatrix[index];
    });

    return ColorFilter.matrix(combinedMatrix);
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final imageData = draftProvider.currentDraft?.imageData ?? Uint8List(0);
    final originalImageData =
        draftProvider.currentDraft?.originalImageData ?? Uint8List(0);
    final originalImagePath =
        draftProvider.currentDraft?.originalImagePath ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.mintGreen),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Reset all adjustments and revert to original image
              setState(() {
                _brightness = 1.0;
                _saturation = 1.0;
                _contrast = 1.0;
                _hue = 0.0;
                _sepia = 0.0;
                _isAdjusted = false; // Reset adjustments flag
                _adjustedImage = null; // Reset the adjusted image
              });

              // Update the draft image to the original data
              draftProvider.updateCurrentDraftImage(
                  originalImageData, originalImagePath);
            },
            icon: Icon(Icons.undo, color: AppColors.mintGreen),
          ),
          IconButton(
            onPressed: () async {
              // Update the current draft image with adjustments
              if (imageData != null) {
                setState(() {
                  _adjustedImage = imageData;
                  _isAdjusted = true; // Mark adjustments as done
                });
                convertWidgetToImage(context);
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.check, color: AppColors.mintGreen),
          ),
        ],
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Image with applied adjustments
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _globalKey,
                child: ImageFiltered(
                  imageFilter: _colorFilter,
                  child: Image.memory(
                    imageData ?? Uint8List(0),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar with icons
          Container(
            width: double.infinity,
            height: 100.h,
            color: Colors.black,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _bottomNavItem('Brightness', Icons.brightness_6, () {
                    setState(() {
                      _showBrightnessSlider = !_showBrightnessSlider;
                    });
                  }),
                  _bottomNavItem('Saturation', Icons.color_lens, () {
                    setState(() {
                      _showSaturationSlider = !_showSaturationSlider;
                    });
                  }),
                  _bottomNavItem('Contrast', Icons.exposure, () {
                    setState(() {
                      _showContrastSlider = !_showContrastSlider;
                    });
                  }),
                  _bottomNavItem('Hue', Icons.colorize, () {
                    setState(() {
                      _showHueSlider = !_showHueSlider;
                    });
                  }),
                  _bottomNavItem('Sepia', Icons.filter_tilt_shift, () {
                    setState(() {
                      _showSepiaSlider = !_showSepiaSlider;
                    });
                  }),
                ],
              ),
            ),
          ),

          // Display sliders based on visibility state
          if (_showBrightnessSlider)
            _buildSlider('brightness', _brightness, (value) {
              setState(() {
                _brightness = value;
                _isAdjusted = true;
              });
            }, 0.0, 2.0),
          if (_showSaturationSlider)
            _buildSlider('saturation', _saturation, (value) {
              setState(() {
                _saturation = value;
                _isAdjusted = true;
              });
            }, 0.0, 2.0),
          if (_showContrastSlider)
            _buildSlider('contrast', _contrast, (value) {
              setState(() {
                _contrast = value;
                _isAdjusted = true;
              });
            }, 0.0, 2.0),
          if (_showHueSlider)
            _buildSlider('hue', _hue, (value) {
              setState(() {
                _hue = value;
                _isAdjusted = true;
              });
            }, -180.0, 180.0),
          if (_showSepiaSlider)
            _buildSlider('sepia', _sepia, (value) {
              setState(() {
                _sepia = value;
                _isAdjusted = true;
              });
            }, 0.0, 1.0),
        ],
      ),
    );
  }

  Widget _bottomNavItem(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.mintGreen),
            Text(AppLocalizations.of(context)!.translate(label),
                style: TextStyle(color: AppColors.mintGreen)),
          ],
        ),
      ),
    );
  }

  // Convert widget to image after adjustments
  Future<void> convertWidgetToImage(BuildContext context) async {
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    // Update the draft with the adjusted image
    Provider.of<DraftProvider>(context, listen: false)
        .updateCurrentDraftImage(pngBytes, '');
  }
}
