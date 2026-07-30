// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:meta/meta.dart';
import 'package:video_data_utils/video_data_utils.dart';
import 'package:flutter_anitomy/flutter_anitomy.dart';

import '../../utils/shell.dart';

/// A simple Dependency Injector configured differently across environments
class ServiceLocator {
  static IShellUtils? _shellUtils;
  static IShellUtils get shellUtils => _shellUtils ??= RealShellUtils();
  static set shellUtils(IShellUtils value) => _shellUtils = value;
  
  /// whether BackgroundIsolateBinaryMessenger.ensureInitialized is required
  static bool? _requireBackgroundIsolateBinaryMessenger;
  static bool get requireBackgroundIsolateBinaryMessenger => _requireBackgroundIsolateBinaryMessenger ?? true;
  static set requireBackgroundIsolateBinaryMessenger(bool value) => _requireBackgroundIsolateBinaryMessenger = value;

  /// whether to spawn an actual alternate isolate
  static bool? _spawnIsolates;
  static bool get spawnIsolates => _spawnIsolates ?? true;
  static set spawnIsolates(bool value) => _spawnIsolates = value;

  /// whether to ensure WidgetsBinding is initialized inside the background isolate
  static bool? _initializeWidgetsBindingInIsolates;
  static bool get initializeWidgetsBindingInIsolates => _initializeWidgetsBindingInIsolates ?? true;
  static set initializeWidgetsBindingInIsolates(bool value) => _initializeWidgetsBindingInIsolates = value;

  /// Replace native services with mock counterparts
  /// 
  /// WARNING: This method performs a global side effect by setting testingMode to true to mock OS-level file access
  /// 
  /// Remember to call `reset()` to ensure testingMode doesn't leak into subsequent tests
  @visibleForTesting
  static void configureForTest() {
    VideoDataUtils.testingMode = true;
    FlutterAnitomy.testingMode = true;
    FlutterAnitomy.setMockData(ParsedAnime.mock(
      episode: '1',
      episodeTitle: 'Test Episode'
    ));

    _shellUtils = MockShellUtils();
    _requireBackgroundIsolateBinaryMessenger = false;
    _spawnIsolates = false;
    _initializeWidgetsBindingInIsolates = false;
  }

  /// Reset the locator to its original production state
  /// 
  /// WARNING: This method performs a global side effect by setting the testingMode flags back to false
  @visibleForTesting
  static void reset() {
    VideoDataUtils.testingMode = false;
    FlutterAnitomy.testingMode = false;
    
    _shellUtils = null;
    _requireBackgroundIsolateBinaryMessenger = null;
    _spawnIsolates = null;
    _initializeWidgetsBindingInIsolates = null;
  }
}

