import '../../../budget/domain/repositories/budget_repository.dart';
import '../../../salary/domain/repositories/salary_repository.dart';
import '../repositories/expense_repository.dart';

/// Use case for deleting an expense
class DeleteExpense {
  final ExpenseRepository expenseRepository;
  final BudgetRepository budgetRepository;
  final SalaryRepository salaryRepository;

  DeleteExpense({
    required this.expenseRepository,
    required this.budgetRepository,
    required this.salaryRepository,
  });

  Future<void> call({
    required String expenseId,
    required String budgetId,
    required double amount,
    required int month,
    required int year,
  }) async {
    // Delete the expense
    await expenseRepository.deleteExpense(expenseId);

    // Update budget spent amount
    final budget = await budgetRepository.getBudgetById(budgetId);
    if (budget != null) {
      final updatedBudget = budget.copyWith(
        spentAmount: budget.spentAmount - amount,
      );
      await budgetRepository.updateBudget(updatedBudget);
    }

    // Update salary remaining
    final salary = await salaryRepository.getSalary(month, year);
    if (salary != null) {
      final updatedSalary = salary.copyWith(
        remaining: salary.remaining + amount,
      );
      await salaryRepository.saveSalary(updatedSalary);
    }
  }
}
