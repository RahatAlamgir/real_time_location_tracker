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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': position.latitude,
    'longitude': position.longitude,
    'fact': fact,
  };

  factory Landmark.fromJson(Map<String, dynamic> json) => Landmark(
    id: json['id'],
    name: json['name'],
    position: LatLng(json['latitude'], json['longitude']),
    fact: json['fact'],
  );
}
