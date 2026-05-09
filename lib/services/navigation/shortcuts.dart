import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:miruryoiki/services/navigation/dialogs.dart';
import 'package:miruryoiki/services/navigation/show_info.dart';
import 'package:miruryoiki/theme.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../manager.dart';
import '../../widgets/dialogs/notifications.dart';
import '../library/library_provider.dart';
import '../../utils/logging.dart';
import '../../utils/screen.dart';
import '../library/scanner/scanner_service.dart';
import 'navigation.dart';
import 'statusbar.dart';
import 'intents.dart';

Map<ShortcutActivator, Intent> _buildShortcuts() {
  final bool mac = Manager.isMacOS;
  SingleActivator ctrl(LogicalKeyboardKey key, {bool shift = false, bool alt = false}) => mac //
      ? SingleActivator(key, meta: true, shift: shift, alt: alt)
      : SingleActivator(key, control: true, shift: shift, alt: alt);

  return {
    ctrl(LogicalKeyboardKey.keyR, alt: true, shift: true): const ClearCacheReloadIntent(),
    ctrl(LogicalKeyboardKey.comma): const OpenSettingsIntent(),
    ctrl(LogicalKeyboardKey.keyF): const OpenSearchIntent(),
    ctrl(LogicalKeyboardKey.equal): const ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.numpadAdd, control: !mac, meta: mac): const ZoomInIntent(),
    ctrl(LogicalKeyboardKey.keyH): const ToggleHiddenSeriesIntent(),
    ctrl(LogicalKeyboardKey.keyR): const ReloadLibraryIntent(),
    const SingleActivator(LogicalKeyboardKey.escape): const BackNavigationIntent(),
    const SingleActivator(LogicalKeyboardKey.f1): const DebugDialogIntent(),
    ctrl(LogicalKeyboardKey.digit1): const GoToPaneIntent(NavigationManager.HomeIndex),
    ctrl(LogicalKeyboardKey.digit2): const GoToPaneIntent(NavigationManager.LibraryIndex),
    ctrl(LogicalKeyboardKey.digit3): const GoToPaneIntent(NavigationManager.CalendarIndex),
    ctrl(LogicalKeyboardKey.digit4): const GoToPaneIntent(NavigationManager.BrowseIndex),
    ctrl(LogicalKeyboardKey.digit5): const GoToPaneIntent(NavigationManager.TorrentIndex),
    ctrl(LogicalKeyboardKey.digit6): const GoToPaneIntent(NavigationManager.AccountsIndex),
    ctrl(LogicalKeyboardKey.minus): const ZoomOutIntent(),
    SingleActivator(LogicalKeyboardKey.numpadSubtract, control: !mac, meta: mac): const ZoomOutIntent(),
    if (kDebugMode) ctrl(LogicalKeyboardKey.keyD, shift: true): const ToggleDebugColorIntent(),
  };
}

class KeyboardState {
  static final ValueNotifier<bool> ctrlPressedNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> zoomReleaseNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> shiftPressedNotifier = ValueNotifier<bool>(false);
}

class CustomKeyboardListener extends StatefulWidget {
  final Widget child;

  const CustomKeyboardListener({super.key, required this.child});

  @override
  State<CustomKeyboardListener> createState() => _CustomKeyboardListenerState();
}

class _CustomKeyboardListenerState extends State<CustomKeyboardListener> {
  late final FocusNode _focusNode;
  late final Map<ShortcutActivator, Intent> _shortcuts;
  late final Map<Type, Action<Intent>> _actions;

