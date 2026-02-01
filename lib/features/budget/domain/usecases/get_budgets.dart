import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

/// Use case for getting all budgets for a specific month/year
class GetBudgets {
  final BudgetRepository repository;

  GetBudgets({required this.repository});

  Future<List<Budget>> call(int month, int year) async {
    final budgets = await repository.getBudgets(month, year);

    // Separate exhausted and active budgets
    final activeBudgets = budgets.where((b) => !b.isExhausted).toList();
    final exhaustedBudgets = budgets.where((b) => b.isExhausted).toList();

    // Return active budgets first, then exhausted budgets at the bottom
    return [...activeBudgets, ...exhaustedBudgets];
  }
}
