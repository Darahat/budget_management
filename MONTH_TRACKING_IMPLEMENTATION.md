# Month/Year Tracking Implementation

## Overview

This document describes the comprehensive refactoring to add month-based tracking throughout the budget management app. Users can now track different salaries, budgets, and expenses across months and years.

## Key Features Added

### 1. Month Selection System

- **MonthYear Model**: Represents a specific month (1-12) and year
- **MonthSelectionNotifier**: State management for current month selection
  - `nextMonth()`: Navigate to next month
  - `previousMonth()`: Navigate to previous month
  - `goToCurrentMonth()`: Jump to current month
- **MonthSelector Widget**: UI component for month navigation with prev/next buttons

### 2. Updated Data Models

#### Salary Entity

```dart
class Salary {
  final double amount;
  final double remaining;
  final int month;     // NEW: 1-12
  final int year;      // NEW
  final DateTime updatedAt;
}
```

#### Budget Entity

```dart
class Budget {
  final String id;
  final String category;
  final double allocatedAmount;
  final double spentAmount;
  final int month;     // NEW: 1-12
  final int year;      // NEW
  final DateTime createdAt;
}
```

#### Expense Entity

```dart
class Expense {
  final String id;
  final String budgetId;
  final String budgetCategory;
  final double amount;
  final String? description;
  final int month;     // NEW: 1-12
  final int year;      // NEW
  final DateTime createdAt;
}
```

### 3. Storage Layer Changes

#### Before (Single Value Storage)

```dart
// Stored one salary
Future<Salary?> getSalary()
Future<void> saveSalary(Salary salary)
```

#### After (Multi-Month Storage)

```dart
// Stores List<Salary> for all months/years
Future<List<Salary>> getAllSalaries()
Future<void> saveAllSalaries(List<Salary> salaries)
Future<Salary?> getSalary(int month, int year) // Filtered retrieval
```

Same pattern applied to Budget and Expense repositories.

### 4. Updated Use Cases

All use cases now accept month/year parameters:

```dart
// SetMonthlySalary
await setMonthlySalary(
  amount: 5000.0,
  month: 1,
  year: 2024,
);

// CreateBudget
await createBudget(
  category: 'Food',
  allocatedAmount: 500.0,
  month: 1,
  year: 2024,
);

// AddExpense
await addExpense(
  budgetId: 'budget-id',
  amount: 50.0,
  month: 1,
  year: 2024,
  description: 'Groceries',
);
```

### 5. Provider Integration

All providers now:

1. Watch `monthSelectionProvider` for changes
2. Automatically reload data when month changes
3. Pass current month/year to use cases

```dart
class SalaryNotifier extends StateNotifier<AsyncValue<Salary?>> {
  final Ref ref;

  SalaryNotifier({required this.ref}) {
    // Listen to month changes
    ref.listen(monthSelectionProvider, (previous, next) {
      loadSalary();
    });
  }

  Future<void> loadSalary() async {
    final monthYear = ref.read(monthSelectionProvider);
    final salary = await getSalary(monthYear.month, monthYear.year);
    state = AsyncValue.data(salary);
  }
}
```

### 6. UI Updates

#### Home Page

- Added MonthSelector at the top
- Shows current month/year (e.g., "January 2024")
- Navigation buttons for previous/next month
- "Go to Current Month" button

#### Data Display

- All data (salary, budgets, expenses) automatically filtered by selected month
- Switching months instantly updates all displayed data

## Migration Path

### For Existing Data

Old data without month/year fields will need migration:

1. Load existing data
2. Assign current month/year to all records
3. Save back with new format

### For New Installations

All data will be created with month/year from the start.

## File Changes Summary

### New Files

- `lib/core/providers/month_selection_provider.dart` - Month navigation state
- `lib/core/widgets/month_selector.dart` - Month selector UI widget
- `MONTH_TRACKING_IMPLEMENTATION.md` - This documentation

### Modified Files

#### Domain Layer (Entities)

