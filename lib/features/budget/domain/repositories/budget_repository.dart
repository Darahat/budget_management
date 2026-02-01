import '../entities/budget.dart';

/// Repository interface for budget operations
abstract class BudgetRepository {
  Future<List<Budget>> getBudgets(int month, int year);
  Future<List<Budget>> getAllBudgets();
  Future<Budget?> getBudgetById(String id);
  Future<void> saveBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
  Future<void> deleteAllBudgets();
  Future<double> getTotalAllocatedAmount(int month, int year);
}
