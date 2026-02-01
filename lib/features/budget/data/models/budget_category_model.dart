import '../../domain/entities/budget_category.dart';

class BudgetCategoryModel extends BudgetCategory {
  const BudgetCategoryModel({
    required super.id,
    required super.name,
    required super.isDefault,
    required super.createdAt,
  });

  factory BudgetCategoryModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetCategoryModel.fromEntity(BudgetCategory category) {
    return BudgetCategoryModel(
      id: category.id,
      name: category.name,
      isDefault: category.isDefault,
      createdAt: category.createdAt,
    );
  }
}
