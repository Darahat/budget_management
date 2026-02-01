import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/month_selection_provider.dart';
import '../../../expense/presentation/providers/expense_providers.dart';
import '../../../salary/presentation/providers/salary_providers.dart';
import '../../data/datasources/budget_local_datasource.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/get_budgets.dart';

// Data source provider
final budgetLocalDataSourceProvider = Provider<BudgetLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return BudgetLocalDataSource(sharedPreferences: sharedPreferences);
});

// Repository provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final localDataSource = ref.watch(budgetLocalDataSourceProvider);
  return BudgetRepositoryImpl(localDataSource: localDataSource);
});

// Use case providers
final getBudgetsUseCaseProvider = Provider<GetBudgets>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return GetBudgets(repository: repository);
});

final createBudgetUseCaseProvider = Provider<CreateBudget>((ref) {
  final budgetRepository = ref.watch(budgetRepositoryProvider);
  final salaryRepository = ref.watch(salaryRepositoryProvider);
  return CreateBudget(
    budgetRepository: budgetRepository,
    salaryRepository: salaryRepository,
  );
});

// Budget state provider
final budgetProvider =
    StateNotifierProvider<BudgetNotifier, AsyncValue<List<Budget>>>((ref) {
      final getBudgets = ref.watch(getBudgetsUseCaseProvider);
      final createBudget = ref.watch(createBudgetUseCaseProvider);
      final salaryNotifier = ref.watch(salaryProvider.notifier);
      // Watch month selection to trigger rebuilds
      ref.watch(monthSelectionProvider);
      return BudgetNotifier(
        getBudgets: getBudgets,
        createBudget: createBudget,
        salaryNotifier: salaryNotifier,
        ref: ref,
      );
    });

/// Notifier for managing budget state
class BudgetNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  final GetBudgets getBudgets;
  final CreateBudget createBudget;
  final SalaryNotifier salaryNotifier;
  final Ref ref;

  BudgetNotifier({
    required this.getBudgets,
    required this.createBudget,
    required this.salaryNotifier,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadBudgets();
    // Listen to month selection changes
    ref.listen(monthSelectionProvider, (previous, next) {
      loadBudgets();
    });
  }

  Future<void> loadBudgets() async {
    state = const AsyncValue.loading();
    try {
      final monthYear = ref.read(monthSelectionProvider);
      final budgets = await getBudgets(monthYear.month, monthYear.year);
      state = AsyncValue.data(budgets);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addBudget({
    required String category,
    required double allocatedAmount,
  }) async {
    try {
      final monthYear = ref.read(monthSelectionProvider);
      await createBudget(
        category: category,
        allocatedAmount: allocatedAmount,
        month: monthYear.month,
        year: monthYear.year,
      );
      await loadBudgets();
      await salaryNotifier.loadSalary(); // Refresh salary
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      final repository = getBudgets.repository;
      await repository.updateBudget(budget);
      await loadBudgets();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      final repository = getBudgets.repository;

      // First, delete all expenses related to this budget
      final expenseRepository = ref.read(expenseRepositoryProvider);
      await expenseRepository.deleteExpensesByBudgetId(id);

      // Then delete the budget
      await repository.deleteBudget(id);

      // Refresh all data
      await loadBudgets();
      await salaryNotifier.loadSalary(); // Refresh salary

      // Refresh expenses list if it exists
      ref.invalidate(expenseProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> reorderBudgets(List<Budget> reorderedBudgets) async {
    try {
      // Optimistically update the UI
      state = AsyncValue.data(reorderedBudgets);

      // Save the new order to local storage
      final repository = getBudgets.repository;
      await repository.deleteAllBudgets();
      for (final budget in reorderedBudgets) {
        await repository.saveBudget(budget);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      // Reload budgets if saving fails
      await loadBudgets();
    }
  }
}
