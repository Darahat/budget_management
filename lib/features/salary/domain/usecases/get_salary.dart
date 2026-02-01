import '../../../expense/domain/repositories/expense_repository.dart';
import '../entities/salary.dart';
import '../repositories/salary_repository.dart';

/// Use case for getting salary
class GetSalary {
  final SalaryRepository repository;
  final ExpenseRepository expenseRepository;

  GetSalary({required this.repository, required this.expenseRepository});

  Future<Salary?> call(int month, int year) async {
    final salary = await repository.getSalary(month, year);
    if (salary == null) return null;

    // Recalculate remaining based on actual expenses
    final expenses = await expenseRepository.getExpenses(month, year);
    final totalSpent = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    final remaining = salary.amount - totalSpent;

    // Return salary with updated remaining
    return salary.copyWith(remaining: remaining);
  }
}
