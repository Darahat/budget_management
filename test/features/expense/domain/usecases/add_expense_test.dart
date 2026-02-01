import 'package:budget_manage/features/budget/domain/entities/budget.dart';
import 'package:budget_manage/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_manage/features/expense/domain/repositories/expense_repository.dart';
import 'package:budget_manage/features/expense/domain/usecases/add_expense.dart';
import 'package:budget_manage/features/salary/domain/entities/salary.dart';
import 'package:budget_manage/features/salary/domain/repositories/salary_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

@GenerateMocks([ExpenseRepository, BudgetRepository, SalaryRepository, Uuid])
import 'add_expense_test.mocks.dart';

void main() {
  late AddExpense useCase;
  late MockExpenseRepository mockExpenseRepository;
  late MockBudgetRepository mockBudgetRepository;
  late MockSalaryRepository mockSalaryRepository;
  late MockUuid mockUuid;

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
    mockBudgetRepository = MockBudgetRepository();
    mockSalaryRepository = MockSalaryRepository();
    mockUuid = MockUuid();
    useCase = AddExpense(
      expenseRepository: mockExpenseRepository,
      budgetRepository: mockBudgetRepository,
      salaryRepository: mockSalaryRepository,
      uuid: mockUuid,
    );
  });

  group('AddExpense UseCase', () {
    test('should add expense successfully when within budget', () async {
      // Arrange
      const budgetId = 'budget1';
      const amount = 100.0;
      const description = 'Test expense';
      const month = 1;
      const year = 2024;

      final budget = Budget(
        id: budgetId,
        category: 'Food',
        allocatedAmount: 500.0,
        spentAmount: 200.0,
        month: month,
        year: year,
        createdAt: DateTime.now(),
      );

      final salary = Salary(
        amount: 5000.0,
        remaining: 4000.0,
        month: month,
        year: year,
        updatedAt: DateTime.now(),
      );

      when(
        mockBudgetRepository.getBudgetById(budgetId),
      ).thenAnswer((_) async => budget);
      when(
        mockSalaryRepository.getSalary(any, any),
      ).thenAnswer((_) async => salary);
      when(mockUuid.v4()).thenReturn('expense-id');
      when(
        mockExpenseRepository.saveExpense(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockBudgetRepository.updateBudget(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockSalaryRepository.updateRemaining(any, any, any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(
        budgetId: budgetId,
        amount: amount,
        month: month,
        year: year,
        description: description,
      );

      // Assert
      verify(mockExpenseRepository.saveExpense(any)).called(1);
      verify(mockBudgetRepository.updateBudget(any)).called(1);
      verify(
        mockSalaryRepository.updateRemaining(month, year, 3900.0),
      ).called(1);
    });

    test('should throw error when budget not found', () async {
      // Arrange
      const month = 1;
      const year = 2024;
      when(
        mockBudgetRepository.getBudgetById(any),
      ).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase(
          budgetId: 'invalid',
          amount: 100.0,
          month: month,
          year: year,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('should throw error when expense exceeds budget', () async {
      // Arrange
      const month = 1;
      const year = 2024;
      final budget = Budget(
        id: 'budget1',
        category: 'Food',
        allocatedAmount: 500.0,
        spentAmount: 450.0,
        month: month,
        year: year,
        createdAt: DateTime.now(),
      );

      when(
        mockBudgetRepository.getBudgetById('budget1'),
      ).thenAnswer((_) async => budget);

      // Act & Assert
      expect(
        () => useCase(
          budgetId: 'budget1',
          amount: 100.0,
          month: month,
          year: year,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('should throw error for zero or negative amount', () async {
      // Arrange
      const month = 1;
      const year = 2024;

      // Act & Assert
      expect(
        () =>
            useCase(budgetId: 'budget1', amount: 0.0, month: month, year: year),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => useCase(
          budgetId: 'budget1',
          amount: -50.0,
          month: month,
          year: year,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
