import '../entities/budget_category.dart';
import '../repositories/budget_category_repository.dart';

class UpdateBudgetCategory {
  final BudgetCategoryRepository repository;

  UpdateBudgetCategory(this.repository);

  Future<void> call({required BudgetCategory category}) async {
    await repository.updateCategory(category);
  }
}
