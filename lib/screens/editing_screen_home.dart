import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/constants/app_colors.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import 'package:ramo_photo_editor/providers/draft_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/constants/app_colors.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import 'package:ramo_photo_editor/providers/draft_provider.dart';
import 'package:ramo_photo_editor/screens/adjust_screen.dart';
import 'package:ramo_photo_editor/screens/crop_screen.dart';
import 'package:ramo_photo_editor/screens/drawing_screen.dart';
import 'package:ramo_photo_editor/screens/filters_screen.dart';
import 'package:ramo_photo_editor/screens/fit_screen.dart';
import 'package:ramo_photo_editor/screens/remove_bg_screen.dart';
import 'package:ramo_photo_editor/screens/stickers_screen.dart';

class EditingScreenHome extends StatefulWidget {
  const EditingScreenHome({super.key});

  @override
  State<EditingScreenHome> createState() => _EditingScreenHomeState();
}

class _EditingScreenHomeState extends State<EditingScreenHome> {
  Future<bool> _onWillPop(BuildContext context) async {
    final draftProvider = Provider.of<DraftProvider>(context, listen: false);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.translate('save_draft'),
            style: AppTextStyles.normalTextStyle,
          ),
          content: Text(
            AppLocalizations.of(context)!.translate('unsaved_changes'),
            style: AppTextStyles.normalTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                AppLocalizations.of(context)!.translate('discard'),
                style:
                    AppTextStyles.normalTextStyle.copyWith(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                draftProvider.saveCurrentDraft();
                Navigator.of(context).pop(true);
              },
              child: Text(
                AppLocalizations.of(context)!.translate('save'),
                style:
                    AppTextStyles.normalTextStyle.copyWith(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    return WillPopScope(
      // canPop: true,
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            AppLocalizations.of(context)!.translate('photo_editor'),
            style:
                AppTextStyles.headerStyle.copyWith(color: AppColors.mintGreen),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              final canPop = await _onWillPop(context);
              if (canPop) Navigator.of(context).pop();
            },
            color: AppColors.mintGreen,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                final canPop = await _onWillPop(context);
                if (canPop) Navigator.of(context).pop();
              },
              color: AppColors.mintGreen,
            ),
          ],
        ),
        body: Center(
          child: Image.memory(
            draftProvider.currentDraft?.imageData ?? Uint8List(0),
            // Displays image data in memory
            fit: BoxFit.cover,
            // Adjusts how the image fits within the container
            width: double
                .infinity, // Ensures the image spans the full width of the container
          ),
        ),
        bottomNavigationBar: Container(
          width: double.infinity,
          height: 60.h,
          color: Colors.black,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _bottomNavItem(AppLocalizations.of(context)!.translate('crop'),
                    Icons.crop_rotate, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CropScreen()));
                }),
                _bottomNavItem(
                    AppLocalizations.of(context)!.translate('filter'),
                    Icons.filter_vintage_outlined, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FiltersScreen()));
                }),
                _bottomNavItem(
                    AppLocalizations.of(context)!.translate('adjust'),
                    Icons.tune_outlined, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AdjustScreen()));
                }),
                _bottomNavItem(AppLocalizations.of(context)!.translate('fit'),
                    Icons.fit_screen_sharp, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FitScreen()));
                }),
                _bottomNavItem(
                    AppLocalizations.of(context)!.translate('Sticker'),
                    Icons.emoji_emotions_outlined, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StickersScreen()));
                }),
                _bottomNavItem(AppLocalizations.of(context)!.translate('Draw'),
                    Icons.draw_outlined, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DrawScreen()));
                }),
                _bottomNavItem(AppLocalizations.of(context)!.translate('Remove Background'),
                    Icons.draw_outlined, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BackgroundRemovalScreen()));
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.mintGreen,
            ),
            Text(
              text,
              style: AppTextStyles.secondaryTextStyle
                  .copyWith(color: AppColors.mintGreen),
            )
          ],
        ),
      ),
    );
  }
}
