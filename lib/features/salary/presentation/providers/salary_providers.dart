import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/month_selection_provider.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../expense/presentation/providers/expense_providers.dart';
import '../../data/datasources/salary_local_datasource.dart';
import '../../data/repositories/salary_repository_impl.dart';
import '../../domain/entities/salary.dart';
import '../../domain/repositories/salary_repository.dart';
import '../../domain/usecases/get_salary.dart';
import '../../domain/usecases/set_monthly_salary.dart';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

// Data source provider
final salaryLocalDataSourceProvider = Provider<SalaryLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return SalaryLocalDataSource(sharedPreferences: sharedPreferences);
});

// Repository provider
final salaryRepositoryProvider = Provider<SalaryRepository>((ref) {
  final localDataSource = ref.watch(salaryLocalDataSourceProvider);
  return SalaryRepositoryImpl(localDataSource: localDataSource);
});

// Use case providers
final getSalaryUseCaseProvider = Provider<GetSalary>((ref) {
  final repository = ref.watch(salaryRepositoryProvider);
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  return GetSalary(
    repository: repository,
    expenseRepository: expenseRepository,
  );
});

final setMonthlySalaryUseCaseProvider = Provider<SetMonthlySalary>((ref) {
  final repository = ref.watch(salaryRepositoryProvider);
  final budgetRepository = ref.watch(budgetRepositoryProvider);
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  return SetMonthlySalary(
    repository: repository,
    budgetRepository: budgetRepository,
    expenseRepository: expenseRepository,
  );
});

// Salary state provider
final salaryProvider =
    StateNotifierProvider<SalaryNotifier, AsyncValue<Salary?>>((ref) {
      final getSalary = ref.watch(getSalaryUseCaseProvider);
      final setSalary = ref.watch(setMonthlySalaryUseCaseProvider);
      // Watch month selection to trigger rebuilds
      ref.watch(monthSelectionProvider);
      return SalaryNotifier(
        getSalary: getSalary,
        setSalary: setSalary,
        ref: ref,
      );
    });

/// Notifier for managing salary state
class SalaryNotifier extends StateNotifier<AsyncValue<Salary?>> {
  final GetSalary getSalary;
  final SetMonthlySalary setSalary;
  final Ref ref;

  SalaryNotifier({
    required this.getSalary,
    required this.setSalary,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadSalary();
    // Listen to month selection changes
    ref.listen(monthSelectionProvider, (previous, next) {
      loadSalary();
    });
  }

  Future<void> loadSalary() async {
    state = const AsyncValue.loading();
    try {
      final monthYear = ref.read(monthSelectionProvider);
      final salary = await getSalary(monthYear.month, monthYear.year);
      state = AsyncValue.data(salary);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> setMonthlySalary(double amount) async {
    try {
      final monthYear = ref.read(monthSelectionProvider);
      await setSalary(
        amount: amount,
        month: monthYear.month,
        year: monthYear.year,
      );
      await loadSalary();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
