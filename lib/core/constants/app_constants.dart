/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Storage Keys
  static const String monthlySalaryKey = 'monthly_salary';
  static const String budgetsKey = 'budgets';
  static const String expensesKey = 'expenses';

  // Validation
  static const double minSalary = 0.0;
  static const double maxSalary = 999999999.0;

  // Budget Categories
  static const List<String> defaultCategories = [
    'Home',
    'Internet',
    'Bua Bill',
    'Bow',
    'Savings',
    'Health',
    'My Expense',
    'Education',
    'Social Activity',
    'Fun',
    'Shopping',
    'Travel',
    'Food',
    'Other',
  ];
}
