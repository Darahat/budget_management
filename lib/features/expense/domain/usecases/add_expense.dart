import 'package:uuid/uuid.dart';

import '../../../budget/domain/repositories/budget_repository.dart';
import '../../../salary/domain/repositories/salary_repository.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for adding an expense
class AddExpense {
  final ExpenseRepository expenseRepository;
  final BudgetRepository budgetRepository;
  final SalaryRepository salaryRepository;
  final Uuid uuid;

  AddExpense({
    required this.expenseRepository,
    required this.budgetRepository,
    required this.salaryRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<void> call({
    required String budgetId,
    required double amount,
    required int month,
    required int year,
    String? description,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Expense amount must be greater than 0');
    }

    // Get the budget for specific month/year
    final budget = await budgetRepository.getBudgetById(budgetId);
    if (budget == null) {
      throw StateError('Budget not found');
    }

    // Verify budget is for the same month/year
    if (budget.month != month || budget.year != year) {
      throw StateError('Budget does not match the selected month/year');
    }

    // Check if expense exceeds remaining budget
    final remainingBudget = budget.remainingAmount;
    if (amount > remainingBudget) {
      throw StateError(
        'Expense amount (\$$amount) exceeds remaining budget (\$$remainingBudget)',
      );
    }

    // Create and save expense
    final expense = Expense(
      id: uuid.v4(),
      budgetId: budgetId,
      budgetCategory: budget.category,
      amount: amount,
      description: description,
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );

    await expenseRepository.saveExpense(expense);

    // Update budget spent amount
    final updatedBudget = budget.copyWith(
      spentAmount: budget.spentAmount + amount,
    );
    await budgetRepository.updateBudget(updatedBudget);

    // Update salary remaining amount
    final salary = await salaryRepository.getSalary(month, year);
    if (salary != null) {
      final newRemaining = salary.remaining - amount;
      await salaryRepository.updateRemaining(month, year, newRemaining);
    }
  }
}
