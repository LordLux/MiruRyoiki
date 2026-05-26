// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/lock_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('LockManager Lock Behavior Tests', () {
    late LockManager lockManager;

    setUp(() {
      lockManager = LockManager();
      // Clear any existing state from previous tests
      lockManager.clearState();
    });

    test('Patient user scenario: sequential operations work perfectly', () async {
      print('[TEST] Testing patient user who waits for operations to complete...');
      
      // 1. Library scan (2 seconds)
      print('[LIBRARY] Starting library scan...');
      final libraryScanHandle = await lockManager.acquireLock(
        OperationType.libraryScanning,
        description: 'scanning library',
        waitForOthers: false,
      );
      
      expect(libraryScanHandle, isNotNull, reason: 'Library scan should acquire lock');
      expect(lockManager.currentOperationDescription, equals('scanning library'));
      print('[SUCCESS] Library scan started: ${lockManager.currentOperationDescription}');
      
      // Simulate 2 seconds of work
      await Future.delayed(const Duration(seconds: 2));
      libraryScanHandle!.dispose();
      print('[SUCCESS] Library scan completed');
      
      // 2. Dominant color calculation (2 seconds)  
      print('[COLOR] Starting dominant color calculation...');
      final colorHandle = await lockManager.acquireLock(
        OperationType.dominantColorCalculation,
        description: 'calculating dominant colors',
        waitForOthers: false,
      );
      
      expect(colorHandle, isNotNull, reason: 'Color calculation should acquire lock');
      expect(lockManager.currentOperationDescription, equals('calculating dominant colors'));
      print('[SUCCESS] Color calculation started: ${lockManager.currentOperationDescription}');
      
      // Simulate 2 seconds of work
      await Future.delayed(const Duration(seconds: 2));
      colorHandle!.dispose();
      print('[SUCCESS] Color calculation completed');
      
      // 3. Database save (fast)
      print('[DATABASE] Starting database save...');
      final dbHandle = await lockManager.acquireLock(
        OperationType.databaseSave,
        description: 'saving to database',
        waitForOthers: true,
      );
      
      expect(dbHandle, isNotNull, reason: 'Database save should acquire lock');
      expect(lockManager.currentOperationDescription, equals('saving to database'));
      print('[SUCCESS] Database save started: ${lockManager.currentOperationDescription}');
      
      // Simulate fast database work
      await Future.delayed(const Duration(milliseconds: 500));
      dbHandle!.dispose();
      print('[SUCCESS] Database save completed');
      
      expect(lockManager.hasActiveOperations, isFalse, reason: 'No operations should be active');
      print('[DONE] Patient user test completed successfully!');
    });

    test('Overlap scenario: library scan blocks dominant color calculation', () async {
      print('[TEST] Testing overlap: library scan should block color calculation...');
      
      // Start library scan
      final libraryScanHandle = await lockManager.acquireLock(
        OperationType.libraryScanning,
        description: 'scanning library',
        waitForOthers: false,
      );
      
      expect(libraryScanHandle, isNotNull);
      print('[LIBRARY] Library scan started: ${lockManager.currentOperationDescription}');
      
      // Try to start color calculation while library scan is running
      final colorHandle = await lockManager.acquireLock(
        OperationType.dominantColorCalculation,
        description: 'calculating colors',
        waitForOthers: false,
      );
      
      expect(colorHandle, isNull, reason: 'Color calculation should be blocked');
      print('[BLOCKED] Color calculation blocked as expected');
      
      final blockMessage = lockManager.getDisabledReason(UserAction.calculateDominantColors);
      expect(blockMessage, contains('scanning library'));
      print('[INFO] Block message: "$blockMessage"');
      
      // Finish library scan
      libraryScanHandle!.dispose();
      print('[SUCCESS] Library scan completed');
      
      // Now color calculation should work
      final colorHandleAfter = await lockManager.acquireLock(
        OperationType.dominantColorCalculation,
        description: 'calculating colors',
        waitForOthers: false,
      );
      
      expect(colorHandleAfter, isNotNull, reason: 'Color calculation should work after library scan');
      print('[SUCCESS] Color calculation now works');
      colorHandleAfter!.dispose();
      
      print('[DONE] Overlap blocking test completed successfully!');
    });

    test('Database save queueing: can wait behind library scan', () async {
      print('[TEST] Testing database save queueing behind library scan...');
      
      // Start library scan
      final libraryScanHandle = await lockManager.acquireLock(
        OperationType.libraryScanning,
        description: 'scanning library',
        waitForOthers: false,
      );
      
      expect(libraryScanHandle, isNotNull);
      print('[LIBRARY] Library scan started');
      
      // Start database save that should queue
      bool dbSaveCompleted = false;
      print('[DATABASE] Starting database save (should queue)...');
      
      final dbSaveFuture = lockManager.acquireLock(
        OperationType.databaseSave,
        description: 'saving episode status',
        waitForOthers: true,
      ).then((handle) async {
        expect(handle, isNotNull);
        print('[DATABASE] Database save started after library scan finished');
        // Simulate quick database work
        await Future.delayed(const Duration(milliseconds: 200));
        handle!.dispose();
        dbSaveCompleted = true;
        print('[SUCCESS] Database save completed');
      });
      
      // Database save should be waiting
      await Future.delayed(const Duration(milliseconds: 500));
      expect(dbSaveCompleted, isFalse, reason: 'Database save should still be waiting');
      print('[WAITING] Database save is waiting as expected');
      
      // Finish library scan
      await Future.delayed(const Duration(milliseconds: 500));
      libraryScanHandle!.dispose();
      print('[SUCCESS] Library scan completed, releasing database save');
      
      // Database save should now complete
      await dbSaveFuture;
      expect(dbSaveCompleted, isTrue, reason: 'Database save should have completed');
      
      print('[DONE] Database save queueing test completed successfully!');
    });

    test('Database save queue limit: only 1 operation can queue', () async {
      print('[TEST] Testing database save queue limit (max 1 in queue)...');
      
      // Start first database save
      final firstDbHandle = await lockManager.acquireLock(
        OperationType.databaseSave,
        description: 'first save',
        waitForOthers: true,
      );
      
      expect(firstDbHandle, isNotNull);
      print('[DATABASE] First database save started');
      
      // Start second database save (should queue)
      bool secondDbStarted = false;
      print('[DATABASE] Starting second database save (should queue)...');
      
      final secondDbFuture = lockManager.acquireLock(
        OperationType.databaseSave,
        description: 'second save',
        waitForOthers: true,
      ).then((handle) {
        expect(handle, isNotNull);
        print('[DATABASE] Second database save started');
        secondDbStarted = true;
        handle!.dispose();
        print('[SUCCESS] Second database save completed');
      });
      
      // Try third database save (should be rejected - queue full)
      print('[DATABASE] Trying third database save (should be rejected)...');
      final thirdDbHandle = await lockManager.acquireLock(
        OperationType.databaseSave,
        description: 'third save',
        waitForOthers: true,
      );
      
      expect(thirdDbHandle, isNull, reason: 'Third database save should be rejected when queue is full');
      print('[BLOCKED] Third database save rejected as expected (queue full)');
      
      // Complete first save
      await Future.delayed(const Duration(milliseconds: 200));
      firstDbHandle!.dispose();
      print('[SUCCESS] First database save completed');
      
      // Second save should now complete
      await secondDbFuture;
      expect(secondDbStarted, isTrue);
      
      print('[DONE] Database save queue limit test completed successfully!');
    });

    test('Other operations can queue behind database save (your specific scenario)', () async {
      print('[TEST] Testing OTHER operations queueing behind database save...');
      
      // Start database save
      final dbHandle = await lockManager.acquireLock(
        OperationType.databaseSave,
        description: 'saving user data',
        waitForOthers: true,
      );
      
      expect(dbHandle, isNotNull);
      print('[DATABASE] Database save started: ${lockManager.currentOperationDescription}');
      print('[STATUS] Active operations: ${lockManager.activeOperations}');
      print('[LOCK] Has active operations: ${lockManager.hasActiveOperations}');
      
      // Try to start library scan while database save is running (should queue)
      bool libraryScanStarted = false;
      print('[LIBRARY] Starting library scan while database save is running (should queue)...');
      
      final libraryScanFuture = lockManager.acquireLock(
        OperationType.libraryScanning,
        description: 'scanning library',
        waitForOthers: true,
      ).then((handle) async {
        print('[LIBRARY] Library scan handle result: ${handle != null ? "NOT NULL" : "NULL"}');
        if (handle != null) {
          print('[LIBRARY] Library scan started after database save finished');
          libraryScanStarted = true;
          
          // Simulate library scan work
          await Future.delayed(const Duration(milliseconds: 300));
          handle.dispose();
          print('[SUCCESS] Library scan completed');
        } else {
          print('[ERROR] Library scan handle was null!');
        }
      }).catchError((error) {
        print('[ERROR] Library scan future error: $error');
      });
      
      // Library scan should be waiting
      await Future.delayed(const Duration(milliseconds: 200));
      expect(libraryScanStarted, isFalse, reason: 'Library scan should be waiting for database save');
      print('[WAITING] Library scan is waiting behind database save as expected');
      
      // Try to start dominant color calculation (should be rejected - queue full)
      print('[COLOR] Trying to start color calculation (should be rejected - queue full)...');
      final colorHandle = await lockManager.acquireLock(
        OperationType.dominantColorCalculation,
        description: 'calculating colors',
        waitForOthers: true,
      );
      
      expect(colorHandle, isNull, reason: 'Color calculation should be rejected - queue is full');
      print('[BLOCKED] Color calculation rejected as expected (queue is full)');
      
      // Complete database save
      await Future.delayed(const Duration(milliseconds: 200));
      print('[DATABASE] Completing database save...');
      dbHandle!.dispose();
      print('[SUCCESS] Database save completed, should release library scan');
      
      // Wait a bit for the library scan to start
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Library scan should now complete
      await libraryScanFuture;
      expect(libraryScanStarted, isTrue, reason: 'Library scan should have started after database save completed');
      
      print('[DONE] Other operations queuing behind database save test completed successfully!');
    });

    test('User action blocking: correct messages during operations', () async {
      print('[TEST] Testing user action blocking and messages...');
      
      // TEST 1: During library scan - ALL dangerous operations should be blocked
      print('[LIBRARY] Testing during library scan...');
      final libraryScanHandle = await lockManager.acquireLock(
        OperationType.libraryScanning,
        description: 'scanning library',
        waitForOthers: false,
      );
      
      // All user actions should be blocked during library scan
      expect(lockManager.shouldDisableAction(UserAction.markEpisodeWatched), isTrue, 
             reason: 'Episode marking should be blocked during library scan');
      expect(lockManager.shouldDisableAction(UserAction.scanLibrary), isTrue,
             reason: 'Duplicate library scan should be blocked');
      expect(lockManager.shouldDisableAction(UserAction.calculateDominantColors), isTrue,
             reason: 'Color calculation should be blocked during library scan');
      expect(lockManager.shouldDisableAction(UserAction.anilistOperations), isTrue,
             reason: 'AniList operations should be blocked during library scan');
      
      final message = lockManager.getDisabledReason(UserAction.markEpisodeWatched);
      expect(message, contains('scanning library'));
      print('[INFO] Block message during library scan: "$message"');
      
      libraryScanHandle!.dispose();
      print('[SUCCESS] Library scan test completed');
      
      // TEST 2: During dominant color calculation - ALL dangerous operations should be blocked
      print('[COLOR] Testing during dominant color calculation...');
      final colorHandle = await lockManager.acquireLock(
        OperationType.dominantColorCalculation,
        description: 'calculating dominant colors',
        waitForOthers: false,
      );
      
      // All dangerous user actions should be blocked during color calculation
      expect(lockManager.shouldDisableAction(UserAction.markEpisodeWatched), isTrue,
             reason: 'Episode marking should be blocked during color calculation');
      expect(lockManager.shouldDisableAction(UserAction.scanLibrary), isTrue,
             reason: 'Library scan should be blocked during color calculation'); // THIS WAS FAILING
      expect(lockManager.shouldDisableAction(UserAction.calculateDominantColors), isTrue,
             reason: 'Duplicate color calculation should be blocked');
      expect(lockManager.shouldDisableAction(UserAction.anilistOperations), isTrue,
             reason: 'AniList operations should be blocked during color calculation');
      
      final colorMessage = lockManager.getDisabledReason(UserAction.scanLibrary);
      expect(colorMessage, contains('calculating dominant colors'));
      print('[INFO] Block message during color calculation: "$colorMessage"');
      
      colorHandle!.dispose();
      print('[SUCCESS] Color calculation test completed');
      
      // TEST 3: During database save - only database operations might be restricted
      print('[DATABASE] Testing during database save...');
      final dbHandle = await lockManager.acquireLock(
        OperationType.databaseSave,
        description: 'saving data',
        waitForOthers: true,
      );
      
      // Database save shouldn't block other dangerous operations (it's fast)
      // But user actions that modify data should still be blocked to prevent conflicts
      expect(lockManager.shouldDisableAction(UserAction.markEpisodeWatched), isTrue,
             reason: 'Episode marking should be blocked during database save to prevent conflicts');
      
      // But dangerous operations like scan/color should still be allowed to queue
      // (they will queue behind the database save)
      
      dbHandle!.dispose();
      print('[SUCCESS] Database save test completed');
      
      print('[DONE] User action blocking test completed successfully!');
    });
  });
}
