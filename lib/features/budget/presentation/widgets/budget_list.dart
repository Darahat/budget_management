import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../expense/presentation/pages/add_expense_page.dart';
import '../../domain/entities/budget.dart';
import '../pages/edit_budget_page.dart';
import '../providers/budget_providers.dart';

class BudgetList extends ConsumerWidget {
  const BudgetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budgets',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (budgetState.maybeWhen(
                data: (budgets) => budgets.length > 1,
                orElse: () => false,
              ))
                Row(
                  children: [
                    Icon(
                      Icons.drag_indicator,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Drag to reorder',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        budgetState.when(
          data: (budgets) {
            if (budgets.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.list_alt, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No budgets yet',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create a budget to start tracking your expenses',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                _onReorder(ref, budgets, oldIndex, newIndex);
              },
              children: budgets.asMap().entries.map((entry) {
                final budget = entry.value;
                final percentage = budget.spentPercentage;
                final isOverBudget = budget.isExhausted;

                return Card(
                  key: ValueKey(budget.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.drag_handle,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(budget.category),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  budget.category,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              CurrencyFormatter.format(budget.allocatedAmount),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ${CurrencyFormatter.format(budget.spentAmount)}',
                              style: TextStyle(
                                color: isOverBudget
                                    ? Colors.red
                                    : Colors.grey[700],
                                fontWeight: isOverBudget
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              'Remaining: ${CurrencyFormatter.format(budget.remainingAmount)}',
                              style: TextStyle(
                                color: budget.remainingAmount <= 0
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage >= 100
                                  ? Colors.red
                                  : percentage > 80
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${percentage.toStringAsFixed(1)}% used',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: () => _addExpense(context, budget),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Expense'),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () =>
                                      _editBudget(context, ref, budget),
                                  tooltip: 'Edit',
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () =>
                                      _deleteBudget(context, ref, budget),
                                  tooltip: 'Delete',
                                  visualDensity: VisualDensity.compact,
                                  color: Colors.red[700],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: $error'),
            ),
          ),
        ),
      ],
    );
  }

  void _onReorder(
    WidgetRef ref,
    List<Budget> budgets,
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final reorderedBudgets = List<Budget>.from(budgets);
    final item = reorderedBudgets.removeAt(oldIndex);
    reorderedBudgets.insert(newIndex, item);

    ref.read(budgetProvider.notifier).reorderBudgets(reorderedBudgets);
  }

  void _addExpense(BuildContext context, Budget budget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpensePage(preSelectedBudget: budget),
      ),
    );
  }

  void _editBudget(BuildContext context, WidgetRef ref, Budget budget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBudgetPage(budget: budget)),
    );
  }

  Future<void> _deleteBudget(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete the "${budget.category}" budget?\n\n'
          'This will remove all tracking for this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ref.read(budgetProvider.notifier).deleteBudget(budget.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${budget.category} budget deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting budget: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'internet ':
        return Icons.wifi;
      case 'bua bill':
        return Icons.receipt_long;
      case 'bow':
        return Icons.card_giftcard;
      case 'savings':
        return Icons.savings;
      case 'health':
        return Icons.local_hospital;
      case 'my expense':
        return Icons.account_balance_wallet;
      case 'education':
        return Icons.school;
      case 'social activity':
        return Icons.people;
      case 'fun':
        return Icons.celebration;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'food':
        return Icons.restaurant;
      case 'other':
        return Icons.category;
      default:
        return Icons.category;
    }
  }
}
