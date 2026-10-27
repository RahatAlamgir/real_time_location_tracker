import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/permission/permission.dart';

class InitPosition {
  static const CameraPosition openingCamera = CameraPosition(
    target: LatLng(23.740, 90.400),
    zoom: 12,
  );

  static const List<LatLng> testPathRoute = [
    LatLng(23.740, 90.400),
    LatLng(23.740, 90.41),
    LatLng(23.740, 90.42),
    LatLng(23.750, 90.42),
    LatLng(23.740, 90.43),
  ];

  static Future<Position?> getPosition() async {
    if (await Permission.hasLocationPermission()) {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: .high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return position;
    } else {
      return null;
    }
  }
}
