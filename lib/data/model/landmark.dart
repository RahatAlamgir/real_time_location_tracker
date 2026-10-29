import 'package:google_maps_flutter/google_maps_flutter.dart';

class Landmark {
  const Landmark({
    required this.id,
    required this.name,
    required this.position,
    required this.fact,
  });

  final String id;
  final String name;
  final LatLng position;

  final String fact;
}
