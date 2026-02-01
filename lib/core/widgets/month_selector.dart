import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/month_selection_provider.dart';

/// Widget for selecting and navigating between months
class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthYear = ref.watch(monthSelectionProvider);
    final notifier = ref.read(monthSelectionProvider.notifier);

    // Format the month/year for display
    final dateFormat = DateFormat('MMMM yyyy');
    final displayDate = DateTime(monthYear.year, monthYear.month);
    final displayText = dateFormat.format(displayDate);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => notifier.previousMonth(),
              tooltip: 'Previous Month',
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    displayText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => notifier.goToCurrentMonth(),
                    child: const Text('Go to Current Month'),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => notifier.nextMonth(),
              tooltip: 'Next Month',
            ),
          ],
        ),
      ),
    );
  }
}