- `lib/features/salary/domain/entities/salary.dart` - Added month/year
- `lib/features/budget/domain/entities/budget.dart` - Added month/year
- `lib/features/expense/domain/entities/expense.dart` - Added month/year

#### Data Layer (Models)

- `lib/features/salary/data/models/salary_model.dart` - JSON with month/year
- `lib/features/budget/data/models/budget_model.dart` - JSON with month/year
- `lib/features/expense/data/models/expense_model.dart` - JSON with month/year

#### Repository Interfaces

- `lib/features/salary/domain/repositories/salary_repository.dart` - Month/year params
- `lib/features/budget/domain/repositories/budget_repository.dart` - Month/year params
- `lib/features/expense/domain/repositories/expense_repository.dart` - Month/year params

#### Repository Implementations

- `lib/features/salary/data/repositories/salary_repository_impl.dart` - Filtering logic
- `lib/features/budget/data/repositories/budget_repository_impl.dart` - Filtering logic
- `lib/features/expense/data/repositories/expense_repository_impl.dart` - Filtering logic

#### Datasources

- `lib/features/salary/data/datasources/salary_local_datasource.dart` - List-based storage
- (Budget and Expense datasources use same storage pattern)

#### Use Cases

- `lib/features/salary/domain/usecases/get_salary.dart` - Month/year params
- `lib/features/salary/domain/usecases/set_monthly_salary.dart` - Month/year params
- `lib/features/budget/domain/usecases/get_budgets.dart` - Month/year params
- `lib/features/budget/domain/usecases/create_budget.dart` - Month/year params
- `lib/features/expense/domain/usecases/get_expenses.dart` - Month/year params
- `lib/features/expense/domain/usecases/add_expense.dart` - Month/year params

#### Presentation Layer (Providers)

- `lib/features/salary/presentation/providers/salary_providers.dart` - Month watching
- `lib/features/budget/presentation/providers/budget_providers.dart` - Month watching
- `lib/features/expense/presentation/providers/expense_providers.dart` - Month watching

#### UI Pages

- `lib/features/home/presentation/pages/home_page.dart` - Added MonthSelector

## Testing

### Tests Need Updates

All tests now need month/year parameters:

```dart
// Old
final salary = Salary(amount: 5000.0, remaining: 3000.0, updatedAt: now);

// New
final salary = Salary(
  amount: 5000.0,
  remaining: 3000.0,
  month: 1,
  year: 2024,
  updatedAt: now,
);
```

Test files requiring updates:

- `test/features/salary/domain/entities/salary_test.dart`
- `test/features/budget/domain/entities/budget_test.dart`
- `test/features/expense/domain/entities/expense_test.dart`
- `test/features/salary/domain/usecases/set_monthly_salary_test.dart`
- `test/features/budget/domain/usecases/create_budget_test.dart`
- `test/features/expense/domain/usecases/add_expense_test.dart`

## Usage Example

```dart
// User opens app in January 2024
// - MonthSelector shows "January 2024"
// - Sets salary for January
// - Creates budgets for January
// - Adds expenses to January budgets

// User clicks next month button (February)
// - MonthSelector shows "February 2024"
// - No salary yet (empty state)
// - No budgets yet
// - No expenses yet
// - User can set new salary and create new budgets

// User clicks previous month (back to January)
// - All January data reappears
// - Previous salary, budgets, and expenses are shown
```

## Benefits

1. **Full Year Tracking**: Track 12 months of financial data
2. **Month-to-Month Comparison**: Easy navigation between months
3. **Flexible Budgeting**: Different budgets for different months
4. **Salary Changes**: Handle salary changes across months
5. **Historical Data**: Keep complete financial history

## Future Enhancements

1. **Custom Categories**: Allow users to add categories beyond default 14
2. **Year View**: Summary of all months in a year
3. **Reports**: Generate monthly/yearly financial reports
4. **Budget Templates**: Copy budgets from previous months
5. **Data Export**: Export financial data to CSV/Excel
6. **Graphs & Charts**: Visualize spending trends over time
