import '../entities/budget_category.dart';
import '../repositories/budget_category_repository.dart';

class CreateBudgetCategory {
  final BudgetCategoryRepository repository;

  CreateBudgetCategory(this.repository);

  Future<void> call({required String name}) async {
    final category = BudgetCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      isDefault: false,
      createdAt: DateTime.now(),
    );

    await repository.addCategory(category);
  }
}
