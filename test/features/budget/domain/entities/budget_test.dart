import 'package:budget_manage/features/budget/domain/entities/budget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Budget Entity', () {
    test('should create budget with correct properties', () {
      final now = DateTime.now();
      final budget = Budget(
        id: '1',
        category: 'Food',
        allocatedAmount: 500.0,
        spentAmount: 200.0,
        month: 1,
        year: 2024,
        createdAt: now,
      );

      expect(budget.id, '1');
      expect(budget.category, 'Food');
      expect(budget.allocatedAmount, 500.0);
      expect(budget.spentAmount, 200.0);
      expect(budget.month, 1);
      expect(budget.year, 2024);
      expect(budget.createdAt, now);
    });

    test('should calculate remaining amount correctly', () {
      final budget = Budget(
        id: '1',
        category: 'Food',
        allocatedAmount: 500.0,
        spentAmount: 200.0,
        month: 1,
        year: 2024,
        createdAt: DateTime.now(),
      );

      expect(budget.remainingAmount, 300.0);
    });

    test('should identify exhausted budget', () {
      final budget = Budget(
        id: '1',
        category: 'Food',
        allocatedAmount: 500.0,
        spentAmount: 500.0,
        month: 1,
        year: 2024,
        createdAt: DateTime.now(),
      );

      expect(budget.isExhausted, true);
    });

    test('should calculate spent percentage correctly', () {
      final budget = Budget(
        id: '1',
        category: 'Food',
        allocatedAmount: 500.0,
        spentAmount: 250.0,
        month: 1,
        year: 2024,
        createdAt: DateTime.now(),
      );

      expect(budget.spentPercentage, 50.0);
    });

    test('should support value equality', () {
      final now = DateTime.now();
      final budget1 = Budget(
        id: '1',
        category: 'Food',
        allocatedAmount: 500.0,
        spentAmount: 200.0,
        month: 1,
        year: 2024,
        createdAt: now,
      );
      final budget2 = Budget(
        id: '1',
        category: 'Food',
        allocatedAmount: 500.0,
        spentAmount: 200.0,
        month: 1,
        year: 2024,
        createdAt: now,
      );

      expect(budget1, budget2);
    });

    test('should create copy with updated values', () {
      final now = DateTime.now();
      final budget = Budget(
        id: '1',
        category: 'Food',
        allocatedAmount: 500.0,
        spentAmount: 200.0,
        month: 1,
        year: 2024,
        createdAt: now,
      );

      final updatedBudget = budget.copyWith(spentAmount: 300.0);

      expect(updatedBudget.id, '1');
      expect(updatedBudget.category, 'Food');
      expect(updatedBudget.allocatedAmount, 500.0);
      expect(updatedBudget.spentAmount, 300.0);
      expect(updatedBudget.month, 1);
      expect(updatedBudget.year, 2024);
      expect(updatedBudget.remainingAmount, 200.0);
    });
  });
}
