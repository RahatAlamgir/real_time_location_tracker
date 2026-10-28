import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String routeName;

  const DeleteConfirmationDialog({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Icon(
        Icons.delete_outline_rounded,
        color: colorScheme.error,
        size: 28,
      ),
      title: const Text('Delete Route'),
      content: Text(
        'Are you sure you want to delete "$routeName"? This action cannot be undone.',
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