  BuildContext get ctx => homeKey.currentContext ?? rootNavigatorKey.currentContext ?? context;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    HardwareKeyboard.instance.addHandler(_syncModifierState);
    _shortcuts = _buildShortcuts();
    _actions = {
      // Ctrl + ,
      OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
        onInvoke: (_) => Manager.navigation.pushPaneIndex(NavigationManager.SettingsIndex),
      ),
      // Ctrl + = or Ctrl + Numpad Add
      ZoomInIntent: CallbackAction<ZoomInIntent>(
        onInvoke: (_) {
          _zoom(zoomIn: true);
          KeyboardState.zoomReleaseNotifier.value = !KeyboardState.zoomReleaseNotifier.value;
          return null;
        },
      ),
      // Ctrl + - or Ctrl + Numpad Subtract
      ZoomOutIntent: CallbackAction<ZoomOutIntent>(
        onInvoke: (_) {
          _zoom(zoomIn: false);
          KeyboardState.zoomReleaseNotifier.value = !KeyboardState.zoomReleaseNotifier.value;
          return null;
        },
      ),
      // Ctrl + H
      ToggleHiddenSeriesIntent: CallbackAction<ToggleHiddenSeriesIntent>(
        onInvoke: (_) {
          _handleToggleHiddenSeries();
          return null;
        },
      ),
      // Ctrl + R
      ReloadLibraryIntent: CallbackAction<ReloadLibraryIntent>(
        onInvoke: (_) {
          _handleReloadLibrary();
          return null;
        },
      ),
      // Ctrl + Alt + Shift + R
      ClearCacheReloadIntent: CallbackAction<ClearCacheReloadIntent>(
        onInvoke: (_) {
          _handleClearCacheReload();
          return null;
        },
      ),
      // Esc
      BackNavigationIntent: CallbackAction<BackNavigationIntent>(
        onInvoke: (_) {
          handleBackNavigation(isBackFromEscKey: true);
          return null;
        },
      ),
      // F1
      DebugDialogIntent: CallbackAction<DebugDialogIntent>(
        onInvoke: (_) => showDebugDialog(ctx),
      ),
      // Ctrl + 1-6
      GoToPaneIntent: CallbackAction<GoToPaneIntent>(
        onInvoke: (intent) => Manager.navigation.pushPaneIndex(intent.paneIndex),
      ),
      // Ctrl + Shift + D
      if (kDebugMode)
        ToggleDebugColorIntent: CallbackAction<ToggleDebugColorIntent>(
          onInvoke: (_) {
            Manager.debugGreenEnabled = !Manager.debugGreenEnabled;
            Manager.appTheme.notify();
            Manager.setState();
            return null;
          },
        ),
    };
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_syncModifierState);
    _focusNode.dispose();
    super.dispose();
  }

  /// Keeps [KeyboardState] notifiers in sync with actual hardware modifier state
  ///
  /// Returns false so it never consumes events
  bool _syncModifierState(KeyEvent event) {
    final bool isCtrl = Manager.isMacOS ? HardwareKeyboard.instance.isMetaPressed : HardwareKeyboard.instance.isControlPressed;
    final bool isShift = HardwareKeyboard.instance.isShiftPressed;

    if (KeyboardState.ctrlPressedNotifier.value != isCtrl) {
      KeyboardState.ctrlPressedNotifier.value = isCtrl;
      if (!isCtrl) KeyboardState.zoomReleaseNotifier.value = !KeyboardState.zoomReleaseNotifier.value;
    }

    if (KeyboardState.shiftPressedNotifier.value != isShift) {
      KeyboardState.shiftPressedNotifier.value = isShift;
    }
    return false;
  }

  void _zoom({required bool zoomIn}) {
    final appTheme = Provider.of<AppTheme>(context, listen: false);
    double newFontSize = appTheme.fontSize;
    newFontSize = zoomIn //
        ? (newFontSize + 2).clamp(ScreenUtils.kMinFontSize, ScreenUtils.kMaxFontSize)
        : (newFontSize - 2).clamp(ScreenUtils.kMinFontSize, ScreenUtils.kMaxFontSize);

    final zoomRaw = ScreenUtils.textScaleFactor * (newFontSize / kDefaultFontSize);
    final zoom = calculateZoom(zoomRaw);
    StatusBarManager().show("${(zoom * 100).toInt()}%", autoHideDuration: const Duration(seconds: 2));

    if (newFontSize != appTheme.fontSize) appTheme.fontSize = newFontSize;
    Manager.setState(() {});
  }

  void _handleScrollSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && KeyboardState.ctrlPressedNotifier.value) {
      _zoom(zoomIn: event.scrollDelta.dy < 0);
      KeyboardState.zoomReleaseNotifier.value = !KeyboardState.zoomReleaseNotifier.value;
    }
  }

  double calculateZoom(double zoomRaw) {
    if (zoomRaw >= 171) return 150;
    if (zoomRaw >= 157) return 140;
    if (zoomRaw >= 142) return 130;
    if (zoomRaw >= 128) return 120;
    if (zoomRaw >= 114) return 110;
    if (zoomRaw >= 100) return 100;
    if (zoomRaw >= 85) return 90;
    if (zoomRaw >= 71) return 80;
    if (zoomRaw >= 57) return 70;
    return zoomRaw;
  }

  void _handleToggleHiddenSeries() {
    logTrace('Ctrl + H: Toggle hidden series');
    final library = Provider.of<Library>(context, listen: false);
    final scannerService = Provider.of<LibraryScannerService>(context, listen: false);
    if (library.initialized && !scannerService.isIndexing && homeKey.currentState?.isSeriesView == false) {
      Manager.settings.showHiddenSeries = !Manager.settings.showHiddenSeries;

      snackBar(
        Manager.settings.showHiddenSeries ? 'Hidden series are now visible' : 'Hidden series are now hidden',
        severity: InfoBarSeverity.info,
      );

      // Invalidate data/caches and refresh whichever screen is active
      libraryScreenKey.currentState?.setState(() => libraryScreenKey.currentState?.invalidateSortCache());
      releaseCalendarScreenKey.currentState?.setState(() {});
      homeKey.currentState?.setState(() {});
      notificationsContentKey.currentState?.setState(() => notificationsContentKey.currentState!.refreshNotifications());
    }
  }

  void _handleReloadLibrary() {
    logTrace('Ctrl + R: Reload library');
    final library = Provider.of<Library>(context, listen: false);
    final scannerService = Provider.of<LibraryScannerService>(context, listen: false);

    if (library.initialized && !scannerService.isIndexing) {
      library.reloadLibrary(force: true);
    } else {
      if (!library.initialized) snackBar('Library is not initialized', severity: InfoBarSeverity.warning);
      if (scannerService.isIndexing) snackBar('Library is currently scanning\nPlease wait before reloading', severity: InfoBarSeverity.warning);
    }
  }

  Future<void> _handleClearCacheReload() async {
    logTrace('Ctrl + Alt + Shift + R: Clear cache and reload');
    final library = Provider.of<Library>(context, listen: false);
    final scannerService = Provider.of<LibraryScannerService>(context, listen: false);

    if (!library.initialized || scannerService.isIndexing) {
      if (!library.initialized) snackBar('Library is not initialized', severity: InfoBarSeverity.warning);
      if (scannerService.isIndexing) snackBar('Library is currently scanning\nPlease wait before reloading', severity: InfoBarSeverity.warning);
      return;
    }

    final homeState = homeKey.currentState;
    if (homeState == null || !homeState.mounted) return;

    if (homeState.isSeriesView) {
      final seriesScreenState = seriesScreenKey.currentState;
      snackBar('Clearing Series cache...', severity: InfoBarSeverity.info, autoHide: false);

      if (seriesScreenState != null && seriesScreenState.widget.seriesPath?.pathMaybe != null) {
        seriesScreenState.setState(() => seriesScreenState.isReloadingSeries = true);

        Future.wait([
          library.clearThumbnailCacheForSeries(seriesScreenState.widget.seriesPath),
          library.clearSingleAnilistCache(seriesScreenState.widget.seriesPath),
        ]).then((_) {
          logTrace('Cleared cache for series: ${seriesScreenState.widget.seriesPath?.fileName}');
          imageCache.clear();
          imageCache.clearLiveImages();
        }).catchError((error) {
          logErr('Error clearing cache for series: ${seriesScreenState.widget.seriesPath?.fileName}', error);
        });

        library.reloadLibrary(force: true, showSnackBar: false).then((_) {
          library.clearSingleAnilistCache(seriesScreenState.widget.seriesPath!).then((_) {
            snackBar('Cleared caches and reloaded data!', severity: InfoBarSeverity.success);
            seriesScreenState.setState(() => seriesScreenState.isReloadingSeries = false);
          }).catchError((error, stacktrace) {
            snackBar('Error refetching AniList data after reload', severity: InfoBarSeverity.error, exception: error, stackTrace: stacktrace);
          });
        });
      }
    } else {
      void clearAllCaches() {
        snackBar('Clearing cache for All Series...', severity: InfoBarSeverity.info, autoHide: false);

        Future.wait([
          library.clearAllThumbnailCache(),
          library.clearAnilistCaches(),
        ]).then((_) {
          logTrace('Cleared all thumbnail cache and AniList cache');
          imageCache.clear();
          imageCache.clearLiveImages();
        }).catchError((error) {
          logErr('Error clearing all thumbnail cache and AniList cache', error);
        });

        library.reloadLibrary(force: true, showSnackBar: false).then((_) {
          library.clearAnilistCaches(refetchAfterClear: true).then((_) {
            snackBar('Cleared caches, reloaded, and refetched AniList data!', severity: InfoBarSeverity.success);
          }).catchError((error, stacktrace) {
            snackBar('Error refetching AniList data after reload', severity: InfoBarSeverity.error, exception: error, stackTrace: stacktrace);
          });
        });
      }

      if (Manager.settings.confirmClearAllThumbnails) {
        clearAllCaches();
      } else {
        await showSimpleTickboxManagedDialog(
          Manager.context,
          id: 'system:confirm-clear-caches',
          title: 'Clear All Caches?',
          body: 'Are you sure you want to clear ALL caches?\nThis will clear thumbnails and AniList data for all Series in your Library and they will be refetched when needed.',
          isPositiveButtonPrimary: true,
          hideTitle: false,
          positiveButtonText: 'Clear All Caches',
          negativeButtonText: 'Cancel',
          tickboxLabel: 'Do not show this again',
          onPositive: (bool tickbox) {
            setState(() => Manager.settings.confirmClearAllThumbnails = tickbox);
            clearAllCaches();
          },
        );
      }
    }

    Manager.setState();
  }

  void _handlePointerSignal(PointerDownEvent event) {
    if (event.buttons == kBackMouseButton)
      handleBackNavigation();
    else if (event.buttons == kForwardMouseButton) _handleForwardNavigation();
  }

  /// Returns true if back navigation was performed, false otherwise
  bool handleBackNavigation({bool isBackFromEscKey = false}) {
    if (Manager.navigation.hasDialog) {
      if (!isBackFromEscKey) {
        logTrace('Back Mouse Button Pressed: Closing dialog');
        return Manager.navigation.popDialog();
      }

      final controller = Manager.navigation.currentDialog?.controller;
      if (controller != null && !controller.canPop) {
        logTrace('Dialog has a controller and is locked, routing ESC to controller');
        return controller.onBackRequested();
      }

      logTrace('Closing dialog from back navigation');
      return Manager.navigation.goBack();
    }

    if (Manager.navigation.canGoBack && !isBackFromEscKey) {
      logDebug('Going back in navigation stack -> ${Manager.navigation.stack[Manager.navigation.stack.length - 2].title}');
      return Manager.navigation.goBack();
    }

    logTrace(isBackFromEscKey ? 'Cannot go back to another page with ESC key, use mouse button 4 instead or UI Back Button' : 'No dialog to close and no back navigation available: ${Manager.navigation.currentStackString}');
    return false;
  }

  void _handleForwardNavigation() {
    logTrace('Forward navigation via mouse button 5');
    Manager.navigation.goForward();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerSignal,
      onPointerSignal: _handleScrollSignal,
      child: Shortcuts(
        shortcuts: _shortcuts,
        child: Actions(
          actions: _actions,
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
