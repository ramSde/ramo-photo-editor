import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_icon.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';

import '../providers/draft_provider.dart';
import '../constants/app_colors.dart';

class StickersScreen extends StatefulWidget {
  const StickersScreen({super.key});

  @override
  State<StickersScreen> createState() => _StickersScreenState();
}

class _StickersScreenState extends State<StickersScreen> {
  final _globalKey = GlobalKey();
  late LindiController controller;
  TextEditingController emojiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = LindiController(
      borderColor: Colors.white,
      icons: [
        LindiStickerIcon(
          icon: Icons.done,
          alignment: Alignment.topRight,
          onTap: () {
            if (controller.selectedWidget != null) {
              controller.selectedWidget?.done();
              setState(() {});
            }
          },
        ),
        LindiStickerIcon(
            icon: Icons.edit,
            alignment: Alignment.bottomCenter,
            onTap: () {
              controller.selectedWidget!
                  .edit(const Icon(Icons.star, size: 50, color: Colors.yellow));
            }),
        LindiStickerIcon(
          icon: Icons.lock_open,
          lockedIcon: Icons.lock,
          alignment: Alignment.topCenter,
          type: IconType.lock,
          onTap: () {
            if (controller.selectedWidget != null) {
              controller.selectedWidget!.lock();
            }
          },
        ),
        LindiStickerIcon(
          icon: Icons.close,
          alignment: Alignment.topLeft,
          onTap: () {
            if (controller.selectedWidget != null) {
              controller.selectedWidget!.delete();
            }
          },
        ),
        LindiStickerIcon(
          icon: Icons.flip,
          alignment: Alignment.bottomLeft,
          onTap: () {
            if (controller.selectedWidget != null) {
              controller.selectedWidget!.flip();
            }
          },
        ),
        LindiStickerIcon(
          icon: Icons.crop_free,
          alignment: Alignment.bottomRight,
          type: IconType.resize,
        ),
      ],
    );

    controller.onPositionChange((index) {});
    controller.addListener(() {
      setState(() {});
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
        actions: [
          IconButton(
            onPressed: () {
              if (controller.selectedWidget != null) {
                controller.selectedWidget!.delete();
                setState(() {});
              }
            },
            icon: Icon(Icons.undo, color: AppColors.mintGreen),
          ),
          IconButton(
            onPressed: () async {
              if (imageData.isNotEmpty) {
                controller.selectedWidget?.done();
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
            child: RepaintBoundary(
              key: _globalKey,
              child: LindiStickerWidget(
                controller: controller,
                child: Center(
                  child: ClipRect(
                    child: imageData.isNotEmpty
                        ? Image.memory(imageData,
                            fit: BoxFit.cover, width: double.infinity)
                        : Center(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('no image'),
                              style: AppTextStyles.secondaryTextStyle
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 80.w,
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emojiController,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context)!.translate('enter emoji'),
                  hintStyle: AppTextStyles.normalTextStyle
                      .copyWith(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                style: AppTextStyles.secondaryTextStyle
                    .copyWith(color: Colors.black),
                onSubmitted: (emoji) {
                  controller.add(
                    Text(
                      emoji,
                      style: AppTextStyles.secondaryTextStyle
                          .copyWith(color: Colors.white),
                    ),
                    position: Alignment.center,
                  );
                  emojiController.clear();
                },
              ),
            ),
          ),
        ],
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

  @override
  void dispose() {
    controller.dispose();
    emojiController.dispose();
    super.dispose();
  }
}
