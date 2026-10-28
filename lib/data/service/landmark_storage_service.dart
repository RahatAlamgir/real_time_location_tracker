import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandmarkStorageService {
  static List<String> allKeys = [];
  static const String _allListkey = 'allKeys';

  static Future<void> saveKey(String key, bool save) async {
    final prefs = await SharedPreferences.getInstance();
    save ? allKeys.add(key) : allKeys.remove(key);
    await prefs.setStringList(_allListkey, allKeys);
  }

  static Future<List<String>> getAllKeys() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? keylist = prefs.getStringList(_allListkey);

    if (keylist != null) {
      allKeys = keylist;
    }
    return allKeys;
  }

  static Future<void> removeLocationList(String namekey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(namekey);
    saveKey(namekey, false);
  }

  static Future<void> saveLocationList(
    List<LatLng> locations,
    String namekey,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final String jsonString = jsonEncode(
      locations.map((loc) {
        return {'latitude': loc.latitude, 'longitude': loc.longitude};
      }).toList(),
    );

    await prefs.setString(namekey, jsonString);
    await saveKey(namekey, true);
  }

  static Future<List<LatLng>> getLocationList(String namekey) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(namekey);

    if (jsonString == null) return [];

    final List<dynamic> decodedList = jsonDecode(jsonString);

    return decodedList.map((item) {
      return LatLng(
        (item['latitude'] as num).toDouble(),
        (item['longitude'] as num).toDouble(),
      );
    }).toList();
  }
}
