import '../entities/budget_category.dart';
import '../repositories/budget_category_repository.dart';

class GetBudgetCategories {
  final BudgetCategoryRepository repository;

  GetBudgetCategories(this.repository);

  Future<List<BudgetCategory>> call() async {
    return await repository.getCategories();
  }
}
