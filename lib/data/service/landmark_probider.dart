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

  void LandmarkProvider() {
    loadData();
  }

  /// Load initial data from SharedPreferences
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _lastLocation = await _storageService.getLastLocation();
    _landmarkLists = await _storageService.getMultipleLists();

    _isLoading = false;
    notifyListeners();
  }

  /// Update and save the user's last map location
  Future<void> updateLastLocation(LatLng latLng) async {
    _lastLocation = latLng;
    notifyListeners();
    await _storageService.saveLastLocation(latLng);
  }

  /// Create a new empty landmark list category
  Future<void> createList(String listName) async {
    if (!_landmarkLists.containsKey(listName)) {
      _landmarkLists[listName] = [];
      notifyListeners();
      await _storageService.saveMultipleLists(_landmarkLists);
    }
  }

  /// Delete an entire list category
  Future<void> deleteList(String listName) async {
    if (_landmarkLists.containsKey(listName)) {
      _landmarkLists.remove(listName);
      notifyListeners();
      await _storageService.saveMultipleLists(_landmarkLists);
    }
  }

  /// Add a landmark to a specific list (creates the list if it doesn't exist)
  Future<void> addLandmarkToList(String listName, Landmark landmark) async {
    _landmarkLists.putIfAbsent(listName, () => []);

    // Remove if already exists with the same ID, then add (upsert behavior)
    _landmarkLists[listName]!.removeWhere((l) => l.id == landmark.id);
    _landmarkLists[listName]!.add(landmark);

    notifyListeners();
    await _storageService.saveMultipleLists(_landmarkLists);
  }

  /// Remove a landmark from a specific list by ID
  Future<void> removeLandmarkFromList(
    String listName,
    String landmarkId,
  ) async {
    if (_landmarkLists.containsKey(listName)) {
      _landmarkLists[listName]!.removeWhere((l) => l.id == landmarkId);
      notifyListeners();
      await _storageService.saveMultipleLists(_landmarkLists);
    }
  }
}
