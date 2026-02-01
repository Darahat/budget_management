import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../budget/domain/entities/budget.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../providers/expense_providers.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  final Budget? preSelectedBudget;

  const AddExpensePage({super.key, this.preSelectedBudget});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedBudgetId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedBudget != null) {
      _selectedBudgetId = widget.preSelectedBudget!.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBudgetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a budget'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      await ref
          .read(expenseProvider.notifier)
          .createExpense(
            budgetId: _selectedBudgetId!,
            amount: amount,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
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
    final isPreSelected = widget.preSelectedBudget != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPreSelected
              ? 'Add Expense - ${widget.preSelectedBudget!.category}'
              : 'Add Expense',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isPreSelected)
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.preSelectedBudget!.category,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Budget: ₹${widget.preSelectedBudget!.allocatedAmount.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Remaining: ₹${widget.preSelectedBudget!.remainingAmount.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color:
                                      widget
                                              .preSelectedBudget!
                                              .remainingAmount >
                                          0
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!isPreSelected)
                  budgetState.when(
                    data: (budgets) {
                      if (budgets.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.info,
                                  color: Colors.orange,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No budgets available',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create a budget first to add expenses',
                                  style: TextStyle(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedBudgetId,
                        decoration: const InputDecoration(
                          labelText: 'Select Budget',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: budgets.map((budget) {
                          return DropdownMenuItem(
                            value: budget.id,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    budget.category,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  ' (₹${budget.remainingAmount.toStringAsFixed(0)})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: budgets.isEmpty
                            ? null
                            : (value) {
                                setState(() => _selectedBudgetId = value);
                              },
                        validator: (value) {
                          if (value == null && budgets.isNotEmpty) {
                            return 'Please select a budget';
                          }
                          return null;
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
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
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: 'E.g., Grocery shopping, Taxi fare',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addExpense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
