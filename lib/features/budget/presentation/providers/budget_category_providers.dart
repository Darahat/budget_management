import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../salary/presentation/providers/salary_providers.dart';
import '../../data/datasources/budget_category_local_datasource.dart';
import '../../data/repositories/budget_category_repository_impl.dart';
import '../../domain/entities/budget_category.dart';
import '../../domain/repositories/budget_category_repository.dart';
import '../../domain/usecases/create_budget_category.dart';
import '../../domain/usecases/delete_budget_category.dart';
import '../../domain/usecases/get_budget_categories.dart';
import '../../domain/usecases/update_budget_category.dart';

// Data source provider
final budgetCategoryLocalDataSourceProvider =
    Provider<BudgetCategoryLocalDatasource>((ref) {
      final sharedPreferences = ref.watch(sharedPreferencesProvider);
      return BudgetCategoryLocalDatasource(sharedPreferences);
    });

// Repository provider
final budgetCategoryRepositoryProvider = Provider<BudgetCategoryRepository>((
  ref,
) {
  final localDataSource = ref.watch(budgetCategoryLocalDataSourceProvider);
  return BudgetCategoryRepositoryImpl(localDataSource);
});

// Use case providers
final getBudgetCategoriesUseCaseProvider = Provider<GetBudgetCategories>((ref) {
  final repository = ref.watch(budgetCategoryRepositoryProvider);
  return GetBudgetCategories(repository);
});

final createBudgetCategoryUseCaseProvider = Provider<CreateBudgetCategory>((
  ref,
) {
  final repository = ref.watch(budgetCategoryRepositoryProvider);
  return CreateBudgetCategory(repository);
});

final updateBudgetCategoryUseCaseProvider = Provider<UpdateBudgetCategory>((
  ref,
) {
  final repository = ref.watch(budgetCategoryRepositoryProvider);
  return UpdateBudgetCategory(repository);
});

final deleteBudgetCategoryUseCaseProvider = Provider<DeleteBudgetCategory>((
  ref,
) {
  final repository = ref.watch(budgetCategoryRepositoryProvider);
  return DeleteBudgetCategory(repository);
});

// Budget category state notifier
class BudgetCategoryNotifier
    extends StateNotifier<AsyncValue<List<BudgetCategory>>> {
  final GetBudgetCategories getBudgetCategories;
  final CreateBudgetCategory createBudgetCategory;
  final UpdateBudgetCategory updateBudgetCategory;
  final DeleteBudgetCategory deleteBudgetCategory;
  final BudgetCategoryRepository repository;

  BudgetCategoryNotifier({
    required this.getBudgetCategories,
    required this.createBudgetCategory,
    required this.updateBudgetCategory,
    required this.deleteBudgetCategory,
    required this.repository,
  }) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await repository.initializeDefaultCategories();
      await loadCategories();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await getBudgetCategories();
      // Sort: default categories first, then custom ones, both alphabetically
      categories.sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCategory({required String name}) async {
    try {
      // Check if category name already exists
      final categories = state.valueOrNull ?? [];
      final exists = categories.any(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );

      if (exists) {
        throw Exception('A category with this name already exists');
      }

      await createBudgetCategory(name: name);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory({required BudgetCategory category}) async {
    try {
      // Check if new name conflicts with existing categories
      final categories = state.valueOrNull ?? [];
      final exists = categories.any(
        (c) =>
            c.id != category.id &&
            c.name.toLowerCase() == category.name.toLowerCase(),
      );

      if (exists) {
        throw Exception('A category with this name already exists');
      }

      await updateBudgetCategory(category: category);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory({required String id}) async {
    try {
      await deleteBudgetCategory(id: id);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
}

// Budget category state provider
final budgetCategoryProvider =
    StateNotifierProvider<
      BudgetCategoryNotifier,
      AsyncValue<List<BudgetCategory>>
    >((ref) {
      final getBudgetCategories = ref.watch(getBudgetCategoriesUseCaseProvider);
      final createBudgetCategory = ref.watch(
        createBudgetCategoryUseCaseProvider,
      );
      final updateBudgetCategory = ref.watch(
        updateBudgetCategoryUseCaseProvider,
      );
      final deleteBudgetCategory = ref.watch(
        deleteBudgetCategoryUseCaseProvider,
      );
      final repository = ref.watch(budgetCategoryRepositoryProvider);

      return BudgetCategoryNotifier(
        getBudgetCategories: getBudgetCategories,
        createBudgetCategory: createBudgetCategory,
        updateBudgetCategory: updateBudgetCategory,
        deleteBudgetCategory: deleteBudgetCategory,
        repository: repository,
      );
    });
