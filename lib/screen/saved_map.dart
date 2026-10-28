import 'package:flutter/material.dart';
import 'package:real_time_location_tracker/data/service/landmark_storage_service.dart';
import 'package:real_time_location_tracker/data/widget/delete_confirmation_dialog.dart';
import 'package:real_time_location_tracker/screen/load_map.dart';

class SavedMap extends StatefulWidget {
  const SavedMap({super.key});

  @override
  State<SavedMap> createState() => SavedMapState();
}

class SavedMapState extends State<SavedMap> {
  List<String> allKeyName = [];

  Future<void> _getAllKeyName() async {
    final allkeys = await LandmarkStorageService.getAllKeys();
    setState(() {
      allKeyName = allkeys;
    });
  }

  @override
  void initState() {
    super.initState();
    _getAllKeyName();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Routes")),
      body: allKeyName.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: colorScheme.outline.withValues(alpha: .5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No saved routes yet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ListView.builder(
                itemCount: allKeyName.length,
                itemBuilder: (context, index) {
                  String name = allKeyName[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoadMap(name: name),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.alt_route_rounded,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),

                            trailing: IconButton(
                              onPressed: () async {
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) =>
                                      DeleteConfirmationDialog(routeName: name),
                                );

                                if (confirm == true) {
                                  LandmarkStorageService.removeLocationList(
                                    name,
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: colorScheme.error,
                              ),
                              tooltip: 'Delete route',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
