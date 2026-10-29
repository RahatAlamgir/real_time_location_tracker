import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:real_time_location_tracker/data/provider/app_status_provider.dart';

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

  static Future<Position?> getPosition(BuildContext context) async {
    if (context.read<AppStatusProvider>().locationPermission) {
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

  static Marker huePin(
    LatLng position, {
    String id = 'id',
    String name = '',
    String fact = '',
    double hue = BitmapDescriptor.hueRed,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(title: name, snippet: fact),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
    );
  }
}
