import '../../domain/entities/budget_category.dart';
import '../../domain/repositories/budget_category_repository.dart';
import '../datasources/budget_category_local_datasource.dart';
import '../models/budget_category_model.dart';

class BudgetCategoryRepositoryImpl implements BudgetCategoryRepository {
  final BudgetCategoryLocalDatasource localDatasource;

  BudgetCategoryRepositoryImpl(this.localDatasource);

  @override
  Future<List<BudgetCategory>> getCategories() async {
    return await localDatasource.getCategories();
  }

  @override
  Future<void> addCategory(BudgetCategory category) async {
    final model = BudgetCategoryModel.fromEntity(category);
    await localDatasource.addCategory(model);
  }

  @override
  Future<void> updateCategory(BudgetCategory category) async {
    final model = BudgetCategoryModel.fromEntity(category);
    await localDatasource.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await localDatasource.deleteCategory(id);
  }

  @override
  Future<void> initializeDefaultCategories() async {
    await localDatasource.initializeDefaultCategories();
  }
}
