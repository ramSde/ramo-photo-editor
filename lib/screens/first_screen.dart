import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/constants/app_colors.dart';
import 'package:ramo_photo_editor/constants/supported_locales.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import 'package:ramo_photo_editor/providers/draft_provider.dart';
import 'package:ramo_photo_editor/providers/image_provider.dart';
import 'package:ramo_photo_editor/providers/locale_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ramo_photo_editor/screens/editing_screen_home.dart';

import '../models/draft_model.dart';

// ignore: depend_on_referenced_packages

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final imageProvider = Provider.of<ImageProviderForFirstScreen>(context);
    final draftProvider = Provider.of<DraftProvider>(context);
    final drafts = draftProvider.drafts;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              "assets/images/background.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Top Bar with Language Selector
          Padding(
            padding:
                const EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton<Locale>(
                      onSelected: (Locale locale) {
                        localeProvider.setLocale(locale);
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<Locale>>[
                        PopupMenuItem<Locale>(
                          value: Locale('en'),
                          child: Text('English',
                              style: AppTextStyles.normalTextStyle),
                        ),
                        PopupMenuItem<Locale>(
                          value: Locale('es'),
                          child: Text('Español',
                              style: AppTextStyles.normalTextStyle),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Main Content and Buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        imageProvider.selectMedia(
                            context: context, fromCamera: false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Text(
                          AppLocalizations.of(context)!.translate('gallery'),
                          style: AppTextStyles.normalTextStyle.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        imageProvider.selectMedia(
                            context: context, fromCamera: true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Text(
                          AppLocalizations.of(context)!.translate('camera'),
                          style: AppTextStyles.normalTextStyle.copyWith(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ))
                ],
              ),
            ),
          ),
          // Carousel for Drafts
          Positioned(
            bottom: 70, // Adjust as needed to place the carousel correctly
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CarouselSlider.builder(
                itemCount: drafts.length,
                itemBuilder: (context, index, realIndex) {
                  final draft = drafts[index];
                  final file = draft.imageData;

                  // Check if the image file exists


                  return InkWell(
                    onTap: (){
                      draftProvider.setCurrentDraft(draft);
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>EditingScreenHome()));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5.r,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: file!=null && file != Uint8List(0)
                            ? Image.memory(
                                file,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/placeholder.jpg',
                                // Use a placeholder if image doesn't exist
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  autoPlayCurve: Curves.decelerate,
                  height: 180.h,
                  // Set the height for the carousel
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                  enableInfiniteScroll: false,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    // Optional: Handle page change
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
