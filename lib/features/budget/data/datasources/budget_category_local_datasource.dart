import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/budget_category_model.dart';

class BudgetCategoryLocalDatasource {
  final SharedPreferences sharedPreferences;
  static const String _categoriesKey = 'budget_categories';
  static const String _initializedKey = 'categories_initialized';

  BudgetCategoryLocalDatasource(this.sharedPreferences);

  Future<List<BudgetCategoryModel>> getCategories() async {
    final jsonString = sharedPreferences.getString(_categoriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map(
          (json) => BudgetCategoryModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveCategories(List<BudgetCategoryModel> categories) async {
    final jsonList = categories.map((category) => category.toJson()).toList();
    await sharedPreferences.setString(_categoriesKey, json.encode(jsonList));
  }

  Future<void> addCategory(BudgetCategoryModel category) async {
    final categories = await getCategories();
    categories.add(category);
    await saveCategories(categories);
  }

  Future<void> updateCategory(BudgetCategoryModel category) async {
    final categories = await getCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await saveCategories(categories);
    }
  }

  Future<void> deleteCategory(String id) async {
    final categories = await getCategories();
    categories.removeWhere((c) => c.id == id);
    await saveCategories(categories);
  }

  Future<void> initializeDefaultCategories() async {
    final isInitialized = sharedPreferences.getBool(_initializedKey) ?? false;
    if (isInitialized) return;

    final uuid = const Uuid();
    final now = DateTime.now();
    final defaultCategories = AppConstants.defaultCategories.map((name) {
      return BudgetCategoryModel(
        id: uuid.v4(),
        name: name,
        isDefault: true,
        createdAt: now,
      );
    }).toList();

    await saveCategories(defaultCategories);
    await sharedPreferences.setBool(_initializedKey, true);
  }
}
