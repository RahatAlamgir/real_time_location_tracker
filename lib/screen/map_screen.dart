import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/data/init_position.dart';
import 'package:real_time_location_tracker/data/service/landmark_storage_service.dart';
import 'package:real_time_location_tracker/data/widget/save_route_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late CameraPosition cameraPosition;
  GoogleMapController? _map;
  Timer? timer;
  int fatchIntervalTimer = 5;
  LatLng? _me;
  bool finding = false;
  bool recording = false;

  final TextEditingController _nameController = TextEditingController();

  List<LatLng> _points = [];

  Future<void> _findMe() async {
    setState(() {
      finding = true;
    });

    final Position? position = await InitPosition.getPosition();
    if (position != null) {
      setState(() {
        _me = LatLng(position.latitude, position.longitude);
        finding = false;
      });
      if (mounted) {
        _map?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _me!, zoom: 18),
          ),
        );
      }
    } else {
      setState(() {
        finding = false;
      });
    }
  }

  void _recordPolyline() {
    setState(() {
      recording = !recording;
    });
    if (recording) {
      _recordingPolyline();
    } else {
      _savingPolyline();
    }
  }

  void _recordingPolyline() {
    timer = Timer.periodic(Duration(seconds: fatchIntervalTimer), (timer) {
      print("10 seconds passed! Fetching location...");
      _findMe();

      _addPoint(_me!);
    });
  }

  void _addPoint(LatLng position) {
    setState(() => _points = [..._points, position]);
  }

  void _clearPoints() {
    setState(() {
      _points.clear();
    });
  }

  Set<Polyline> _lines() {
    return {
      Polyline(
        polylineId: PolylineId('walk'),
        color: Colors.teal,
        points: _points,
        width: 5,
      ),
    };
  }

  Future<void> savingPolyline() async {
    bool lastLocation = false;

    if (timer!.isActive) {
      timer!.cancel();
    }

    _findMe();

    if (mounted) {
      lastLocation = true;
    }

    showDialog(
      context: context,

      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Polyline'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Enter name (key)',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: !lastLocation
                  ? null
                  : () async {
                      String key = _nameController.text.trim();
                      if (key.isNotEmpty) {
                        _addPoint(_me!);
                        Navigator.of(context).pop();
                        await LandmarkStorageService.saveLocationList(
                          _points,
                          key,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Successfully saved as "$key"!'),
                          ),
                        );
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savingPolyline() async {
    bool lastLocation = false;

    if (timer!.isActive) {
      timer!.cancel();
    }
    _findMe();

    if (mounted) {
      lastLocation = true;
    }

    showDialog(
      context: context,
      builder: (context) => SaveRouteDialog(
        controller: _nameController,
        onSave: () async {
          String key = _nameController.text.trim();
          if (key.isNotEmpty) {
            _addPoint(_me!);
            await LandmarkStorageService.saveLocationList(_points, key);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Successfully saved as "$key"!')),
            );
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    cameraPosition = InitPosition.openingCamera;
    _findMe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = {
      if (_me != null)
        Marker(
          markerId: const MarkerId('me'),
          position: _me!,
          infoWindow: const InfoWindow(title: 'Me'),
          flat: true,
        ),
    };
    return Scaffold(
      appBar: AppBar(title: Text("Read-Time-Location-Tracker")),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: cameraPosition,
                markers: markers,
                polylines: _lines(),
                onMapCreated: (controller) => _map = controller,
              ),
            ),
            Wrap(
              children: [
                ElevatedButton(
                  onPressed: finding ? null : _findMe,
                  child: Text(finding ? 'Finding' : 'Find me'),
                ),

                ElevatedButton(
                  onPressed: _recordPolyline,
                  child: Text(recording ? 'Stop Recording' : 'Start Recording'),
                ),
                ElevatedButton(onPressed: _clearPoints, child: Text('clear')),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
