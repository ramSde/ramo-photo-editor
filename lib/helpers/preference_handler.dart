import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  // shared pref instance
  static SharedPreferences? _prefs;

// Preference(){
//   load();
// }

  static Future<SharedPreferences> load() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    List<String>? val =  _prefs?.getStringList(key);
    return val;
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  String? getString(String key, {String? def}) {
    String? val;
    val ??=  _prefs?.getString(key);
    print("access token prference $val");
    val ??= def;
    return val;
  }

  int? getInt(String key, {int? def}) {
    int? val;
    val ??= _prefs?.getInt(key);
    val ??= def;
    return val;
  }

  double? getDouble(String key, {double? def}) {
    double? val;
    val ??= _prefs?.getDouble(key);
    val ??= def;
    return val;
  }

  bool? getBool(String key) {
    bool? val;
    val = _prefs?.getBool(key);
    return val;
  }


  /*String _convertToJsonStringQuotes({required String raw}) {
    /// remove space
    String jsonString = raw.replaceAll(" ", "");

    /// add quotes to json string
    jsonString = jsonString.replaceAll('{', '{"');
    jsonString = jsonString.replaceAll(':', '": "');
    jsonString = jsonString.replaceAll(',', '", "');
    jsonString = jsonString.replaceAll('}', '"}');

    /// remove quotes on object json string
    jsonString = jsonString.replaceAll('"{"', '{"');
    jsonString = jsonString.replaceAll('"}"', '"}');

    /// remove quotes on array json string
    jsonString = jsonString.replaceAll('"[{', '[{');
    jsonString = jsonString.replaceAll('}]"', '}]');

    return jsonString;
  }*/

  Future<bool> remove(String key) async {
    await _prefs?.remove(key);
    return true;
  }

  Future<bool> clear() async {
    await _prefs?.clear();
    return true;
  }

  clearPrefsExcept(List<String> mKeys) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    keys.removeAll(mKeys);
    for(var key in keys) {
      if(prefs.containsKey(key)) {
        prefs.remove(key);
      }
    }
  }
}

mixin PrefKeys {
  static const String selectedLang = 'lang';
}