import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/data/service/init_position.dart';
import 'package:real_time_location_tracker/data/service/landmark_storage_service.dart';
import 'package:real_time_location_tracker/data/widget/custom_app_bar.dart';
import 'package:real_time_location_tracker/data/widget/save_route_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late CameraPosition _cameraPosition;
  GoogleMapController? _mapController;
  Timer? _timer;

  int _fetchIntervalSeconds = 5;
  LatLng? _me;
  bool _isFinding = false;
  bool _isRecording = false;

  final TextEditingController _nameController = TextEditingController();
  List<LatLng> _points = [];

  @override
  void initState() {
    super.initState();
    _cameraPosition = InitPosition.openingCamera;
    _findMe();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _findMe() async {
    setState(() => _isFinding = true);

    final Position? position = await InitPosition.getPosition();
    if (position != null) {
      final newPos = LatLng(position.latitude, position.longitude);
      setState(() {
        _me = newPos;
        _isFinding = false;
      });

      if (mounted && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newPos, zoom: 18),
          ),
        );
      }
    } else {
      setState(() => _isFinding = false);
    }
  }

  void _toggleRecordPolyline() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _startPeriodicRecording();
    } else {
      _savingPolyline();
    }
  }

  void _startPeriodicRecording() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: _fetchIntervalSeconds), (
      timer,
    ) async {
      await _findMe();
      if (_me != null) {
        _addPoint(_me!);
      }
    });
  }

  void _setInterval(int seconds) {
    setState(() {
      _fetchIntervalSeconds = seconds;
    });

    if (_isRecording) {
      _startPeriodicRecording();
    }
  }

  void _addPoint(LatLng position) {
    setState(() => _points = [..._points, position]);
  }

  void _clearPoints() {
    setState(() => _points.clear());
  }

  Set<Polyline> _buildPolylines() {
    return {
      Polyline(
        polylineId: const PolylineId('walk_path'),
        color: Colors.teal,
        points: _points,
        width: 5,
      ),
    };
  }

  Future<void> _savingPolyline() async {
    _timer?.cancel();
    await _findMe();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => SaveRouteDialog(
        controller: _nameController,
        onSave: () async {
          String key = _nameController.text.trim();
          if (key.isNotEmpty && _me != null) {
            _addPoint(_me!);
            await LandmarkStorageService.saveLocationList(_points, key);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully saved as "$key"!')),
              );
            }
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final String currentSnippet = _me != null
        ? '${_me!.latitude}, ${_me!.longitude}'
        : 'Locating...';

    final Set<Marker> markers = {
      if (_me != null)
        Marker(
          markerId: const MarkerId('me'),
          position: _me!,
          infoWindow: InfoWindow(
            title: 'My Current Location',
            snippet: currentSnippet,
          ),
        ),
    };

    return Scaffold(
      body: Stack(
        children: [
          // Google Map View
          GoogleMap(
            initialCameraPosition: _cameraPosition,
            markers: markers,
            polylines: _buildPolylines(),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
          ),
          Column(
            children: [
              CustomAppBar(
                colorScheme: colorScheme,
                name: "Real-Time Location Tracker",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIntervalChip(
                            label: '5s',
                            seconds: 5,
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(width: 4),
                          _buildIntervalChip(
                            label: '10s',
                            seconds: 10,
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: colorScheme.outlineVariant, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isFinding ? null : _findMe,
                    child: _isFinding
                        ? SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Find Me',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                  ),

                  ElevatedButton(
                    onPressed: _toggleRecordPolyline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                    child: Text(
                      _isRecording
                          ? 'Stop (${_fetchIntervalSeconds}s)'
                          : 'Start Recording',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  ElevatedButton(
                    onPressed: _clearPoints,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalChip({
    required String label,
    required int seconds,
    required ColorScheme colorScheme,
  }) {
    final bool isSelected = _fetchIntervalSeconds == seconds;
    return GestureDetector(
      onTap: () => _setInterval(seconds),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
