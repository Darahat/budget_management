import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../providers/salary_providers.dart';

class SalaryCard extends ConsumerWidget {
  const SalaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaryState = ref.watch(salaryProvider);

    return salaryState.when(
      data: (salary) {
        if (salary == null) return const SizedBox.shrink();

        final spentAmount = salary.amount - salary.remaining;
        final spentPercentage = (spentAmount / salary.amount) * 100;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Salary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Icon(
                      Icons.account_balance_wallet,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  CurrencyFormatter.format(salary.amount),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoColumn(
                      label: 'Remaining',
                      value: CurrencyFormatter.format(salary.remaining),
                      color: Colors.green,
                    ),
                    _InfoColumn(
                      label: 'Spent',
                      value: CurrencyFormatter.format(spentAmount),
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: spentPercentage / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      spentPercentage > 90
                          ? Colors.red
                          : spentPercentage > 70
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${spentPercentage.toStringAsFixed(1)}% spent',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
