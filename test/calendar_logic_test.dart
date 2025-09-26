import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/enums.dart';

void main() {
  group('Calendar Start Day Calculation', () {
    test('should calculate correct start days for different first day settings', () {
      // Test case: First day of month is a Wednesday (weekday = 3)
      final firstDayOfMonth = DateTime(2024, 1, 3); // January 3, 2024 is a Wednesday
      expect(firstDayOfMonth.weekday, 3); // Verify it's Wednesday

      // When first day of week is Monday (1)
      var firstDayWeekdayValue = FirstDayOfWeek.monday.toWeekdayValue; // 1
      var startDay = (firstDayOfMonth.weekday - firstDayWeekdayValue) % 7;
      if (startDay < 0) startDay += 7;
      expect(startDay, 2); // Wednesday is 2 positions from Monday

      // When first day of week is Sunday (7)
      firstDayWeekdayValue = FirstDayOfWeek.sunday.toWeekdayValue; // 7
      startDay = (firstDayOfMonth.weekday - firstDayWeekdayValue) % 7;
      if (startDay < 0) startDay += 7;
      expect(startDay, 3); // Wednesday is 3 positions from Sunday

      // When first day of week is Wednesday (3)
      firstDayWeekdayValue = FirstDayOfWeek.wednesday.toWeekdayValue; // 3
      startDay = (firstDayOfMonth.weekday - firstDayWeekdayValue) % 7;
      if (startDay < 0) startDay += 7;
      expect(startDay, 0); // Wednesday is 0 positions from Wednesday
    });

    test('should generate correct day headers', () {
      final allDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

      // Test Monday first
      var firstDayWeekdayValue = FirstDayOfWeek.monday.toWeekdayValue; // 1
      var startIndex = (firstDayWeekdayValue == 7) ? 0 : firstDayWeekdayValue; // 1
      var dayHeaders = <String>[];
      for (int i = 0; i < 7; i++) {
        dayHeaders.add(allDays[(startIndex + i) % 7]);
      }
      expect(dayHeaders, ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);

      // Test Sunday first
      firstDayWeekdayValue = FirstDayOfWeek.sunday.toWeekdayValue; // 7
      startIndex = (firstDayWeekdayValue == 7) ? 0 : firstDayWeekdayValue; // 0
      dayHeaders = <String>[];
      for (int i = 0; i < 7; i++) {
        dayHeaders.add(allDays[(startIndex + i) % 7]);
      }
      expect(dayHeaders, ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']);

      // Test Wednesday first
      firstDayWeekdayValue = FirstDayOfWeek.wednesday.toWeekdayValue; // 3
      startIndex = (firstDayWeekdayValue == 7) ? 0 : firstDayWeekdayValue; // 3
      dayHeaders = <String>[];
      for (int i = 0; i < 7; i++) {
        dayHeaders.add(allDays[(startIndex + i) % 7]);
      }
      expect(dayHeaders, ['Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue']);
    });
  });
}