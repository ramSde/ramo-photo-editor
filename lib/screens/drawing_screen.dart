import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_painter/image_painter.dart';
import 'package:provider/provider.dart';
import '../providers/draft_provider.dart';
import '../constants/app_colors.dart';
import 'dart:ui' as ui;

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  final _globalKey = GlobalKey();
  late TextEditingController emojiController;
  late ImagePainterController _imagePainterController;
  late String _imageUrl;
  List<Offset> drawingOffsets = [];

  @override
  void initState() {
    super.initState();
    emojiController = TextEditingController();
    _imagePainterController = ImagePainterController();
    _imageUrl = ''; // Replace with default image URL if needed
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

    if (imageData.isNotEmpty) {
      _imageUrl =
          ''; // Set it to empty since we will use the image from `imageData`
    } else {
      _imageUrl = ''; // Replace with a default image URL if needed
    }

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
            onPressed: () async {
              if (imageData.isNotEmpty) {
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
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    drawingOffsets.add(details.localPosition);
                    _imagePainterController.addOffsets(details.localPosition);
                    _imagePainterController.addPaintInfo(PaintInfo(
                      mode: PaintMode.arrow,
                      offsets: List.from(drawingOffsets), // Clone the list
                      color: Colors.white,
                      strokeWidth: 5.0,
                    ));
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    if (drawingOffsets.isNotEmpty) {
                      _imagePainterController.addOffsets(drawingOffsets.last);
                    }
                    drawingOffsets.clear();
                  });
                },
                child: Center(
                  child: ClipRect(
                    child: imageData.isNotEmpty
                        ? ImagePainter.memory(
                            imageData,
                            width: double.infinity,
                            controller: _imagePainterController,
                            scalable: true,
                          )
                        : Center(
                            child: Text(
                              'No image available',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ),
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
    emojiController.dispose();
    super.dispose();
  }
}
