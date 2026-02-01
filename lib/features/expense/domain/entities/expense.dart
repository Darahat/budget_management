import 'package:equatable/equatable.dart';

/// Domain entity representing an expense
class Expense extends Equatable {
  final String id;
  final String budgetId;
  final String budgetCategory;
  final double amount;
  final String? description;
  final int month; // 1-12
  final int year;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.budgetId,
    required this.budgetCategory,
    required this.amount,
    this.description,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  Expense copyWith({
    String? id,
    String? budgetId,
    String? budgetCategory,
    double? amount,
    String? description,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      budgetCategory: budgetCategory ?? this.budgetCategory,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    budgetId,
    budgetCategory,
    amount,
    description,
    month,
    year,
    createdAt,
  ];
}
