import 'package:budget_manage/features/budget/domain/entities/budget.dart';
import 'package:budget_manage/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_manage/features/budget/domain/usecases/create_budget.dart';
import 'package:budget_manage/features/salary/domain/entities/salary.dart';
import 'package:budget_manage/features/salary/domain/repositories/salary_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

@GenerateMocks([BudgetRepository, SalaryRepository, Uuid])
import 'create_budget_test.mocks.dart';

void main() {
  late CreateBudget useCase;
  late MockBudgetRepository mockBudgetRepository;
  late MockSalaryRepository mockSalaryRepository;
  late MockUuid mockUuid;

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    mockSalaryRepository = MockSalaryRepository();
    mockUuid = MockUuid();
    useCase = CreateBudget(
      budgetRepository: mockBudgetRepository,
      salaryRepository: mockSalaryRepository,
      uuid: mockUuid,
    );
  });

  group('CreateBudget UseCase', () {
    test(
      'should create budget successfully when within salary limit',
      () async {
        // Arrange
        const category = 'Food';
        const allocatedAmount = 500.0;
        const month = 1;
        const year = 2024;
        final salary = Salary(
          amount: 5000.0,
          remaining: 5000.0,
          month: month,
          year: year,
          updatedAt: DateTime.now(),
        );

        when(
          mockBudgetRepository.getBudgets(any, any),
        ).thenAnswer((_) async => []);
        when(
          mockSalaryRepository.getSalary(any, any),
        ).thenAnswer((_) async => salary);
        when(
          mockBudgetRepository.getTotalAllocatedAmount(any, any),
        ).thenAnswer((_) async => 0.0);
        when(mockUuid.v4()).thenReturn('test-id');
        when(
          mockBudgetRepository.saveBudget(any),
        ).thenAnswer((_) async => Future.value());

        // Act
        await useCase(
          category: category,
          allocatedAmount: allocatedAmount,
          month: month,
          year: year,
        );

        // Assert
        verify(mockBudgetRepository.saveBudget(any)).called(1);
      },
    );

    test('should throw error when salary is not set', () async {
      // Arrange
      const month = 1;
      const year = 2024;
      when(
        mockBudgetRepository.getBudgets(any, any),
      ).thenAnswer((_) async => []);
      when(
        mockSalaryRepository.getSalary(any, any),
      ).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase(
          category: 'Food',
          allocatedAmount: 500.0,
          month: month,
          year: year,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('should throw error when budget exceeds salary', () async {
      // Arrange
      const month = 1;
      const year = 2024;
      final salary = Salary(
        amount: 5000.0,
        remaining: 5000.0,
        month: month,
        year: year,
        updatedAt: DateTime.now(),
      );

      when(
        mockBudgetRepository.getBudgets(any, any),
      ).thenAnswer((_) async => []);
      when(
        mockSalaryRepository.getSalary(any, any),
      ).thenAnswer((_) async => salary);
      when(
        mockBudgetRepository.getTotalAllocatedAmount(any, any),
      ).thenAnswer((_) async => 4800.0);

      // Act & Assert
      expect(
        () => useCase(
          category: 'Food',
          allocatedAmount: 500.0,
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
      when(
        mockBudgetRepository.getBudgets(any, any),
      ).thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => useCase(
          category: 'Food',
          allocatedAmount: 0.0,
          month: month,
          year: year,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => useCase(
          category: 'Food',
          allocatedAmount: -100.0,
          month: month,
          year: year,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error when category already exists', () async {
      // Arrange
      const month = 1;
      const year = 2024;
      final existingBudget = Budget(
        id: 'existing-id',
        category: 'Food',
        allocatedAmount: 1000.0,
        spentAmount: 0.0,
        month: month,
        year: year,
        createdAt: DateTime.now(),
      );

      when(
        mockBudgetRepository.getBudgets(any, any),
      ).thenAnswer((_) async => [existingBudget]);

      // Act & Assert
      expect(
        () => useCase(
          category: 'Food',
          allocatedAmount: 500.0,
          month: month,
          year: year,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
