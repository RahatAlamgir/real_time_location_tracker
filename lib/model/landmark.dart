import 'package:google_maps_flutter/google_maps_flutter.dart';

class Landmark {
  const Landmark({
    required this.id,
    required this.name,
    required this.position,
    required this.fact,
  });

  /// Becomes the MarkerId. Two markers on the same map cannot share an id.
  final String id;
  final String name;
  final LatLng position;

  /// The short line under the name in an info window.
  final String fact;
}
