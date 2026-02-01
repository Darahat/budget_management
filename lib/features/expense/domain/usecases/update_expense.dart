import '../../../budget/domain/repositories/budget_repository.dart';
import '../../../salary/domain/repositories/salary_repository.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for updating an expense
class UpdateExpense {
  final ExpenseRepository expenseRepository;
  final BudgetRepository budgetRepository;
  final SalaryRepository salaryRepository;

  UpdateExpense({
    required this.expenseRepository,
    required this.budgetRepository,
    required this.salaryRepository,
  });

  Future<void> call({
    required Expense oldExpense,
    required String newBudgetId,
    required double newAmount,
    String? newDescription,
  }) async {
    final amountDifference = newAmount - oldExpense.amount;
    final budgetChanged = oldExpense.budgetId != newBudgetId;

    // Get the new budget to get its category name
    final newBudget = await budgetRepository.getBudgetById(newBudgetId);
    if (newBudget == null) {
      throw StateError('Budget not found');
    }

    // Update the expense
    final updatedExpense = oldExpense.copyWith(
      budgetId: newBudgetId,
      budgetCategory: newBudget.category,
      amount: newAmount,
      description: newDescription,
    );

    // Delete old and save new (since we don't have update in repository)
    await expenseRepository.deleteExpense(oldExpense.id);
    await expenseRepository.saveExpense(updatedExpense);

    if (budgetChanged) {
      // Remove amount from old budget
      final oldBudget = await budgetRepository.getBudgetById(
        oldExpense.budgetId,
      );
      if (oldBudget != null) {
        final updatedOldBudget = oldBudget.copyWith(
          spentAmount: oldBudget.spentAmount - oldExpense.amount,
        );
        await budgetRepository.updateBudget(updatedOldBudget);
      }

      // Add amount to new budget
      final updatedNewBudget = newBudget.copyWith(
        spentAmount: newBudget.spentAmount + newAmount,
      );
      await budgetRepository.updateBudget(updatedNewBudget);
    } else {
      // Same budget, just update the spent amount
      final budget = await budgetRepository.getBudgetById(newBudgetId);
      if (budget != null) {
        final updatedBudget = budget.copyWith(
          spentAmount: budget.spentAmount + amountDifference,
        );
        await budgetRepository.updateBudget(updatedBudget);
      }
    }

    // Update salary remaining
    final salary = await salaryRepository.getSalary(
      oldExpense.month,
      oldExpense.year,
    );
    if (salary != null) {
      final updatedSalary = salary.copyWith(
        remaining: salary.remaining - amountDifference,
      );
      await salaryRepository.saveSalary(updatedSalary);
    }
  }
}
