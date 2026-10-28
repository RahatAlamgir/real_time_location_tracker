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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 2,
          titleTextStyle: TextStyle(
            fontWeight: .bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),

        dividerTheme: DividerThemeData(thickness: 0.8),

        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        // Consistent M3 Button Shapes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 231, 237, 234),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
