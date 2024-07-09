// given a habit list of completion days
// is the habit completed today
import 'package:habit_tracker/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();

  return completedDays.any((date) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day);
}

// Prepare heat map dataset

Map<DateTime, int> prepareHeatMapDataSet(List<Habit> habits) {
  Map<DateTime, int> dataSet = {};

  for (var habit in habits) {
    for (var date in habit.completedDays) {
      // normalise date to avoid time mismatch
      final normalisedDate = DateTime(date.year, date.month, date.day);
      // if the date already exist in datasets => increment its count
      if (dataSet.containsKey(normalisedDate)) {
        dataSet[normalisedDate] = dataSet[normalisedDate]! + 1;
      } else {
        // initialise it with a count of one
        dataSet[normalisedDate] = 1;
      }
    }
  }
  return dataSet;
}
