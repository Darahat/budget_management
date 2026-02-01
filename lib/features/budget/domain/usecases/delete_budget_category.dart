import '../repositories/budget_category_repository.dart';

class DeleteBudgetCategory {
  final BudgetCategoryRepository repository;

  DeleteBudgetCategory(this.repository);

  Future<void> call({required String id}) async {
    await repository.deleteCategory(id);
  }
}
