import '../../domain/entities/expense.dart';

/// Data model for Expense with JSON serialization
class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.budgetId,
    required super.budgetCategory,
    required super.amount,
    super.description,
    required super.month,
    required super.year,
    required super.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      budgetId: json['budgetId'] as String,
      budgetCategory: json['budgetCategory'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      month: json['month'] as int,
      year: json['year'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetId': budgetId,
      'budgetCategory': budgetCategory,
      'amount': amount,
      'description': description,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      budgetId: expense.budgetId,
      budgetCategory: expense.budgetCategory,
      amount: expense.amount,
      description: expense.description,
      month: expense.month,
      year: expense.year,
      createdAt: expense.createdAt,
    );
  }

  Expense toEntity() => this;
}
