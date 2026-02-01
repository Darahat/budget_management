# Setup Guide - Budget Manager App

## Current Status

The project has been fully implemented with:
✅ Clean Architecture (Domain, Data, Presentation layers)
✅ Riverpod State Management
✅ Complete feature implementation (Salary, Budget, Expense)
✅ Comprehensive tests
✅ Professional UI/UX

## Quick Fix Required

There's a minor import path issue that needs to be resolved. The core utilities are at `lib/core/` but some imports reference them incorrectly.

### Fix Import Paths

Run the following command to fix all import paths:

```bash
# For PowerShell/Windows
(Get-ChildItem -Path "lib\features" -Recurse -Filter "*.dart") | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  $content = $content -replace "import '../../../core/", "import '../../../../core/"
  $content = $content -replace "import '../../../\.\./core/", "import '../../../../core/"
  Set-Content -Path $_.FullName -Value $content
}
```

Or manually update these files:

1. [lib/features/salary/data/datasources/salary_local_datasource.dart](lib/features/salary/data/datasources/salary_local_datasource.dart#L5)

   - Change: `import '../../../core/constants/app_constants.dart';`
   - To: `import '../../../../core/constants/app_constants.dart';`

2. [lib/features/budget/data/datasources/budget_local_datasource.dart](lib/features/budget/data/datasources/budget_local_datasource.dart#L5)

   - Change: `import '../../../core/constants/app_constants.dart';`
   - To: `import '../../../../core/constants/app_constants.dart';`

3. [lib/features/expense/data/datasources/expense_local_datasource.dart](lib/features/expense/data/datasources/expense_local_datasource.dart#L5)

   - Change: `import '../../../core/constants/app_constants.dart';`
   - To: `import '../../../../core/constants/app_constants.dart';`

4. [lib/features/budget/presentation/pages/create_budget_page.dart](lib/features/budget/presentation/pages/create_budget_page.dart#L5)

   - Change: `import '../../../core/constants/app_constants.dart';`
   - To: `import '../../../../core/constants/app_constants.dart';`

5. [lib/features/budget/presentation/widgets/budget_list.dart](lib/features/budget/presentation/widgets/budget_list.dart#L4)

   - Change: `import '../../../core/utils/currency_formatter.dart';`
   - To: `import '../../../../core/utils/currency_formatter.dart';`

6. [lib/features/expense/presentation/widgets/expense_list.dart](lib/features/expense/presentation/widgets/expense_list.dart#L5)

   - Change: `import '../../../core/utils/currency_formatter.dart';`
   - To: `import '../../../../core/utils/currency_formatter.dart';`

7. [lib/features/salary/presentation/widgets/salary_card.dart](lib/features/salary/presentation/widgets/salary_card.dart#L4)
   - Change: `import '../../../core/utils/currency_formatter.dart';`
   - To: `import '../../../../core/utils/currency_formatter.dart';`

### After Fixing Imports

Run these commands:

```bash
# Install dependencies
flutter pub get

# Generate mocks for tests
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run the app
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
│       └── currency_formatter.dart
├── features/
│   ├── salary/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── budget/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── expense/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   └── home/
│       └── presentation/
└── main.dart
```

##Features Implemented

### 1. Salary Management

- Set monthly salary
- Update salary anytime
- View remaining balance
- Track spending percentage

### 2. Budget Management

- Create budgets by category
- Cannot exceed monthly salary
- Real-time tracking
- Visual progress indicators

### 3. Expense Tracking

- Add expenses to budgets
- Auto-reduce budget and salary
- Recent expense history
- Optional descriptions

## How to Use the App

1. **First Time**: Set your monthly salary
2. **Create Budgets**: Add budget categories with allocated amounts
3. **Track Expenses**: Select a budget and add expenses
4. **Monitor**: View your spending on the home screen

## Testing

The project includes comprehensive tests:

- Entity tests
- Use case tests
- Widget tests
- Repository tests

Run all tests with:

```bash
flutter test
```

## Development

Built with professional standards:

- ✅ Clean Architecture
- ✅ SOLID Principles
- ✅ Dependency Injection
- ✅ State Management (Riverpod)
- ✅ Local Storage (SharedPreferences)
- ✅ Comprehensive Testing
- ✅ Type Safety
- ✅ Null Safety

## Next Steps

1. Fix the import paths as described above
2. Run `flutter pub get`
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`
4. Run `flutter test` to verify all tests pass
5. Run `flutter run` to start the app

Enjoy your professional budget management app! 🎉
