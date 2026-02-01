import '../entities/expense.dart';

/// Repository interface for expense operations
abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses(int month, int year);
  Future<List<Expense>> getExpensesByBudgetId(
    String budgetId,
    int month,
    int year,
  );
  Future<List<Expense>> getAllExpenses(); // All months/years
  Future<void> saveExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> deleteExpensesByBudgetId(String budgetId);
  Future<void> deleteAllExpenses();
}
