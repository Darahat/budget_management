import '../../../budget/domain/repositories/budget_repository.dart';
import '../../../expense/domain/repositories/expense_repository.dart';
import '../entities/salary.dart';
import '../repositories/salary_repository.dart';

/// Use case for setting monthly salary
class SetMonthlySalary {
  final SalaryRepository repository;
  final BudgetRepository budgetRepository;
  final ExpenseRepository expenseRepository;

  SetMonthlySalary({
    required this.repository,
    required this.budgetRepository,
    required this.expenseRepository,
  });

  Future<void> call({
    required double amount,
    required int month,
    required int year,
  }) async {
    if (amount < 0) {
      throw ArgumentError('Salary amount cannot be negative');
    }

    // Get actual spent amount from expenses
    final expenses = await expenseRepository.getExpenses(month, year);
    final totalSpent = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Calculate remaining based on actual spending
    final remaining = amount - totalSpent;

    final salary = Salary(
      amount: amount,
      remaining: remaining,
      month: month,
      year: year,
      updatedAt: DateTime.now(),
    );

    await repository.saveSalary(salary);
  }
}
