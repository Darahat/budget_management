import 'package:uuid/uuid.dart';

import '../../../salary/domain/repositories/salary_repository.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

/// Use case for creating a new budget
class CreateBudget {
  final BudgetRepository budgetRepository;
  final SalaryRepository salaryRepository;
  final Uuid uuid;

  CreateBudget({
    required this.budgetRepository,
    required this.salaryRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<void> call({
    required String category,
    required double allocatedAmount,
    required int month,
    required int year,
  }) async {
    if (allocatedAmount <= 0) {
      throw ArgumentError('Budget amount must be greater than 0');
    }

    // Check if category already exists for this month/year
    final existingBudgets = await budgetRepository.getBudgets(month, year);
    final categoryExists = existingBudgets.any(
      (budget) => budget.category.toLowerCase() == category.toLowerCase(),
    );

    if (categoryExists) {
      throw StateError(
        'A budget for "$category" already exists for this month. Each category can only have one budget per month.',
      );
    }

    // Check if salary is set for this month/year
    final salary = await salaryRepository.getSalary(month, year);
    if (salary == null) {
      throw StateError('Please set your monthly salary first');
    }

    // Check if total allocated amount exceeds salary
    final currentTotalAllocated = await budgetRepository
        .getTotalAllocatedAmount(month, year);
    final newTotal = currentTotalAllocated + allocatedAmount;

    if (newTotal > salary.amount) {
      throw StateError(
        'Total budget allocation cannot exceed monthly salary. '
        'Available: \$${salary.amount - currentTotalAllocated}, '
        'Requested: \$$allocatedAmount',
      );
    }

    final budget = Budget(
      id: uuid.v4(),
      category: category,
      allocatedAmount: allocatedAmount,
      spentAmount: 0.0,
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );

    await budgetRepository.saveBudget(budget);
  }
}
