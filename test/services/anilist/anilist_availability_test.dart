import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/anilist/anilist_availability.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset state before each test
    AnilistAvailabilityService().reset();
  });

  group('AnilistAvailabilityService', () {
    test('starts as available', () {
      final service = AnilistAvailabilityService();
      expect(service.isAvailable, true);
      expect(service.isUnavailable, false);
    });

    test('markUnavailable sets the flag', () {
      final service = AnilistAvailabilityService();
      service.markUnavailable(recheckDelay: const Duration(minutes: 5));

      expect(service.isUnavailable, true);
      expect(service.isAvailable, false);
    });

    test('markUnavailable notifies listeners', () {
      final service = AnilistAvailabilityService();
      bool notified = false;
      service.unavailableNotifier.addListener(() => notified = true);

      service.markUnavailable(recheckDelay: const Duration(minutes: 5));

      expect(notified, true);
    });

    test('markUnavailable is idempotent (no double-flag)', () {
      final service = AnilistAvailabilityService();
      int notifyCount = 0;
      service.unavailableNotifier.addListener(() => notifyCount++);

      service.markUnavailable(recheckDelay: const Duration(minutes: 5));
      service.markUnavailable(recheckDelay: const Duration(minutes: 5)); // should no-op

      expect(notifyCount, 1);
      expect(service.isUnavailable, true);
    });

    test('reset clears the flag immediately', () {
      final service = AnilistAvailabilityService();
      service.markUnavailable(recheckDelay: const Duration(minutes: 5));
      expect(service.isUnavailable, true);

      service.reset();
      expect(service.isAvailable, true);
      expect(service.isUnavailable, false);
    });

    test('reset notifies listeners', () {
      final service = AnilistAvailabilityService();
      service.markUnavailable(recheckDelay: const Duration(minutes: 5));

      bool notified = false;
      service.unavailableNotifier.addListener(() => notified = true);

      service.reset();
      expect(notified, true);
    });

    test('auto-clears after recheckDelay', () async {
      final service = AnilistAvailabilityService();
      service.markUnavailable(recheckDelay: const Duration(milliseconds: 100));

      expect(service.isUnavailable, true);

      // Wait for the timer to fire
      await Future.delayed(const Duration(milliseconds: 200));

      expect(service.isAvailable, true);
    });

    test('reset cancels the auto-clear timer', () async {
      final service = AnilistAvailabilityService();
      service.markUnavailable(recheckDelay: const Duration(milliseconds: 100));
      service.reset();

      // The flag is already cleared by reset
      expect(service.isAvailable, true);

      // Wait past the original timer — should stay available (timer was cancelled)
      await Future.delayed(const Duration(milliseconds: 200));
      expect(service.isAvailable, true);
    });

    test('can be marked unavailable again after reset', () {
      final service = AnilistAvailabilityService();
      service.markUnavailable(recheckDelay: const Duration(minutes: 5));
      service.reset();
      expect(service.isAvailable, true);

      service.markUnavailable(recheckDelay: const Duration(minutes: 5));
      expect(service.isUnavailable, true);
    });

    test('can be marked unavailable again after auto-clear', () async {
      final service = AnilistAvailabilityService();
      service.markUnavailable(recheckDelay: const Duration(milliseconds: 50));

      await Future.delayed(const Duration(milliseconds: 100));
      expect(service.isAvailable, true);

      service.markUnavailable(recheckDelay: const Duration(minutes: 5));
      expect(service.isUnavailable, true);

      service.reset(); // cleanup
    });
  });
}
