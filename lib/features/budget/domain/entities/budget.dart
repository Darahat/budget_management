import 'package:equatable/equatable.dart';

/// Domain entity representing a budget category
class Budget extends Equatable {
  final String id;
  final String category;
  final double allocatedAmount;
  final double spentAmount;
  final int month; // 1-12
  final int year;
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  double get remainingAmount => allocatedAmount - spentAmount;

  bool get isExhausted => spentAmount >= allocatedAmount;

  double get spentPercentage =>
      allocatedAmount > 0 ? (spentAmount / allocatedAmount) * 100 : 0;

  Budget copyWith({
    String? id,
    String? category,
    double? allocatedAmount,
    double? spentAmount,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    allocatedAmount,
    spentAmount,
    month,
    year,
    createdAt,
  ];
}
