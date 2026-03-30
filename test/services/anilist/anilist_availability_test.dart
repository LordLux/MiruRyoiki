import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/anilist/anilist_availability.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AnilistAvailabilityService().reset();
    AnilistAvailabilityService().probeCallback = null;
  });

  group('AnilistAvailabilityService', () {
    test('starts as available', () {
      final service = AnilistAvailabilityService();
      expect(service.isAvailable, true);
      expect(service.isUnavailable, false);
    });

    test('markUnavailable sets the flag', () {
      final service = AnilistAvailabilityService();
      service.markUnavailable();

      expect(service.isUnavailable, true);
      expect(service.isAvailable, false);
    });

    test('markUnavailable notifies listeners', () {
      final service = AnilistAvailabilityService();
      bool notified = false;
      service.unavailableNotifier.addListener(() => notified = true);

      service.markUnavailable();

      expect(notified, true);
    });

    test('markUnavailable is idempotent (no double-flag)', () {
      final service = AnilistAvailabilityService();
      int notifyCount = 0;
      service.unavailableNotifier.addListener(() => notifyCount++);

      service.markUnavailable();
      service.markUnavailable(); // should no-op

      expect(notifyCount, 1);
      expect(service.isUnavailable, true);
    });

    test('flag stays set indefinitely (no auto-clear)', () async {
      final service = AnilistAvailabilityService();
      service.markUnavailable();

      // Wait well past any timer — flag should NOT clear on its own
      // (probe callback is null, so probe is a no-op)
      await Future.delayed(const Duration(milliseconds: 200));
      expect(service.isUnavailable, true);
    });

    test('reset clears the flag immediately', () {
      final service = AnilistAvailabilityService();
      service.markUnavailable();
      expect(service.isUnavailable, true);

      service.reset();
      expect(service.isAvailable, true);
      expect(service.isUnavailable, false);
    });

    test('reset notifies listeners', () {
      final service = AnilistAvailabilityService();
      service.markUnavailable();

      bool notified = false;
      service.unavailableNotifier.addListener(() => notified = true);

      service.reset();
      expect(notified, true);
    });

    test('markAvailable clears the flag', () {
      final service = AnilistAvailabilityService();
      service.markUnavailable();
      expect(service.isUnavailable, true);

      service.markAvailable();
      expect(service.isAvailable, true);
    });

    test('can be marked unavailable again after reset', () {
      final service = AnilistAvailabilityService();
      service.markUnavailable();
      service.reset();
      expect(service.isAvailable, true);

      service.markUnavailable();
      expect(service.isUnavailable, true);
    });
  });
}
