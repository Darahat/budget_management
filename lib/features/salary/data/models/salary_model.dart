import '../../domain/entities/salary.dart';

/// Data model for Salary with JSON serialization
class SalaryModel extends Salary {
  const SalaryModel({
    required super.amount,
    required super.remaining,
    required super.month,
    required super.year,
    required super.updatedAt,
  });

  factory SalaryModel.fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      amount: (json['amount'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'remaining': remaining,
      'month': month,
      'year': year,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SalaryModel.fromEntity(Salary salary) {
    return SalaryModel(
      amount: salary.amount,
      remaining: salary.remaining,
      month: salary.month,
      year: salary.year,
      updatedAt: salary.updatedAt,
    );
  }

  Salary toEntity() => this;
}
