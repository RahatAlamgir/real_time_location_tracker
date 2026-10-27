import 'package:flutter/material.dart';

class SavedMap extends StatelessWidget {
  const SavedMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, builder) {
          return Card(child: ListTile(title: Text("data")));
        },
      ),
    );
  }
}
