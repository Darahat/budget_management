import '../../domain/entities/budget.dart';

/// Data model for Budget with JSON serialization
class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.category,
    required super.allocatedAmount,
    required super.spentAmount,
    required super.month,
    required super.year,
    required super.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      category: json['category'] as String,
      allocatedAmount: (json['allocatedAmount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      category: budget.category,
      allocatedAmount: budget.allocatedAmount,
      spentAmount: budget.spentAmount,
      month: budget.month,
      year: budget.year,
      createdAt: budget.createdAt,
    );
  }

  Budget toEntity() => this;
}
