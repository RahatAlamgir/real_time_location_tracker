import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/data/init_position.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late CameraPosition cameraPosition;
  GoogleMapController? _map;
  LatLng? _me;
  bool finding = false;

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

  Set<Polyline> _lines() {
    return {
      Polyline(
        polylineId: PolylineId('walk'),
        color: Colors.teal,
        points: InitPosition.testPathRoute,
        width: 5,
      ),
    };
  }

  @override
  void initState() {
    cameraPosition = InitPosition.openingCamera;
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
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
