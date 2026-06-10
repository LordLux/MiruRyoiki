// Tests for the MPC-HC slave-mode wiring in MediaPlayerMonitorService,
// focused on the slow-launch window between `tryLaunchViaSlave` and the
// CMD_CONNECT push (no instance tracked yet, facade already connected):
//
//  - a stale mpc-hc process-exit event during the gap must NOT tear the facade down
//  - if something did tear it down, CMD_CONNECT must re-adopt it
//  - normal teardown when the last instance closes still works
//
// Uses a fake MpcSlaveManager (no FFI bridge, no real MPC-HC) injected via
// MediaPlayerMonitorService.debugInjectSlaveSession.

import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/services/di/dependency_injection.dart';
import 'package:miruryoiki/services/library/library_provider.dart';
import 'package:miruryoiki/services/players/media_player_monitor.dart';
import 'package:miruryoiki/services/players/players/mpc_hc_slave_player.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_manager.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:miruryoiki/utils/path.dart';

/// Drives MediaPlayerMonitorService without a real MPC-HC: instance presence is
/// a settable flag and `changes` events are fired manually. Never touches the
/// FFI bridge (`ensureStarted`/`launch`/`pruneDeadInstances`/`dispose` overridden).
class _FakeSlaveManager extends MpcSlaveManager {
  bool fakeHasInstances = false;
  int pruneCalls = 0;
  final StreamController<void> _fakeChanges = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _fakeChanges.stream;

  @override
  bool get hasInstances => fakeHasInstances;

  @override
  Future<bool> ensureStarted() async => true;

  @override
  Future<bool> launch(String exePath, PathString file) async => true;

  @override
  void pruneDeadInstances() => pruneCalls++;

  /// Simulates a CMD_CONNECT / CMD_DISCONNECT bookkeeping change.
  void fireChange() => _fakeChanges.add(null);

  @override
  Future<void> dispose() async {
    if (!_fakeChanges.isClosed) await _fakeChanges.close();
    // Skip super: there is no FFI bridge to stop in tests.
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SettingsManager settings;
  late Library library;
  late MediaPlayerMonitorService monitor;
  late _FakeSlaveManager fake;

  setUp(() {
    ServiceLocator.configureForTest();
    LoggingConfig.usePrintForLogging = true;
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsManager();
    // Keep the constructor from starting process monitoring / player discovery
    settings.enableMediaPlayerIntegration = false;
    library = Library(settings, db);
    monitor = MediaPlayerMonitorService(settings, library);
    fake = _FakeSlaveManager();
  });

  tearDown(() async {
    try {
      await monitor.stop();
    } catch (_) {
      // process monitoring was never started; ignore teardown noise
    }
    ServiceLocator.reset();
    await db.close();
  });

  group('MPC-HC slave slow-launch handling', () {
    test('stale mpc-hc exit event during the launch gap prunes instead of tearing the facade down', () async {
      // State right after tryLaunchViaSlave: facade connected, CMD_CONNECT not yet arrived
      await monitor.debugInjectSlaveSession(fake, launchPending: true, adoptFacade: true);
      expect(monitor.currentConnectedPlayer, 'mpc-hc');

      // Process monitor reports an mpc-hc exit (e.g. an older external window closing)
      monitor.handleSpecificPlayerStopped('mpc-hc64.exe', 'mpc-hc');

      expect(fake.pruneCalls, 1, reason: 'should prune dead instances, not disconnect');
      expect(monitor.playerManager!.currentPlayer, isA<MpcSlavePlayer>(), reason: 'facade must survive the launch gap');
      expect(monitor.currentConnectedPlayer, 'mpc-hc');
    });

    test('CMD_CONNECT re-adopts the facade if it was torn down during a slow launch', () async {
      await monitor.debugInjectSlaveSession(fake, launchPending: true, adoptFacade: true);

      // Simulate the poll path cleaning up the "stale" facade mid-gap
      // (verifyPlayerConnection sees pollStatus() == hasInstances == false)
      await monitor.playerManager!.disconnect();
      expect(monitor.playerManager!.currentPlayer, isNull);

      // MPC-HC finally finishes starting and CMD_CONNECT arrives
      fake.fakeHasInstances = true;
      fake.fireChange();
      await pumpEventQueue();

      expect(monitor.debugSlaveLaunchPending, isFalse, reason: 'launch hold must be released');
      expect(monitor.playerManager!.currentPlayer, isA<MpcSlavePlayer>(), reason: 'facade must be re-adopted');
      expect(monitor.currentConnectedPlayer, 'mpc-hc');
    });

    test('CMD_CONNECT releases the launch hold on the happy path too', () async {
      await monitor.debugInjectSlaveSession(fake, launchPending: true, adoptFacade: true);
      expect(monitor.debugSlaveLaunchPending, isTrue);

      fake.fakeHasInstances = true;
      fake.fireChange();
      await pumpEventQueue();

      expect(monitor.debugSlaveLaunchPending, isFalse);
      expect(monitor.currentConnectedPlayer, 'mpc-hc');
    });

    test('process exit during an active session prunes and keeps the connection', () async {
      await monitor.debugInjectSlaveSession(fake, adoptFacade: true);
      fake.fakeHasInstances = true;
      fake.fireChange();
      await pumpEventQueue();

      // One of several instances dies without CMD_DISCONNECT
      monitor.handleSpecificPlayerStopped('mpc-hc64.exe', 'mpc-hc');

      expect(fake.pruneCalls, 1);
      expect(monitor.currentConnectedPlayer, 'mpc-hc');
      expect(monitor.playerManager!.currentPlayer, isA<MpcSlavePlayer>());
    });

    test('last instance closing drops the facade so the poll path can resume', () async {
      await monitor.debugInjectSlaveSession(fake, adoptFacade: true);
      fake.fakeHasInstances = true;
      fake.fireChange();
      await pumpEventQueue();
      expect(monitor.currentConnectedPlayer, 'mpc-hc');

      fake.fakeHasInstances = false;
      fake.fireChange();
      await pumpEventQueue();

      expect(monitor.currentConnectedPlayer, isNull);
      expect(monitor.playerManager!.currentPlayer, isNull);
    });

    test('non-slave player exit events still go through normal teardown', () async {
      await monitor.debugInjectSlaveSession(fake, adoptFacade: true);
      fake.fakeHasInstances = true;
      fake.fireChange();
      await pumpEventQueue();

      // A VLC exit while the slave session is active must not touch the slave facade
      monitor.handleSpecificPlayerStopped('vlc.exe', 'vlc');

      expect(fake.pruneCalls, 0);
      expect(monitor.currentConnectedPlayer, 'mpc-hc');
    });
  });

  group('enableMpcHcSlaveMode prompt-flag reset', () {
    test('re-enabling slave mode resets the one-time MPC-HC setup prompt', () {
      settings.enableMpcHcSlaveMode = true;
      settings.mpcHcSlavePromptShown = true;

      settings.enableMpcHcSlaveMode = false;
      expect(settings.mpcHcSlavePromptShown, isTrue, reason: 'disabling must not reset the flag');

      settings.enableMpcHcSlaveMode = true;
      expect(settings.mpcHcSlavePromptShown, isFalse, reason: 'turning the toggle back on gives the prompt another chance');
    });

    test('setting the toggle to true when already enabled does not reset the prompt', () {
      settings.enableMpcHcSlaveMode = true;
      settings.mpcHcSlavePromptShown = true;

      settings.enableMpcHcSlaveMode = true;
      expect(settings.mpcHcSlavePromptShown, isTrue);
    });
  });
}
