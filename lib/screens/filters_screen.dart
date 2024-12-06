import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import 'package:ramo_photo_editor/models/filter_model.dart';
import 'package:ramo_photo_editor/providers/draft_provider.dart';
import 'dart:ui' as ui;

import '../constants/app_colors.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  final GlobalKey _globalKey = GlobalKey();
  final _filterColor = ValueNotifier<int>(0); // Use index instead of color

  // Original filter and other filters
  final List<Filter> _filters = [
    Filter(name: "Original", color: null), // No filter for Original
    Filter(color: Color(0xFF704214), name: "Sepia"),
    Filter(color: Color(0xFFBFA382), name: "Vintage"),
    Filter(color: Color(0xFF808080), name: "Grayscale"),
    Filter(color: Color(0xFFFFE4B5), name: "Brighten"),
    Filter(color: Color(0xFF4682B4), name: "Cool Blue"),
    Filter(color: Color(0xFFFFD700), name: "Warm Glow"),
    Filter(color: Color(0xFF9370DB), name: "Faded Purple"),
    Filter(color: Color(0xFF008080), name: "Teal Tint"),
    Filter(color: Color(0xFFFFC0CB), name: "Retro Pink"),
    Filter(color: Color(0xFF50C878), name: "Emerald"),
    Filter(color: Color(0xFF2E8B57), name: "Ocean Depths"),
    Filter(color: Color(0xFFFF4500), name: "Sunset"),
    Filter(color: Color(0xFF8B4513), name: "Chocolate"),
    Filter(color: Color(0xFFE6E6FA), name: "Soft Lavender"),
    Filter(color: Color(0xFFB0E0E6), name: "Pastel Blue"),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final String imagePath = draftProvider.currentDraft?.imagePath ?? "";
    final Uint8List imageData =
        draftProvider.currentDraft?.imageData ?? Uint8List(0);
    final String originalImagePath =
        draftProvider.currentDraft?.originalImagePath ?? "";
    final Uint8List originalImageData =
        draftProvider.currentDraft?.originalImageData ?? Uint8List(0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.of(context).pop();
          },
          color: AppColors.mintGreen,
        ),
        actions: [
          IconButton(
            onPressed: () {
              draftProvider.updateCurrentDraftImage(
                  originalImageData, originalImagePath);
              _filterColor.value = 0; // Reset to original
            },
            icon: Icon(Icons.undo, color: AppColors.mintGreen),
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              convertWidgetToImage(context);
              Navigator.of(context).pop();
            },
            color: AppColors.mintGreen,
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              child: ValueListenableBuilder<int>(
                valueListenable: _filterColor,
                builder: (context, filterIndex, child) {
                  return RepaintBoundary(
                    key: _globalKey,
                    child: Image.memory(
                      imageData,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      color: _filters[filterIndex].color ?? Colors.transparent,
                      // No effect if null
                      colorBlendMode: _filters[filterIndex].color != null
                          ? BlendMode.color
                          : BlendMode.dst, // If null, no effect
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 150.h, // Adjusted height for filter selection
        color: Colors.transparent,
        child: FilterSelector(
          filters: _filters,
          image: imageData, // Pass image data
          onFilterChanged: _onFilterChanged,
        ),
      ),
    );
  }

  void _onFilterChanged(int index) {
    _filterColor.value = index;
  }

  void convertWidgetToImage(BuildContext context) async {
    final draftProvider = Provider.of<DraftProvider>(context, listen: false);
    RenderRepaintBoundary? repaintBoundary =
        _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (repaintBoundary != null) {
      ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1.0);

      ByteData? byteData =
          await boxImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? uint8list = byteData?.buffer.asUint8List();
      draftProvider.updateCurrentDraftImage(uint8list ?? Uint8List(0),
          draftProvider.currentDraft?.imagePath ?? '');
    }
  }
}

@immutable
class FilterSelector extends StatefulWidget {
  const FilterSelector({
    super.key,
    required this.filters,
    required this.onFilterChanged,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    required this.image,
  });

  final List<Filter> filters;
  final void Function(int selectedIndex) onFilterChanged;
  final EdgeInsets padding;
  final Uint8List image;

  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  static const _filtersPerScreen = 4.5;
  static const _viewportFractionPerItem = 1.0 / _filtersPerScreen;

  late final PageController _controller;
  late int _page;

  int get filterCount => widget.filters.length;

  Color? itemColor(int index) => widget.filters[index % filterCount].color;

  @override
  void initState() {
    super.initState();
    _page = 0;
    _controller = PageController(
      initialPage: _page,
      viewportFraction: _viewportFractionPerItem,
    );
    _controller.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = (_controller.page ?? 0).round();
    if (page != _page) {
      _page = page;
      widget.onFilterChanged(page);
    }
  }

  void _onFilterTapped(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.w,
      child: PageView.builder(
        controller: _controller,
        itemCount: filterCount,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onFilterTapped(index),
            child: Padding(
              padding: widget.padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      child: Image.memory(
                        widget.image,
                        color:
                            widget.filters[index].color ?? Colors.transparent,
                        colorBlendMode: widget.filters[index].color != null
                            ? BlendMode.color
                            : BlendMode.dst,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(widget.filters[index].name,
                      style: AppTextStyles.normalTextStyle
                          .copyWith(color: AppColors.mintGreen),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
