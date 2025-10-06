import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:miruryoiki/services/navigation/dialogs.dart';
import 'package:miruryoiki/services/navigation/show_info.dart';
import 'package:miruryoiki/services/window/service.dart';
import 'package:miruryoiki/theme.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../manager.dart';
import '../../widgets/dialogs/notifications.dart';
import '../library/library_provider.dart';
import '../../utils/logging.dart';
import '../../utils/screen.dart';
import 'statusbar.dart';

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
  bool isCtrlPressed = false;
  bool isShiftPressed = false;

  bool isSuperPressed(RawKeyDownEvent event) {
    if (Manager.isMacOS) return event.logicalKey == LogicalKeyboardKey.metaLeft || event.logicalKey == LogicalKeyboardKey.metaRight;
    return event.logicalKey == LogicalKeyboardKey.controlLeft || event.logicalKey == LogicalKeyboardKey.controlRight;
  }

  BuildContext get ctx => homeKey.currentContext ?? rootNavigatorKey.currentContext ?? context;

  void _zoom(bool zoomIn) {
    final appTheme = Provider.of<AppTheme>(context, listen: false);
    double newFontSize = appTheme.fontSize;
    newFontSize = zoomIn //
        ? (newFontSize + 2).clamp(ScreenUtils.kMinFontSize, ScreenUtils.kMaxFontSize)
        : (newFontSize - 2).clamp(ScreenUtils.kMinFontSize, ScreenUtils.kMaxFontSize);

    // Snap zoom to nearest allowed value
    final zoomRaw = ScreenUtils.textScaleFactor * (newFontSize / kDefaultFontSize);
    double zoom = calculateZoom(zoomRaw);
    StatusBarManager().show("${(zoom * 100).toInt().toString()}%", autoHideDuration: const Duration(seconds: 2));

    // Only update if changed
    if (newFontSize != appTheme.fontSize) {
      // Update settings
      appTheme.fontSize = newFontSize;
    }
    Manager.setState(() {});
  }

  void _handleScrollSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && isCtrlPressed) {
      // Scrolling up has negative delta.dy, scrolling down has positive
      final bool isScrollingUp = event.scrollDelta.dy < 0;

      // Adjust font size
      _zoom(isScrollingUp);

      KeyboardState.zoomReleaseNotifier.value = !KeyboardState.zoomReleaseNotifier.value;
    }
  }

  double calculateZoom(double zoomRaw) {
    double zoom;
    if (zoomRaw >= 100 && zoomRaw < 114) {
      zoom = 100;
    } else if (zoomRaw >= 114 && zoomRaw < 128) {
      zoom = 110;
    } else if (zoomRaw >= 128 && zoomRaw < 142) {
      zoom = 120;
    } else if (zoomRaw >= 142 && zoomRaw < 157) {
      zoom = 130;
    } else if (zoomRaw >= 157 && zoomRaw < 171) {
      zoom = 140;
    } else if (zoomRaw >= 171) {
      zoom = 150;
    } else if (zoomRaw >= 85 && zoomRaw < 100) {
      zoom = 90;
    } else if (zoomRaw >= 71 && zoomRaw < 85) {
      zoom = 80;
    } else if (zoomRaw >= 57 && zoomRaw < 71) {
      zoom = 70;
    } else {
      zoom = zoomRaw;
    }
    return zoom;
  }

  void _handleKeyPress(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      if (isSuperPressed(event)) {
        isCtrlPressed = true;
        KeyboardState.ctrlPressedNotifier.value = true;
        KeyboardState.zoomReleaseNotifier.value = !KeyboardState.zoomReleaseNotifier.value;
      }
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
        isShiftPressed = true;
        KeyboardState.shiftPressedNotifier.value = true;
      }

      /// Handle specific key combinations
      // Open settings
      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.comma) {
        logTrace('Ctrl + , pressed: Open settings');
        if (homeKey.currentState != null && homeKey.currentState!.mounted) {
          homeKey.currentState!.openSettings();
        }
      } else
      //
      // Open search Palette
      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
        logTrace('Ctrl + f pressed: Search');
      } else
      //
      // Zoom in
      if (isCtrlPressed && (event.logicalKey == LogicalKeyboardKey.equal || event.logicalKey == LogicalKeyboardKey.numpadAdd || event.logicalKey == LogicalKeyboardKey.add)) {
        logTrace('Ctrl + + pressed: Zoom in');
        _zoom(true);
        KeyboardState.zoomReleaseNotifier.value = !KeyboardState.zoomReleaseNotifier.value;
      } else
      //
      // Zoom out
      if (isCtrlPressed && (event.logicalKey == LogicalKeyboardKey.minus || event.logicalKey == LogicalKeyboardKey.numpadSubtract)) {
        logTrace('Ctrl + - pressed: Zoom out');
        _zoom(false);
        KeyboardState.zoomReleaseNotifier.value = !KeyboardState.zoomReleaseNotifier.value;
      } else
      //
      // Toggle hidden series
      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyH) {
        final library = Provider.of<Library>(context, listen: false);
        if (library.initialized && !library.isIndexing && homeKey.currentState?.isSeriesView == false) {
          Manager.settings.showHiddenSeries = !Manager.settings.showHiddenSeries;
          snackBar(
            Manager.settings.showHiddenSeries ? 'Hidden series are now visible' : 'Hidden series are now hidden',
            severity: InfoBarSeverity.info,
          );

          // If in library view, invalidate sort cache to refresh the list
          libraryScreenKey.currentState?.setState(() => libraryScreenKey.currentState?.invalidateSortCache());

          // Refresh release calendar if visible
          releaseCalendarScreenKey.currentState?.setState(() {});

          // Refresh home screen if visible
          homeKey.currentState?.setState(() {});

          // Refresh notifications dialog if visible
          notificationsContentKey.currentState?.setState(() => notificationsContentKey.currentState!.refreshNotifications());
        }
      } else
      //
      // Reload
      if (isCtrlPressed && !isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyR && !HardwareKeyboard.instance.isAltPressed) {
        final library = Provider.of<Library>(context, listen: false);

        if (library.initialized && !library.isIndexing) {
          library.reloadLibrary(force: true);
        } else {
          if (!library.initialized) snackBar('Library is not initialized', severity: InfoBarSeverity.warning);
          if (library.isIndexing) snackBar('Library is currently scanning\nPlease wait before reloading', severity: InfoBarSeverity.warning);
        }
      } else
      //
      // Reload + Clearing all Cache (Ctrl + Alt + Shift + R)
      if (isCtrlPressed && isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyR && HardwareKeyboard.instance.isAltPressed) {
        final library = Provider.of<Library>(context, listen: false);

        if (library.initialized && !library.isIndexing) {
          // Check if we're in series view and clear thumbnails for that series
          final homeState = homeKey.currentState;

          if (homeState != null && homeState.mounted) {
            if (homeState.isSeriesView) {
              final seriesScreenState = getActiveSeriesScreenState();
              snackBar('Clearing Series cache...', severity: InfoBarSeverity.info);

              // Clear thumbnails for the CURRENT SERIES if possible
              if (seriesScreenState != null && seriesScreenState.widget.seriesPath?.pathMaybe != null) {
                seriesScreenState.setState(() => seriesScreenState.isReloadingSeries = true);

                // Clear thumbnails and AniList caches for this specific series (don't await, do it in background)
                Future.wait([
                  library.clearThumbnailCacheForSeries(seriesScreenState.widget.seriesPath),
                  library.clearSingleAnilistCache(seriesScreenState.widget.seriesPath),
                ]).then((_) {
                  logTrace('Cleared cache for series: ${seriesScreenState.widget.seriesPath?.name}');
                  imageCache.clear();
                  imageCache.clearLiveImages();
                }).catchError((error) {
                  logErr('Error clearing cache for series: ${seriesScreenState.widget.seriesPath?.name}', error);
                });

                library.reloadLibrary(force: true, showSnackBar: false).then((_) {
                  // Refetch AniList data after reload completes
                  library.clearSingleAnilistCache(seriesScreenState.widget.seriesPath!).then((_) {
                    snackBar('Cleared caches and reloaded data!', severity: InfoBarSeverity.success);
                    seriesScreenState.setState(() => seriesScreenState.isReloadingSeries = false);
                  }).catchError((error, stacktrace) {
                    snackBar('Error refetching AniList data after reload', severity: InfoBarSeverity.error, exception: error, stackTrace: stacktrace);
                  });
                });
              }
            } else {
              // Not in series view, clear ALL thumbnails after confirmation
              void clearAllCaches() {
                snackBar('Clearing cache for All Series...', severity: InfoBarSeverity.info);

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
                  // Refetch AniList data after reload completes
                  library.clearAnilistCaches(refetchAfterClear: true).then((_) {
                    snackBar('Cleared caches, reloaded, and refetched AniList data!', severity: InfoBarSeverity.success);
                  }).catchError((error, stacktrace) {
                    snackBar('Error refetching AniList data after reload', severity: InfoBarSeverity.error, exception: error, stackTrace: stacktrace);
                  });
                });
              }

              if (Manager.settings.confirmClearAllThumbnails)
                clearAllCaches();
              else
                // Confirm before clearing all thumbnails if the setting is not enabled
                await showSimpleTickboxManagedDialog<bool>(
                  context: context,
                  id: 'confirm_clear_all_thumbnails',
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
        } else {
          if (!library.initialized) snackBar('Library is not initialized', severity: InfoBarSeverity.warning);
          if (library.isIndexing) snackBar('Library is currently scanning\nPlease wait before reloading', severity: InfoBarSeverity.warning);
        }
      } else
      //
      // Esc
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleBackNavigation(isEsc: true);
      } else
      //
      //
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        logTrace('Enter pressed');
      } else
      //
      // Debug
      if (event.logicalKey == LogicalKeyboardKey.f1) {
        logTrace('F1 pressed: Debug');
        showDebugDialog(ctx);
      } else
      //
      // Rename
      if (event.logicalKey == LogicalKeyboardKey.f2) {
        logTrace('F2 pressed: Rename');
      } else
      //
      // Modify path
      if (event.logicalKey == LogicalKeyboardKey.f4) {
        logTrace('F4 pressed: Modify path');
      } else
      //
      // ctrl + N to expand/collapse Nth season
      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit1) {
        _toggleSeason(1);
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit2) {
        _toggleSeason(2);
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit3) {
        _toggleSeason(3);
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit4) {
        _toggleSeason(4);
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit5) {
        _toggleSeason(5);
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit6) {
        _toggleSeason(6);
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit7) {
        _toggleSeason(7);
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit8) {
        _toggleSeason(8);
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit9) {
        _toggleSeason(9);
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit0) {
        _toggleSeason(0);
      } else if (event.logicalKey == LogicalKeyboardKey.f11) {
        WindowStateService.toggleFullScreen();
      }
    } else if (event is RawKeyUpEvent) {
      // Update key states on key release
      if (event.logicalKey == LogicalKeyboardKey.controlLeft || event.logicalKey == LogicalKeyboardKey.controlRight) {
        isCtrlPressed = false;
        KeyboardState.ctrlPressedNotifier.value = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
        isShiftPressed = false;
        KeyboardState.shiftPressedNotifier.value = false;
      }
    }
    setState(() {});
  }

  void _handlePointerSignal(PointerDownEvent event) {
    if (event.buttons == kBackMouseButton)
      _handleBackNavigation();
    else if (event.buttons == kForwardMouseButton) //
      _handleForwardNavigation();
  }

  void _handleBackNavigation({bool isEsc = false}) {
    final homeState = homeKey.currentState;

    if (homeState != null && homeState.mounted) {
      if (homeState.handleBackNavigation(isEsc: isEsc)) {
        // Handled by AppRoot
        return;
      }
    }
  }

  void _handleForwardNavigation() {
    // Implementation for forward navigation would go here
    // You'd need to track forward history separately
  }

  void _toggleSeason(int season) {
    final homeState = homeKey.currentState;
    if (homeState != null && homeState.mounted && homeState.isSeriesView) {
      final seriesScreenState = getActiveSeriesScreenState();

      if (seriesScreenState != null) {
        logTrace('Ctrl + $season pressed: Toggling season $season');
        seriesScreenState.toggleSeasonExpander(season);
      } else {
        logDebug('SeriesScreenState not found');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerSignal,
      onPointerSignal: _handleScrollSignal,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _handleKeyPress,
        child: widget.child,
      ),
    );
  }
}
