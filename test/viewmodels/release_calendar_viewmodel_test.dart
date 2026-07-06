import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/calendar_entry.dart';
import 'package:miruryoiki/models/notification.dart';
import 'package:miruryoiki/viewmodels/release_calendar_viewmodel.dart';

/// Pure-logic tests for [ReleaseCalendarViewModel]: date selection, list
/// filtering modes, and notification read-status cache updates. Data loading
/// (AniList sync) is not exercised here — the cache is seeded directly via
/// [ReleaseCalendarViewModel.debugSetCalendarCache].

int _sec(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

AiringNotification _notif(int id, DateTime createdAt, {bool isRead = false}) => AiringNotification(
      id: id,
      type: NotificationType.AIRING,
      createdAt: _sec(createdAt),
      isRead: isRead,
      animeId: 100 + id,
      episode: 1,
      contexts: const [],
    );

NotificationCalendarEntry _entry(int id, DateTime createdAt, {bool isRead = false}) => //
    NotificationCalendarEntry(notification: _notif(id, createdAt, isRead: isRead));

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  final today = DateTime.now();
  final todayKey = _day(today);
  final yesterday = today.subtract(const Duration(days: 1));
  final yesterdayKey = _day(yesterday);
  final tomorrow = today.add(const Duration(days: 1));
  final tomorrowKey = _day(tomorrow);

  ReleaseCalendarViewModel seeded() {
    final vm = ReleaseCalendarViewModel();
    vm.debugSetCalendarCache({
      yesterdayKey: [_entry(1, yesterday), _entry(2, yesterday, isRead: true)],
      todayKey: [_entry(3, today)],
      tomorrowKey: [_entry(4, tomorrow)],
    });
    return vm;
  }

  group('unread count', () {
    test('counts only unread notifications across all days', () {
      expect(seeded().unreadCount, 3);
    });

    test('applyNotificationRead flips a single notification and notifies', () {
      final vm = seeded();
      var notified = 0;
      vm.addListener(() => notified++);

      vm.applyNotificationRead(1);

      expect(vm.unreadCount, 2);
      expect(notified, 1);
      final yesterdayEntries = vm.calendarCache[yesterdayKey]!.whereType<NotificationCalendarEntry>();
      expect(yesterdayEntries.firstWhere((e) => e.notification.id == 1).notification.isRead, isTrue);
    });

    test('applyAllNotificationsRead flips everything', () {
      final vm = seeded();
      vm.applyAllNotificationsRead();
      expect(vm.unreadCount, 0);
    });
  });

  group('visibleEntriesByDate', () {
    test('default view on today hides days before today', () {
      final vm = seeded();
      final visible = vm.visibleEntriesByDate;
      expect(visible.containsKey(yesterdayKey), isFalse);
      expect(visible.containsKey(todayKey), isTrue);
      expect(visible.containsKey(tomorrowKey), isTrue);
    });

    test('toggleOlderNotifications(true) reveals past days', () {
      final vm = seeded();
      final turnedOn = vm.toggleOlderNotifications(true);
      expect(turnedOn, isTrue);
      expect(vm.visibleEntriesByDate.containsKey(yesterdayKey), isTrue);
    });

    test('today-only filter shows only today', () {
      final vm = seeded();
      vm.toggleTodayFilter(true);
      final visible = vm.visibleEntriesByDate;
      expect(visible.keys.toList(), [todayKey]);
    });

    test('selecting a date with entries shows only that date', () {
      final vm = seeded();
      vm.selectDate(tomorrowKey);
      expect(vm.filterSelectedDate, isTrue);
      expect(vm.visibleEntriesByDate.keys.toList(), [tomorrowKey]);
    });

    test('selecting an empty date shows nothing until older toggled', () {
      final vm = seeded();
      final emptyDay = _day(today.add(const Duration(days: 10)));
      vm.selectDate(emptyDay);
      expect(vm.visibleEntriesByDate, isEmpty);
      expect(vm.shouldShowOlderButton, isTrue);

      vm.toggleOlderNotifications(true);
      // Reveals everything (all-dates mode)
      expect(vm.visibleEntriesByDate.containsKey(yesterdayKey), isTrue);
    });

    test('re-selecting the selected date clears the filter', () {
      final vm = seeded();
      vm.selectDate(tomorrowKey);
      expect(vm.filterSelectedDate, isTrue);
      vm.selectDate(tomorrowKey);
      expect(vm.filterSelectedDate, isFalse);
    });

    test('selecting today never keeps the date filter', () {
      final vm = seeded();
      vm.selectDate(tomorrowKey);
      vm.selectDate(todayKey);
      expect(vm.filterSelectedDate, isFalse);
      expect(vm.isSelectedToday, isTrue);
    });
  });

  group('older-notifications button', () {
    test('offered on today by default, gone once toggled', () {
      final vm = seeded();
      expect(vm.shouldShowOlderButton, isTrue);
      vm.toggleOlderNotifications(true);
      expect(vm.shouldShowOlderButton, isFalse);
    });
  });

  group('month navigation', () {
    test('previous/next month move focusedMonth; focusToday resets', () {
      final vm = seeded();
      final startMonth = vm.focusedMonth.month;
      vm.nextMonth();
      expect(vm.focusedMonth.month, (startMonth % 12) + 1);
      vm.focusToday();
      expect(vm.focusedMonth.month, DateTime.now().month);
      expect(vm.filterSelectedDate, isFalse);
    });
  });
}
