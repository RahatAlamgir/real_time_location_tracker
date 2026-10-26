import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_location_tracker/data/init.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Read-Time-Location-Tracker")),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: GoogleMap(initialCameraPosition: Init.openingCamera),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
