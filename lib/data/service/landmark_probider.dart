import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/data/service/landmark_storage_service.dart';
import 'package:real_time_location_tracker/model/landmark.dart';

class LandmarkProvidert extends ChangeNotifier {
  final LandmarkStorageService _storageService = LandmarkStorageService();

  LatLng? _lastLocation;
  Map<String, List<Landmark>> _landmarkLists = {};
  bool _isLoading = true;

  LatLng? get lastLocation => _lastLocation;
  Map<String, List<Landmark>> get landmarkLists => _landmarkLists;
  bool get isLoading => _isLoading;
}
