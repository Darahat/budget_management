import '../entities/budget_category.dart';

abstract class BudgetCategoryRepository {
  Future<List<BudgetCategory>> getCategories();
  Future<void> addCategory(BudgetCategory category);
  Future<void> updateCategory(BudgetCategory category);
  Future<void> deleteCategory(String id);
  Future<void> initializeDefaultCategories();
}
