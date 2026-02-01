import 'package:budget_manage/features/expense/domain/entities/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expense Entity', () {
    test('should create expense with correct properties', () {
      final now = DateTime.now();
      final expense = Expense(
        id: '1',
        budgetId: 'budget1',
        budgetCategory: 'Food',
        amount: 50.0,
        description: 'Grocery shopping',
        month: 1,
        year: 2024,
        createdAt: now,
      );

      expect(expense.id, '1');
      expect(expense.budgetId, 'budget1');
      expect(expense.budgetCategory, 'Food');
      expect(expense.amount, 50.0);
      expect(expense.description, 'Grocery shopping');
      expect(expense.month, 1);
      expect(expense.year, 2024);
      expect(expense.createdAt, now);
    });

    test('should allow null description', () {
      final expense = Expense(
        id: '1',
        budgetId: 'budget1',
        budgetCategory: 'Food',
        amount: 50.0,
        month: 1,
        year: 2024,
        createdAt: DateTime.now(),
      );

      expect(expense.description, null);
    });

    test('should support value equality', () {
      final now = DateTime.now();
      final expense1 = Expense(
        id: '1',
        budgetId: 'budget1',
        budgetCategory: 'Food',
        amount: 50.0,
        description: 'Test',
        month: 1,
        year: 2024,
        createdAt: now,
      );
      final expense2 = Expense(
        id: '1',
        budgetId: 'budget1',
        budgetCategory: 'Food',
        amount: 50.0,
        description: 'Test',
        month: 1,
        year: 2024,
        createdAt: now,
      );

      expect(expense1, expense2);
    });

    test('should create copy with updated values', () {
      final now = DateTime.now();
      final expense = Expense(
        id: '1',
        budgetId: 'budget1',
        budgetCategory: 'Food',
        amount: 50.0,
        month: 1,
        year: 2024,
        createdAt: now,
      );

      final updatedExpense = expense.copyWith(
        description: 'Updated description',
      );

      expect(updatedExpense.id, '1');
      expect(updatedExpense.amount, 50.0);
      expect(updatedExpense.month, 1);
      expect(updatedExpense.year, 2024);
      expect(updatedExpense.description, 'Updated description');
    });
  });
}
