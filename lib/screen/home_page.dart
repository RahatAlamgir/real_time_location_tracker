import 'package:flutter/material.dart';
import 'package:real_time_location_tracker/data/init_position.dart';
import 'package:real_time_location_tracker/data/widget/deshboard_card.dart';
import 'package:real_time_location_tracker/permission/permission.dart';

import 'package:real_time_location_tracker/screen/map_screen.dart';
import 'package:real_time_location_tracker/screen/saved_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool engineActive = false;

  Future<void> _getRequest() async {
    final permission = await Permission.hasLocationPermission();

    setState(() {
      engineActive = permission;
    });
  }

  @override
  void initState() {
    _getRequest();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard"),
            Text(
              'Real-time GPS tracking app',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Status Card
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: engineActive
                          ? Text(
                              'GPS Engine Active',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            )
                          : Text(
                              'GPS Permission denied',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to Track',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Record live paths or view saved routes instantly.',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section Label
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Navigation Cards Grid/List
            DashboardCard(
              title: 'Start Live Tracking',
              subtitle: 'Open map, record, and trace live routes',
              icon: Icons.map_rounded,
              colorScheme: colorScheme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            DashboardCard(
              title: 'Saved Routes',
              subtitle: 'Manage, view, and reload stored paths',
              icon: Icons.bookmark_rounded,
              colorScheme: colorScheme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedMap()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable M3 Action Card Component
