import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/data/service/init_position.dart';
import 'package:real_time_location_tracker/data/permission/permission.dart';
import 'package:real_time_location_tracker/data/service/landmark_storage_service.dart';

class AppStatusProvider extends ChangeNotifier {
  bool _locationPermission = false;

  bool _isFinding = false;
  bool _isRecording = false;
  LatLng? _me;
  Set<Marker> _myMarkers = {};
  List<LatLng> _points = [];
  List<String> _allKeyName = [];
  int _intervalSeconds = 5;

  List<String> get allKeyName => _allKeyName;

  int get intervalSceonds => _intervalSeconds;

  List<LatLng> get points => _points;
  bool get isFinding => _isFinding;
  bool get isRecording => _isRecording;

  Set<Marker> get myMarkers => _myMarkers;

  Future<void> updateAllKeyName() async {
    _allKeyName = await LandmarkStorageService.getAllKeys();
    notifyListeners();
  }

  void toggleIntervalSeconds() {
    _intervalSeconds = _intervalSeconds == 5 ? 10 : 5;
    notifyListeners();
  }

  void setIntervalSeconds(int seconds) {
    _intervalSeconds = seconds;
    notifyListeners();
  }

  void addPoint() {
    points.add(_me!);
    notifyListeners();
  }

  void clearPoint() {
    points.clear();
    notifyListeners();
  }

  void setMyMarker() {
    if (_me != null) {
      _myMarkers = {
        Marker(
          markerId: const MarkerId('me'),
          position: _me!,
          infoWindow: InfoWindow(
            title: 'My Current Location',
            snippet: '${_me!.latitude}, ${_me!.longitude}',
          ),
        ),
      };
      notifyListeners();
    }
  }

  LatLng get me {
    if (_me == null) {
      return InitPosition.openingCamera.target;
    } else {
      return _me!;
    }
  }

  Future<void> autoUpdateMe() async {
    toggleIsFinding(value: true);
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: .high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    _me = LatLng(position.latitude, position.longitude);
    setMyMarker();
    toggleIsFinding(value: false);
    notifyListeners();
  }

  void setMe(LatLng me) {
    _me = me;
    setMyMarker();
    notifyListeners();
  }

  void toggleIsFinding({bool? value}) {
    _isFinding = value ?? !_isFinding;
    notifyListeners();
  }

  void toggleIsRecording({bool? value}) {
    _isRecording = value ?? !_isRecording;
    notifyListeners();
  }

  bool get locationPermission {
    if (_locationPermission) {
      return _locationPermission;
    } else {
      getLocationPermission();
    }

    return _locationPermission;
  }

  Future<void> getLocationPermission() async {
    final permission = await Permission.hasLocationPermission();
    if (_locationPermission != permission) {
      _locationPermission = permission;
      notifyListeners();
    }
  }
}
