import 'package:budget_manage/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_manage/features/expense/domain/repositories/expense_repository.dart';
import 'package:budget_manage/features/salary/domain/repositories/salary_repository.dart';
import 'package:budget_manage/features/salary/domain/usecases/set_monthly_salary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([SalaryRepository, BudgetRepository, ExpenseRepository])
import 'set_monthly_salary_test.mocks.dart';

void main() {
  late SetMonthlySalary useCase;
  late MockSalaryRepository mockRepository;
  late MockBudgetRepository mockBudgetRepository;
  late MockExpenseRepository mockExpenseRepository;

  setUp(() {
    mockRepository = MockSalaryRepository();
    mockBudgetRepository = MockBudgetRepository();
    mockExpenseRepository = MockExpenseRepository();
    useCase = SetMonthlySalary(
      repository: mockRepository,
      budgetRepository: mockBudgetRepository,
      expenseRepository: mockExpenseRepository,
    );
  });

  group('SetMonthlySalary UseCase', () {
    test('should save salary with correct values', () async {
      // Arrange
      const amount = 5000.0;
      const month = 1;
      const year = 2024;
      when(
        mockExpenseRepository.getExpenses(month, year),
      ).thenAnswer((_) async => []);
      when(
        mockRepository.saveSalary(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(amount: amount, month: month, year: year);

      // Assert
      verify(mockRepository.saveSalary(any)).called(1);
    });

    test('should throw error for negative amount', () async {
      // Arrange
      const amount = -1000.0;
      const month = 1;
      const year = 2024;

      // Act & Assert
      expect(
        () => useCase(amount: amount, month: month, year: year),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockRepository.saveSalary(any));
    });

    test('should allow zero amount', () async {
      // Arrange
      const amount = 0.0;
      const month = 1;
      const year = 2024;
      when(
        mockExpenseRepository.getExpenses(month, year),
      ).thenAnswer((_) async => []);
      when(
        mockRepository.saveSalary(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(amount: amount, month: month, year: year);

      // Assert
      verify(mockRepository.saveSalary(any)).called(1);
    });
  });
}
