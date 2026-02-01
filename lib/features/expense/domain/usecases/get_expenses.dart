import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for getting all expenses
class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses({required this.repository});

  Future<List<Expense>> call(int month, int year) async {
    final expenses = await repository.getExpenses(month, year);
    // Sort by created date, newest first
    expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return expenses;
  }
}
