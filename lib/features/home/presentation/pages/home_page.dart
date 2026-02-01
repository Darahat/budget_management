import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/month_selector.dart';
import '../../../budget/presentation/pages/budget_categories_page.dart';
import '../../../budget/presentation/pages/create_budget_page.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../budget/presentation/widgets/budget_list.dart';
import '../../../salary/presentation/pages/set_salary_page.dart';
import '../../../salary/presentation/providers/salary_providers.dart';
import '../../../salary/presentation/widgets/salary_card.dart';
import '../../../settings/presentation/pages/currency_settings_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaryState = ref.watch(salaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Manager'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == 'salary') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SetSalaryPage(),
                  ),
                );
              } else if (value == 'currency') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CurrencySettingsPage(),
                  ),
                );
              } else if (value == 'categories') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BudgetCategoriesPage(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'salary',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 20),
                    SizedBox(width: 12),
                    Text('Salary Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'currency',
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 20),
                    SizedBox(width: 12),
                    Text('Currency Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category, size: 20),
                    SizedBox(width: 12),
                    Text('Manage Categories'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: salaryState.when(
        data: (salary) {
          if (salary == null) {
            return const _NoSalaryView();
          }
          return const _MainView();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: salaryState.maybeWhen(
        data: (salary) => salary != null
            ? FloatingActionButton(
                heroTag: 'add_budget',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateBudgetPage(),
                    ),
                  );
                },
                tooltip: 'Create Budget',
                child: const Icon(Icons.add),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

class _NoSalaryView extends StatelessWidget {
  const _NoSalaryView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Budget Manager',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Set your monthly salary to get started',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SetSalaryPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Set Monthly Salary'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainView extends ConsumerWidget {
  const _MainView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(salaryProvider);
        ref.invalidate(budgetProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          MonthSelector(),
          SizedBox(height: 12),
          SalaryCard(),
          SizedBox(height: 20),
          BudgetList(),
        ],
      ),
    );
  }
}
