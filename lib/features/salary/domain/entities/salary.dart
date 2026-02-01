import 'package:equatable/equatable.dart';

/// Domain entity representing monthly salary
class Salary extends Equatable {
  final double amount;
  final double remaining;
  final int month; // 1-12
  final int year;
  final DateTime updatedAt;

  const Salary({
    required this.amount,
    required this.remaining,
    required this.month,
    required this.year,
    required this.updatedAt,
  });

  Salary copyWith({
    double? amount,
    double? remaining,
    int? month,
    int? year,
    DateTime? updatedAt,
  }) {
    return Salary(
      amount: amount ?? this.amount,
      remaining: remaining ?? this.remaining,
      month: month ?? this.month,
      year: year ?? this.year,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [amount, remaining, month, year, updatedAt];
}
