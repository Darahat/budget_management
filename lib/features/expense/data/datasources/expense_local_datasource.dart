import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/expense_model.dart';

/// Local data source for expense data using SharedPreferences
class ExpenseLocalDataSource {
  final SharedPreferences sharedPreferences;

  ExpenseLocalDataSource({required this.sharedPreferences});

  Future<List<ExpenseModel>> getExpenses() async {
    final jsonString = sharedPreferences.getString(AppConstants.expensesKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    final jsonList = expenses.map((expense) => expense.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await sharedPreferences.setString(AppConstants.expensesKey, jsonString);
  }

  Future<void> deleteExpenses() async {
    await sharedPreferences.remove(AppConstants.expensesKey);
  }
}
