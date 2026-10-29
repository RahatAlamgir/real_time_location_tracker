import 'package:geolocator/geolocator.dart';

class Permission {
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  static Future<void> requestPermission() async {
    if (!await hasLocationPermission()) {
      await Geolocator.requestPermission();
    }
  }
}
