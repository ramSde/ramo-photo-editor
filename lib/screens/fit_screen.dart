import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/constants/app_colors.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import '../providers/draft_provider.dart';

class FitScreen extends StatefulWidget {
  const FitScreen({super.key});

  @override
  State<FitScreen> createState() => _FitScreenState();
}

class _FitScreenState extends State<FitScreen> {
  bool _isAdjusted = false;
  Uint8List? _adjustedImage;
  final _globalKey = GlobalKey();
  double _blurValue = 0.0; // Blur intensity
  double _textureOpacity = 0.0; // Texture opacity
  double _aspectRatio = 1.0; // Default aspect ratio
  bool _showBlur = false;
  bool _showTexture = false;
  bool _showAspectRatio = false;

  Color _containerColor = Colors.white; // Default container color

  final Map<String, double> _aspectRatios = {
    'Original': 0.0, // Special case: Original aspect ratio
    '1:1': 1.0,
    '4:3': 4 / 3,
    '16:9': 16 / 9,
    '9:16': 9 / 16
  };
  final List<String> _textures = [
    'assets/images/textures/texture1.jpg',
    'assets/images/textures/texture2.jpg',
    'assets/images/textures/texture3.jpg',
    'assets/images/textures/texture4.jpg',
  ];
  String _selectedTexture =
      'assets/images/textures/texture1.jpg'; // Default texture

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
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _blurValue = 0.0;
                _textureOpacity = 0.0;
                _aspectRatio = 1.0;
                _isAdjusted = false;
                _showBlur = false;
                _showTexture = false;
                _showAspectRatio = false;
              });
            },
            icon: Icon(Icons.undo, color: AppColors.mintGreen),
          ),
          IconButton(
            onPressed: () async {
              if (imageData.isNotEmpty) {
                setState(() {
                  _isAdjusted = true;
                });
                await convertWidgetToImage(context);
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
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _globalKey,
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _aspectRatio == 0.0 ? 1.0 : _aspectRatio,
                      child: Container(
                        color: _containerColor, // Apply the selected color here
                        child: Center(
                          child: ClipRect(
                            child: ImageFiltered(
                              imageFilter: ui.ImageFilter.blur(
                                sigmaX: _blurValue,
                                sigmaY: _blurValue,
                              ),
                              child: Image.memory(
                                imageData,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_textureOpacity > 0.0)
                      Opacity(
                        opacity: _textureOpacity,
                        child: Image.asset(
                          _selectedTexture,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_showAspectRatio) _buildAspectRatioSelector(),
          if (_showBlur)
            _buildSlider(
              'Blur',
              _blurValue,
              (value) => setState(() => _blurValue = value),
              0.0,
              10.0,
            ),
          if (_showTexture)
            Column(
              children: [
                _buildSlider(
                  'Texture',
                  _textureOpacity,
                  (value) => setState(() => _textureOpacity = value),
                  0.0,
                  1.0,
                ),
                _buildTextureSelector()
              ],
            ),
          Container(
            width: double.infinity,
            height: 100.w,
            color: Colors.black,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _bottomNavItem('Blur', Icons.brightness_6, () {
                    setState(() {
                      _showBlur = !_showBlur;
                      _showTexture = false;
                      _showAspectRatio = false;
                    });
                  }),
                  _bottomNavItem('Texture', Icons.color_lens, () {
                    setState(() {
                      _showTexture = !_showTexture;
                      _showBlur = false;
                      _showAspectRatio = false;
                    });
                  }),
                  _bottomNavItem('Aspect Ratio', Icons.aspect_ratio, () {
                    setState(() {
                      _showAspectRatio = !_showAspectRatio;
                      _showBlur = false;
                      _showTexture = false;
                    });
                  }),
                  _bottomNavItem('Pick Color', Icons.color_lens, () {
                    _showColorPicker(context);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    Color pickedColor = _containerColor;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (Color color) {
                pickedColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent:
                  0.8, // Keep this to control the picker area size
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _containerColor = pickedColor;
                });
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.translate('Select'),
                style: AppTextStyles.normalTextStyle,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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

  Widget _buildAspectRatioSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _aspectRatios.entries.map((entry) {
          final isSelected = entry.value == _aspectRatio;
          return InkWell(
            onTap: () {
              setState(() {
                _aspectRatio = entry.value;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mintGreen : Colors.black,
                border: Border.all(color: AppColors.mintGreen),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                entry.key,
                style: AppTextStyles.normalTextStyle.copyWith(
                  color: isSelected ? Colors.black : AppColors.mintGreen,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextureSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _textures.map((texture) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTexture = texture;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedTexture == texture
                        ? AppColors.mintGreen
                        : Colors.transparent,
                  ),
                ),
                child: Image.asset(
                  texture,
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _bottomNavItem(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.mintGreen),
            Text(AppLocalizations.of(context)!.translate(label),
                style: AppTextStyles.normalTextStyle
                    .copyWith(color: AppColors.mintGreen)),
          ],
        ),
      ),
    );
  }

  Future<void> convertWidgetToImage(BuildContext context) async {
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    Provider.of<DraftProvider>(context, listen: false)
        .updateCurrentDraftImage(pngBytes, '');
  }

  Widget _buildSlider(
    String label,
    double value,
    Function(double) onChanged,
    double min,
    double max,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.normalTextStyle.copyWith(
              color: AppColors.mintGreen,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
