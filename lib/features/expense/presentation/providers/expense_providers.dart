import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/month_selection_provider.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../salary/presentation/providers/salary_providers.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';

// Data source provider
final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return ExpenseLocalDataSource(sharedPreferences: sharedPreferences);
});

// Repository provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final localDataSource = ref.watch(expenseLocalDataSourceProvider);
  return ExpenseRepositoryImpl(localDataSource: localDataSource);
});

// Use case providers
final getExpensesUseCaseProvider = Provider<GetExpenses>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return GetExpenses(repository: repository);
});

final addExpenseUseCaseProvider = Provider<AddExpense>((ref) {
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final budgetRepository = ref.watch(budgetRepositoryProvider);
  final salaryRepository = ref.watch(salaryRepositoryProvider);
  return AddExpense(
    expenseRepository: expenseRepository,
    budgetRepository: budgetRepository,
    salaryRepository: salaryRepository,
  );
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpense>((ref) {
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final budgetRepository = ref.watch(budgetRepositoryProvider);
  final salaryRepository = ref.watch(salaryRepositoryProvider);
  return DeleteExpense(
    expenseRepository: expenseRepository,
    budgetRepository: budgetRepository,
    salaryRepository: salaryRepository,
  );
});

final updateExpenseUseCaseProvider = Provider<UpdateExpense>((ref) {
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final budgetRepository = ref.watch(budgetRepositoryProvider);
  final salaryRepository = ref.watch(salaryRepositoryProvider);
  return UpdateExpense(
    expenseRepository: expenseRepository,
    budgetRepository: budgetRepository,
    salaryRepository: salaryRepository,
  );
});

// Expense state provider
final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
      final getExpenses = ref.watch(getExpensesUseCaseProvider);
      final addExpense = ref.watch(addExpenseUseCaseProvider);
      final deleteExpense = ref.watch(deleteExpenseUseCaseProvider);
      final updateExpense = ref.watch(updateExpenseUseCaseProvider);
      final budgetNotifier = ref.watch(budgetProvider.notifier);
      final salaryNotifier = ref.watch(salaryProvider.notifier);
      // Watch month selection to trigger rebuilds
      ref.watch(monthSelectionProvider);
      return ExpenseNotifier(
        getExpenses: getExpenses,
        addExpense: addExpense,
        deleteExpense: deleteExpense,
        updateExpense: updateExpense,
        budgetNotifier: budgetNotifier,
        salaryNotifier: salaryNotifier,
        ref: ref,
      );
    });

/// Notifier for managing expense state
class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final DeleteExpense deleteExpense;
  final UpdateExpense updateExpense;
  final BudgetNotifier budgetNotifier;
  final SalaryNotifier salaryNotifier;
  final Ref ref;

  ExpenseNotifier({
    required this.getExpenses,
    required this.addExpense,
    required this.deleteExpense,
    required this.updateExpense,
    required this.budgetNotifier,
    required this.salaryNotifier,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadExpenses();
    // Listen to month selection changes
    ref.listen(monthSelectionProvider, (previous, next) {
      loadExpenses();
    });
  }

  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final monthYear = ref.read(monthSelectionProvider);
      final expenses = await getExpenses(monthYear.month, monthYear.year);
      state = AsyncValue.data(expenses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createExpense({
    required String budgetId,
    required double amount,
    String? description,
  }) async {
    try {
      final monthYear = ref.read(monthSelectionProvider);
      await addExpense(
        budgetId: budgetId,
        amount: amount,
        month: monthYear.month,
        year: monthYear.year,
        description: description,
      );
      await loadExpenses();
      await budgetNotifier.loadBudgets(); // Refresh budgets
      await salaryNotifier.loadSalary(); // Refresh salary
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> removeExpense(Expense expense) async {
    try {
      await deleteExpense(
        expenseId: expense.id,
        budgetId: expense.budgetId,
        amount: expense.amount,
        month: expense.month,
        year: expense.year,
      );
      await loadExpenses();
      await budgetNotifier.loadBudgets(); // Refresh budgets
      await salaryNotifier.loadSalary(); // Refresh salary
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> modifyExpense({
    required Expense oldExpense,
    required String newBudgetId,
    required double newAmount,
    String? newDescription,
  }) async {
    try {
      await updateExpense(
        oldExpense: oldExpense,
        newBudgetId: newBudgetId,
        newAmount: newAmount,
        newDescription: newDescription,
      );
      await loadExpenses();
      await budgetNotifier.loadBudgets(); // Refresh budgets
      await salaryNotifier.loadSalary(); // Refresh salary
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
