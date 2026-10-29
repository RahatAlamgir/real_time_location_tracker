import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_location_tracker/data/provider/app_status_provider.dart';

class IntervalToggleChip extends StatelessWidget {
  const new({
    super.key,
    required this.label,
    required this.seconds,
    required this.colorScheme,
  });

  final String label;
  final int seconds;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStatusProvider>(
      builder: (context, provider, _) {
        final bool isSelected = provider.intervalSceonds == seconds;
        return GestureDetector(
          onTap: () => provider.setIntervalSeconds(seconds),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}
