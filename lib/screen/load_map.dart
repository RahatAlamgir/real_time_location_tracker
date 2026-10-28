import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/data/service/init_position.dart';
import 'package:real_time_location_tracker/data/service/landmark_storage_service.dart';
import 'package:real_time_location_tracker/data/widget/custom_app_bar.dart';
import 'package:real_time_location_tracker/data/widget/load_map_matrix_point.dart';

class LoadMap extends StatefulWidget {
  const LoadMap({super.key, required this.name});
  final String name;

  @override
  State<LoadMap> createState() => _LoadMapState();
}

class _LoadMapState extends State<LoadMap> {
  List<LatLng> _points = [];
  GoogleMapController? _mapController;
  bool _isLoading = true;

  final CameraPosition _initialCameraPosition = InitPosition.openingCamera;

  @override
  void initState() {
    super.initState();
    _loadPolyline();
  }

  Future<void> _loadPolyline() async {
    setState(() => _isLoading = true);
    final routePoints = await LandmarkStorageService.getLocationList(
      widget.name,
    );

    if (mounted) {
      setState(() {
        _points = routePoints;
        _isLoading = false;
      });
      _updateCameraPosition();
    }
  }

  void _updateCameraPosition() {
    if (_points.isEmpty || _mapController == null) return;
    final LatLng target = _points.first;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 18)),
    );
  }

  double _calculateTotalDistanceInKm() {
    if (_points.length < 2) return 0.0;
    double totalMeters = 0.0;
    for (int i = 0; i < _points.length - 1; i++) {
      totalMeters += Geolocator.distanceBetween(
        _points[i].latitude,
        _points[i].longitude,
        _points[i + 1].latitude,
        _points[i + 1].longitude,
      );
    }
    return totalMeters / 1000.0;
  }

  Set<Polyline> _buildPolylines() {
    if (_points.isEmpty) return {};
    return {
      Polyline(
        polylineId: PolylineId(widget.name),
        color: Colors.teal,
        points: _points,
        width: 5,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    if (_points.isEmpty) return {};
    final LatLng start = _points.first;
    final LatLng end = _points.last;
    return {
      InitPosition.huePin(
        start,
        id: "start_point",
        name: "Start Point",
        fact:
            "${start.latitude.toStringAsFixed(4)}, ${start.longitude.toStringAsFixed(4)}",
        hue: BitmapDescriptor.hueBlue,
      ),
      InitPosition.huePin(
        end,
        id: "end_point",
        name: 'End Point',
        fact:
            "${end.latitude.toStringAsFixed(4)}, ${end.longitude.toStringAsFixed(4)}",
        hue: BitmapDescriptor.hueGreen,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            polylines: _buildPolylines(),
            markers: _buildMarkers(),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _updateCameraPosition();
            },
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),

          CustomAppBar(colorScheme: colorScheme, name: widget.name),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: colorScheme.outlineVariant, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ROUTE METRICS",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.outline,
                          letterSpacing: 1,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          backgroundColor: colorScheme.primaryContainer
                              .withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _loadPolyline,
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        label: Text(
                          "Reload",
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Coordinates",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${_points.length}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Distance",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${_calculateTotalDistanceInKm().toStringAsFixed(2)} km",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_points.isNotEmpty) ...[
                    LoadMapMatrixPoint(
                      label: "Start Point:",
                      latLng: _points.first,
                      dotColor: Colors.blue,
                    ),
                    const SizedBox(height: 6),
                    LoadMapMatrixPoint(
                      label: "End Point:",
                      latLng: _points.last,
                      dotColor: Colors.green,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
