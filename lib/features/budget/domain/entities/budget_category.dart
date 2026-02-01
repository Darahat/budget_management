import 'package:equatable/equatable.dart';

/// Domain entity representing a budget category
class BudgetCategory extends Equatable {
  final String id;
  final String name;
  final bool isDefault; // Default categories cannot be deleted
  final DateTime createdAt;

  const BudgetCategory({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.createdAt,
  });

  BudgetCategory copyWith({
    String? id,
    String? name,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, isDefault, createdAt];
}
