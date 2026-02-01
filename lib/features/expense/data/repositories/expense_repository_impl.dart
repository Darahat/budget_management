import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

/// Implementation of ExpenseRepository
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Expense>> getAllExpenses() async {
    final models = await localDataSource.getExpenses();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getExpenses(int month, int year) async {
    final allExpenses = await getAllExpenses();
    return allExpenses
        .where((expense) => expense.month == month && expense.year == year)
        .toList();
  }

  @override
  Future<List<Expense>> getExpensesByBudgetId(
    String budgetId,
    int month,
    int year,
  ) async {
    final expenses = await getExpenses(month, year);
    return expenses.where((expense) => expense.budgetId == budgetId).toList();
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final expenses = List<Expense>.from(await getAllExpenses());
    expenses.add(expense);
    final models = expenses.map((e) => ExpenseModel.fromEntity(e)).toList();
    await localDataSource.saveExpenses(models);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final expenses = List<Expense>.from(await getAllExpenses());
    expenses.removeWhere((expense) => expense.id == id);
    final models = expenses.map((e) => ExpenseModel.fromEntity(e)).toList();
    await localDataSource.saveExpenses(models);
  }

  @override
  Future<void> deleteExpensesByBudgetId(String budgetId) async {
    final expenses = List<Expense>.from(await getAllExpenses());
    expenses.removeWhere((expense) => expense.budgetId == budgetId);
    final models = expenses.map((e) => ExpenseModel.fromEntity(e)).toList();
    await localDataSource.saveExpenses(models);
  }

  @override
  Future<void> deleteAllExpenses() async {
    await localDataSource.deleteExpenses();
  }
}
