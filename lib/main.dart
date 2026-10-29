import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_location_tracker/data/provider/app_status_provider.dart';
import 'package:real_time_location_tracker/my_app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppStatusProvider(),
      child: const MyApp(),
    ),
  );
}
