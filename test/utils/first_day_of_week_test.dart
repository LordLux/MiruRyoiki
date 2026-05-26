import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/enums.dart';

void main() {
  group('FirstDayOfWeek', () {
    test('should convert to correct weekday values', () {
      expect(FirstDayOfWeek.monday.toWeekdayValue, 1);
      expect(FirstDayOfWeek.tuesday.toWeekdayValue, 2);
      expect(FirstDayOfWeek.wednesday.toWeekdayValue, 3);
      expect(FirstDayOfWeek.thursday.toWeekdayValue, 4);
      expect(FirstDayOfWeek.friday.toWeekdayValue, 5);
      expect(FirstDayOfWeek.saturday.toWeekdayValue, 6);
      expect(FirstDayOfWeek.sunday.toWeekdayValue, 7);
    });

    test('should have correct display names', () {
      expect(FirstDayOfWeek.monday.displayName, 'Monday');
      expect(FirstDayOfWeek.tuesday.displayName, 'Tuesday');
      expect(FirstDayOfWeek.wednesday.displayName, 'Wednesday');
      expect(FirstDayOfWeek.thursday.displayName, 'Thursday');
      expect(FirstDayOfWeek.friday.displayName, 'Friday');
      expect(FirstDayOfWeek.saturday.displayName, 'Saturday');
      expect(FirstDayOfWeek.sunday.displayName, 'Sunday');
    });

    test('should parse from string correctly', () {
      expect(FirstDayOfWeekX.fromString('monday'), FirstDayOfWeek.monday);
      expect(FirstDayOfWeekX.fromString('sunday'), FirstDayOfWeek.sunday);
      expect(FirstDayOfWeekX.fromString('Friday'), FirstDayOfWeek.friday);
      expect(FirstDayOfWeekX.fromString('WEDNESDAY'), FirstDayOfWeek.wednesday);
    });

    test('should default to Monday when invalid string provided', () {
      expect(FirstDayOfWeekX.fromString('invalid'), FirstDayOfWeek.monday);
      expect(FirstDayOfWeekX.fromString(''), FirstDayOfWeek.monday);
    });
  });
}