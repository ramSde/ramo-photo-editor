import 'package:flutter/material.dart';
import 'package:ramo_photo_editor/helpers/preference_handler.dart';

class LocaleProvider extends ChangeNotifier {
  static late Locale _locale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'es'].contains(locale.languageCode))
      return; // Supported locales
    _locale = locale;
    Preference().setString(
        PrefKeys.selectedLang, locale.languageCode == 'es' ? "es" : "en");
    notifyListeners();
  }
}
