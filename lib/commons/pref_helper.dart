import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static Future<bool> savePref(String key, String value) {
    return SharedPreferences.getInstance().then((prefs) {
      return prefs.setString(key, jsonEncode(value));
    });
  }

  static Future<dynamic> getPref(String key) async {
    var prefs = await SharedPreferences.getInstance();
    var data = jsonDecode(prefs.getString(key) ?? 'false');
    return data;
  }

  static read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(key));
  }

  static save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  static remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
