import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ramo_photo_editor/helpers/localization_helper.dart';
import 'package:ramo_photo_editor/helpers/preference_handler.dart';
import 'package:ramo_photo_editor/providers/draft_provider.dart';
import 'package:ramo_photo_editor/providers/image_provider.dart';
import 'package:ramo_photo_editor/providers/locale_provider.dart';
import 'package:ramo_photo_editor/screens/first_screen.dart';
import 'package:ramo_photo_editor/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force light mode system interface
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // Optional
    ),
  );
  // Retrieve saved language preference
  await Preference.load();
  final String? savedLocale = Preference().getString(PrefKeys.selectedLang);
  late AppLocalizations appLocalizations;
  // Initialize LocaleProvider with the saved locale
  final LocaleProvider localeProvider = LocaleProvider();
  if (savedLocale != null) {
    localeProvider.setLocale(Locale(savedLocale));
    appLocalizations = AppLocalizations(Locale(savedLocale));
    appLocalizations.load();
  } else {
    appLocalizations = AppLocalizations(Locale('en'));
    appLocalizations.load();
    localeProvider.setLocale(Locale('en'));
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ImageProviderForFirstScreen()),
    ChangeNotifierProvider(create: (_) => LocaleProvider()),
    ChangeNotifierProvider(create: (_) => DraftProvider()),
  ], child: MyApp()));
}
