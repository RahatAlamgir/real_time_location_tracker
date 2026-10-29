import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:real_time_location_tracker/data/provider/app_status_provider.dart';
import 'package:real_time_location_tracker/data/service/init_position.dart';
import 'package:real_time_location_tracker/data/service/landmark_storage_service.dart';
import 'package:real_time_location_tracker/presentation/widget/custom_app_bar.dart';
import 'package:real_time_location_tracker/presentation/widget/interval_toggle_chip.dart';
import 'package:real_time_location_tracker/presentation/widget/save_route_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late CameraPosition _cameraPosition;
  GoogleMapController? _mapController;
  Timer? _timer;

  final TextEditingController _nameController = TextEditingController();

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
    final appStatusProvider = context.read<AppStatusProvider>();
    await appStatusProvider.autoUpdateMe();

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: appStatusProvider.me, zoom: 18),
        ),
      );
    }
  }

  void _toggleRecordPolyline() {
    final appStatusProvider = context.read<AppStatusProvider>();
    appStatusProvider.toggleIsRecording();

    if (appStatusProvider.isRecording) {
      _startPeriodicRecording();
    } else {
      _savingPolyline();
    }
  }

  void _startPeriodicRecording() {
    final appStatusProvider = context.read<AppStatusProvider>();
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: appStatusProvider.intervalSceonds),
      (timer) async {
        await _findMe();
        if (!mounted) return;
        appStatusProvider.addPoint();
      },
    );
  }

  Future<void> _savingPolyline() async {
    _timer?.cancel();

    showDialog(
      context: context,
      builder: (dialogContext) => SaveRouteDialog(
        controller: _nameController,
        onSave: () async {
          String key = _nameController.text.trim();
          if (key.isNotEmpty) {
            context.read<AppStatusProvider>().addPoint();
            await LandmarkStorageService.saveLocationList(
              context.read<AppStatusProvider>().points,
              key,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully saved as "$key"!')),
              );
            }
          }
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Consumer<AppStatusProvider>(
            builder: (context, provider, _) {
              return GoogleMap(
                initialCameraPosition: _cameraPosition,
                markers: provider.myMarkers,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('walk_path'),
                    color: Colors.teal,
                    points: provider.points,
                    width: 5,
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
              );
            },
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
                          IntervalToggleChip(
                            label: '5s',
                            seconds: 5,
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(width: 4),
                          IntervalToggleChip(
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
                  Consumer<AppStatusProvider>(
                    builder: (context, provider, _) {
                      return ElevatedButton(
                        onPressed: provider.isFinding ? null : _findMe,
                        child: provider.isFinding
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Find Me',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                      );
                    },
                  ),
                  Consumer<AppStatusProvider>(
                    builder: (context, provider, _) {
                      return ElevatedButton(
                        onPressed: _toggleRecordPolyline,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: provider.isRecording
                              ? colorScheme.error
                              : colorScheme.primary,
                        ),
                        child: Text(
                          provider.isRecording
                              ? 'Stop (${provider.intervalSceonds}s)'
                              : 'Start Recording',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AppStatusProvider>().clearPoint();
                    },
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
}
