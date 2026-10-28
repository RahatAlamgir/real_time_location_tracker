import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/model/landmark.dart';

class LandmarkProvidert extends ChangeNotifier {
  LatLng? _lastLocation;
  final Map<String, List<Landmark>> _landmarkLists = {};
  final bool _isLoading = true;

  LatLng? get lastLocation => _lastLocation;
  Map<String, List<Landmark>> get landmarkLists => _landmarkLists;
  bool get isLoading => _isLoading;
}
