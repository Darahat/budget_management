import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../salary/presentation/providers/salary_providers.dart';
import '../providers/budget_category_providers.dart';
import '../providers/budget_providers.dart';

class CreateBudgetPage extends ConsumerStatefulWidget {
  const CreateBudgetPage({super.key});

  @override
  ConsumerState<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends ConsumerState<CreateBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  bool _hasShownAlert = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _checkBudgetExceedsSalary(double currentTotal, double salary) {
    if (!_hasShownAlert && currentTotal > salary && salary > 0) {
      _hasShownAlert = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Flexible(child: Text('Budget Exceeds Salary')),
                ],
              ),
              content: Text(
                'Your total allocated budget (\$${currentTotal.toStringAsFixed(2)}) exceeds your monthly salary (\$${salary.toStringAsFixed(2)}).\n\n'
                'Please adjust your budgets or update your salary.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  Future<void> _createBudget() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      // Check if total budget would exceed salary
      final salaryState = ref.read(salaryProvider);
      final monthlySalary = salaryState.valueOrNull?.amount ?? 0.0;

      final budgetState = ref.read(budgetProvider);
      final currentTotalBudget =
          budgetState.valueOrNull?.fold<double>(
            0.0,
            (sum, budget) => sum + budget.allocatedAmount,
          ) ??
          0.0;

      final newTotal = currentTotalBudget + amount;

      if (newTotal > monthlySalary) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Total budget (\$${newTotal.toStringAsFixed(2)}) would exceed your monthly salary (\$${monthlySalary.toStringAsFixed(2)})',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      await ref
          .read(budgetProvider.notifier)
          .addBudget(category: _selectedCategory!, allocatedAmount: amount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);
    final salaryState = ref.watch(salaryProvider);
    final categoriesState = ref.watch(budgetCategoryProvider);

    final existingCategories =
        budgetState.whenOrNull(
          data: (budgets) =>
              budgets.map((b) => b.category.toLowerCase()).toSet(),
        ) ??
        <String>{};

    final currentTotalBudget =
        budgetState.whenOrNull(
          data: (budgets) => budgets.fold<double>(
            0.0,
            (sum, budget) => sum + budget.allocatedAmount,
          ),
        ) ??
        0.0;

    final monthlySalary = salaryState.valueOrNull?.amount ?? 0.0;
    final remainingBudget = monthlySalary - currentTotalBudget;

    return categoriesState.when(
      data: (categories) {
        final availableCategories = categories
            .where(
              (cat) => !existingCategories.contains(cat.name.toLowerCase()),
            )
            .map((cat) => cat.name)
            .toList();

        // Reset selected category if it's no longer available
        if (_selectedCategory != null &&
            !availableCategories.contains(_selectedCategory)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedCategory = null);
            }
          });
        }

        // Check if budgets exceed salary and show alert
        _checkBudgetExceedsSalary(currentTotalBudget, monthlySalary);

        return _buildScaffold(
          context,
          availableCategories,
          monthlySalary,
          currentTotalBudget,
          remainingBudget,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Create Budget')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Create Budget')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading categories: $error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(budgetCategoryProvider.notifier).loadCategories();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    List<String> availableCategories,
    double monthlySalary,
    double currentTotalBudget,
    double remainingBudget,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Budget')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Budget Status Card
                if (monthlySalary > 0)
                  Card(
                    color: remainingBudget < 0
                        ? Colors.red.shade50
                        : remainingBudget == 0
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget Status',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Monthly Salary:'),
                              Text(
                                '\$${monthlySalary.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Allocated:'),
                              Text(
                                '\$${currentTotalBudget.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: currentTotalBudget > monthlySalary
                                      ? Colors.red
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Remaining Budget:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${remainingBudget.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: remainingBudget < 0
                                      ? Colors.red
                                      : remainingBudget == 0
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: availableCategories.contains(_selectedCategory)
                      ? _selectedCategory
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                    helperText: 'Select a category for your budget',
                  ),
                  items: availableCategories.isEmpty
                      ? [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All categories are used'),
                          ),
                        ]
                      : availableCategories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                  onChanged: availableCategories.isEmpty
                      ? null
                      : (value) {
                          setState(() => _selectedCategory = value);
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Budget Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    helperText: 'Enter the allocated amount for this category',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (amount > remainingBudget) {
                      return 'Amount exceeds remaining budget (\$${remainingBudget.toStringAsFixed(2)})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createBudget,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Budget'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
