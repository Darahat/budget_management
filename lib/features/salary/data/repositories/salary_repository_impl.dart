import '../../domain/entities/salary.dart';
import '../../domain/repositories/salary_repository.dart';
import '../datasources/salary_local_datasource.dart';
import '../models/salary_model.dart';

/// Implementation of SalaryRepository
class SalaryRepositoryImpl implements SalaryRepository {
  final SalaryLocalDataSource localDataSource;

  SalaryRepositoryImpl({required this.localDataSource});

  @override
  Future<Salary?> getSalary(int month, int year) async {
    final models = await localDataSource.getAllSalaries();
    try {
      return models
          .firstWhere((s) => s.month == month && s.year == year)
          .toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Salary>> getAllSalaries() async {
    final models = await localDataSource.getAllSalaries();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveSalary(Salary salary) async {
    final allSalaries = await localDataSource.getAllSalaries();
    // Remove existing salary for the same month/year if exists
    allSalaries.removeWhere(
      (s) => s.month == salary.month && s.year == salary.year,
    );
    allSalaries.add(SalaryModel.fromEntity(salary));
    await localDataSource.saveAllSalaries(allSalaries);
  }

  @override
  Future<void> updateRemaining(int month, int year, double remaining) async {
    final currentSalary = await getSalary(month, year);
    if (currentSalary != null) {
      final updatedSalary = currentSalary.copyWith(
        remaining: remaining,
        updatedAt: DateTime.now(),
      );
      await saveSalary(updatedSalary);
    }
  }

  @override
  Future<void> deleteSalary(int month, int year) async {
    final allSalaries = await localDataSource.getAllSalaries();
    allSalaries.removeWhere((s) => s.month == month && s.year == year);
    await localDataSource.saveAllSalaries(allSalaries);
  }
}
