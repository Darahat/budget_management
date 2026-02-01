import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

/// Implementation of BudgetRepository
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Budget>> getBudgets(int month, int year) async {
    final models = await localDataSource.getBudgets();
    return models
        .where((m) => m.month == month && m.year == year)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Budget>> getAllBudgets() async {
    final models = await localDataSource.getBudgets();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final budgets = await getAllBudgets();
    try {
      return budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    final budgets = List<Budget>.from(await getAllBudgets());
    budgets.add(budget);
    final models = budgets.map((b) => BudgetModel.fromEntity(b)).toList();
    await localDataSource.saveBudgets(models);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final budgets = List<Budget>.from(await getAllBudgets());
    final index = budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      budgets[index] = budget;
      final models = budgets.map((b) => BudgetModel.fromEntity(b)).toList();
      await localDataSource.saveBudgets(models);
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    final budgets = List<Budget>.from(await getAllBudgets());
    budgets.removeWhere((budget) => budget.id == id);
    final models = budgets.map((b) => BudgetModel.fromEntity(b)).toList();
    await localDataSource.saveBudgets(models);
  }

  @override
  Future<void> deleteAllBudgets() async {
    await localDataSource.deleteBudgets();
  }

  @override
  Future<double> getTotalAllocatedAmount(int month, int year) async {
    final budgets = await getBudgets(month, year);
    return budgets.fold<double>(
      0.0,
      (sum, budget) => sum + budget.allocatedAmount,
    );
  }
}
