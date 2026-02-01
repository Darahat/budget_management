import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/salary_model.dart';

/// Local data source for salary data using SharedPreferences
class SalaryLocalDataSource {
  final SharedPreferences sharedPreferences;

  SalaryLocalDataSource({required this.sharedPreferences});

  Future<List<SalaryModel>> getAllSalaries() async {
    final jsonString = sharedPreferences.getString(
      AppConstants.monthlySalaryKey,
    );
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => SalaryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveAllSalaries(List<SalaryModel> salaries) async {
    final jsonList = salaries.map((s) => s.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await sharedPreferences.setString(
      AppConstants.monthlySalaryKey,
      jsonString,
    );
  }
}
