import 'package:budget_manage/features/salary/domain/entities/salary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Salary Entity', () {
    test('should create salary with correct properties', () {
      final now = DateTime.now();
      final salary = Salary(
        amount: 5000.0,
        remaining: 3000.0,
        month: 1,
        year: 2024,
        updatedAt: now,
      );

      expect(salary.amount, 5000.0);
      expect(salary.remaining, 3000.0);
      expect(salary.month, 1);
      expect(salary.year, 2024);
    });

    test('should support value equality', () {
      final now = DateTime.now();
      final salary1 = Salary(
        amount: 5000.0,
        remaining: 3000.0,
        month: 1,
        year: 2024,
        updatedAt: now,
      );
      final salary2 = Salary(
        amount: 5000.0,
        remaining: 3000.0,
        month: 1,
        year: 2024,
        updatedAt: now,
      );

      expect(salary1, salary2);
    });

    test('should create copy with updated values', () {
      final now = DateTime.now();
      final salary = Salary(
        amount: 5000.0,
        remaining: 3000.0,
        month: 1,
        year: 2024,
        updatedAt: now,
      );

      final updatedSalary = salary.copyWith(remaining: 2500.0);

      expect(updatedSalary.amount, 5000.0);
      expect(updatedSalary.remaining, 2500.0);
      expect(updatedSalary.month, 1);
      expect(updatedSalary.year, 2024);
      expect(updatedSalary.updatedAt, now);
    });
  });
}
