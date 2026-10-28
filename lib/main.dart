import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:real_time_location_tracker/data/service/landmark_probider.dart';
import 'package:real_time_location_tracker/screen/home_page.dart';

void main() {
  runApp(
    // ChangeNotifierProvider(
    //   create: (context) => LandmarkProvider(),
    //   child:
    const MyApp(),
    // ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomePage(),
    );
  }
}
