import 'package:flutter/material.dart';
import 'package:real_time_location_tracker/data/service/landmark_storage_service.dart';
import 'package:real_time_location_tracker/model/landmark.dart';
import 'package:real_time_location_tracker/screen/load_map.dart';

class SavedMap extends StatefulWidget {
  const SavedMap({super.key});

  @override
  State<SavedMap> createState() => _SavedMapState();
}

class _SavedMapState extends State<SavedMap> {
  List<String> allKeyName = [];

  Future<void> _getAllKeyName() async {
    final allkeys = await LandmarkStorageService.getAllKeys();
    setState(() {
      allKeyName = allkeys;
    });
  }

  @override
  void initState() {
    _getAllKeyName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("List of Saved Map")),
      body: ListView.builder(
        itemCount: allKeyName.length,

        itemBuilder: (context, index) {
          String name = allKeyName[index];
          return Card(
            child: ListTile(
              title: Text(name),
              onTap: () {
                print(name);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoadMap(name: name)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
