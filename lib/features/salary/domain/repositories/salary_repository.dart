import '../entities/salary.dart';

/// Repository interface for salary operations
abstract class SalaryRepository {
  Future<Salary?> getSalary(int month, int year);
  Future<List<Salary>> getAllSalaries();
  Future<void> saveSalary(Salary salary);
  Future<void> updateRemaining(int month, int year, double remaining);
  Future<void> deleteSalary(int month, int year);
}
