import 'package:flutter/material.dart';

class SaveRouteDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const SaveRouteDialog({
    super.key,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Icon(
        Icons.bookmark_add_rounded,
        color: colorScheme.primary,
        size: 28,
      ),
      title: const Text('Save Route'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Enter route name (key)',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: onSave, child: const Text('Save')),
      ],
    );
  }
}
