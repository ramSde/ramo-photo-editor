import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/constants/app_colors.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import 'package:ramo_photo_editor/screens/first_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ramo_photo_editor/providers/locale_provider.dart';

import '../constants/supported_locales.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      locale: localeProvider.locale,
      // Dynamic locale from Provider
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Custom delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Ramo Photo Editor App',
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const FirstScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ScreenUtilInit(builder: (context, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Lottie.asset(
                  'assets/images/splash_animation.json',
                  // Replace with the path to your Lottie JSON file
                  fit: BoxFit.cover,

                  // Set to true if you want the animation to loop
                ),
              ),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.translate('splash_text'),
                  style: AppTextStyles.headerStyle,
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
