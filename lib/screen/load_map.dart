import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/data/init_position.dart';
import 'package:real_time_location_tracker/data/service/landmark_storage_service.dart';

class LoadMap extends StatefulWidget {
  const LoadMap({super.key, required this.name});
  final String name;

  @override
  State<LoadMap> createState() => _LoadMapState();
}

class _LoadMapState extends State<LoadMap> {
  List<LatLng> _point = [];
  GoogleMapController? _map;

  CameraPosition cameraPosition = InitPosition.openingCamera;

  Future<void> _loadPolyline() async {
    final _route = await LandmarkStorageService.getLocationList(widget.name);

    if (mounted) {
      setState(() {
        _point = _route;
      });
    }
    updateCamaraPosition();
  }

  void updateCamaraPosition() {
    if (_point.isEmpty || _map == null) return;

    final LatLng target = _point.first;

    _map!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 18)),
    );
  }

  Set<Polyline> _lines() {
    if (_point.isEmpty) return {};
    return {
      Polyline(
        polylineId: PolylineId(widget.name),
        color: Colors.teal,
        points: _point,
        width: 5,
      ),
    };
  }

  Set<Marker> _markers() {
    if (_point.isEmpty) return {};
    LatLng start = _point.first;
    LatLng end = _point.last;
    return {
      InitPosition.huePin(
        start,
        id: "start_point",
        name: "start point",
        fact: "${start.latitude}, ${start.longitude}",
        hue: BitmapDescriptor.hueBlue,
      ),
      InitPosition.huePin(
        end,
        id: "end_point",
        name: 'end point',
        fact: "${end.latitude}, ${end.longitude}",
        hue: BitmapDescriptor.hueGreen,
      ),
    };
  }

  @override
  void initState() {
    _loadPolyline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: cameraPosition,
                polylines: _lines(),
                markers: _markers(),
                onMapCreated: (controller) {
                  _map = controller;
                  updateCamaraPosition();
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _loadPolyline();
              },
              child: Text("reload"),
            ),
          ],
        ),
      ),
    );
  }
}
