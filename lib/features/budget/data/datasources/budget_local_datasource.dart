import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/budget_model.dart';

/// Local data source for budget data using SharedPreferences
class BudgetLocalDataSource {
  final SharedPreferences sharedPreferences;

  BudgetLocalDataSource({required this.sharedPreferences});

  Future<List<BudgetModel>> getBudgets() async {
    final jsonString = sharedPreferences.getString(AppConstants.budgetsKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => BudgetModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveBudgets(List<BudgetModel> budgets) async {
    final jsonList = budgets.map((budget) => budget.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await sharedPreferences.setString(AppConstants.budgetsKey, jsonString);
  }

  Future<void> deleteBudgets() async {
    await sharedPreferences.remove(AppConstants.budgetsKey);
  }
}
