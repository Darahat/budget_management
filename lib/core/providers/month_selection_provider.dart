import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for selected month and year
class MonthYear {
  final int month; // 1-12
  final int year;

  const MonthYear({required this.month, required this.year});

  factory MonthYear.now() {
    final now = DateTime.now();
    return MonthYear(month: now.month, year: now.year);
  }

  MonthYear copyWith({int? month, int? year}) {
    return MonthYear(month: month ?? this.month, year: year ?? this.year);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthYear &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => month.hashCode ^ year.hashCode;

  @override
  String toString() => '$month/$year';
}

/// State notifier for selected month
class MonthSelectionNotifier extends StateNotifier<MonthYear> {
  MonthSelectionNotifier() : super(MonthYear.now());

  void selectMonth(int month, int year) {
    state = MonthYear(month: month, year: year);
  }

  void nextMonth() {
    if (state.month == 12) {
      state = MonthYear(month: 1, year: state.year + 1);
    } else {
      state = MonthYear(month: state.month + 1, year: state.year);
    }
  }

  void previousMonth() {
    if (state.month == 1) {
      state = MonthYear(month: 12, year: state.year - 1);
    } else {
      state = MonthYear(month: state.month - 1, year: state.year);
    }
  }

  void goToCurrentMonth() {
    state = MonthYear.now();
  }
}

/// Provider for selected month
final monthSelectionProvider =
    StateNotifierProvider<MonthSelectionNotifier, MonthYear>((ref) {
      return MonthSelectionNotifier();
    });
