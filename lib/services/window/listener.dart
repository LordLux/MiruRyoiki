// ignore_for_file: constant_identifier_names

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/services/navigation/dialog_framework.dart';
import 'package:tray_manager/tray_manager.dart';

import '../../utils/icons.dart' as icons;
import '../../widgets/dialogs/show_dialog.dart';
import '../navigation/dialog_functions.dart';
import '../navigation/modifier_key_utils.dart';
import 'dart:io';

import 'package:miruryoiki/main.dart';
import 'package:window_manager/window_manager.dart';

import '../../manager.dart';
import '../../utils/logging.dart';
import '../../utils/time.dart';
import '../../utils/path.dart';
import '../navigation/navigation.dart';
import 'service.dart';

class MyWindowListener extends WindowListener with TrayListener {
  DateTime? lastFocusTime;
  List<DateTime> closeAttempts = [];

  static const String ShowWindowMenuKey = 'show_window';
  static const String ExitAppMenuKey = 'exit_app';
  static const String NavigateHomeMenuKey = 'navigator_home';
  static const String NavigateLibraryMenuKey = 'navigator_library';
  static const String NavigateReleasesMenuKey = 'navigator_releases';
  static const String NavigateBrowseMenuKey = 'navigator_browse';
  static const String NavigateTorrentMenuKey = 'navigator_torrent';
  static const String NavigateAccountMenuKey = 'navigator_account';
  static const String NavigateSettingsMenuKey = 'navigator_settings';

  static const String ShowWindowMenuLabel = 'Show Window';
  static const String NavigateHomeMenuLabel = 'Home';
  static const String NavigateLibraryMenuLabel = 'Library';
  static const String NavigateReleasesMenuLabel = 'Releases';
  static const String NavigateBrowseMenuLabel = 'Browse';
  static const String NavigateTorrentMenuLabel = 'Torrent';
  static const String NavigateAccountMenuLabel = 'Account';
  static const String NavigateSettingsMenuLabel = 'Settings';
  static const String ExitAppMenuLabel = 'Quit';

  void update() => nextFrame(() => Manager.setState());

  Future<void> initSystemTray() async {
    await trayManager.setIcon(Platform.isWindows ? iconPath32 : iconPng);
    await trayManager.setToolTip('MiruRyoiki');

    Menu menu = Menu(
      items: [
        MenuItem(
          key: ShowWindowMenuKey,
          label: ShowWindowMenuLabel,
        ),
        MenuItem.separator(),
        MenuItem(
          key: NavigateHomeMenuKey,
          label: NavigateHomeMenuLabel,
        ),
        MenuItem(
          key: NavigateLibraryMenuKey,
          label: NavigateLibraryMenuLabel,
        ),
        MenuItem(
          key: NavigateReleasesMenuKey,
          label: NavigateReleasesMenuLabel,
        ),
        MenuItem(
          key: NavigateBrowseMenuKey,
          label: NavigateBrowseMenuLabel,
        ),
        MenuItem(
          key: NavigateTorrentMenuKey,
          label: NavigateTorrentMenuLabel,
        ),
        MenuItem.separator(),
        MenuItem(
          key: NavigateAccountMenuKey,
          label: NavigateAccountMenuLabel,
        ),
        MenuItem(
          key: NavigateSettingsMenuKey,
          label: NavigateSettingsMenuLabel,
        ),
        MenuItem.separator(),
        MenuItem(
          icon: icons.anilist,
          key: ExitAppMenuKey,
          label: ExitAppMenuLabel,
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  @override
  void onTrayIconMouseDown() async {
    // Hide if already open, show and focus if hidden
    if (lastFocusTime != null && now.difference(lastFocusTime!).inMilliseconds < 170) {
      hideToTray();
    } else {
      restoreFromTray();
    }
  }

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu(bringAppToFront: true);

  Future<void> _showAndFocus() async => restoreFromTray();

  /// Hides the window to the tray and pauses rendering so no frames are
  /// scheduled and the engine goes idle (GPU ~0%).
  static Future<void> hideToTray() async {
    Manager.renderingEnabled.value = false;
    await windowManager.hide();
  }

  /// Restores the window from the tray (or minimized) and resumes rendering.
  static Future<void> restoreFromTray() async {
    Manager.renderingEnabled.value = true;
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> navigateToMenuKey(int index) async {
    await _showAndFocus();
    homeKey.currentState?.onChangedPane(index);
  }

  @override // TODO fix bug for some reason this gets called when running
  void onTrayMenuItemClick(MenuItem menuItem) {
    // Prevents menu item clicks immediately after opening a dialog
    if (NavigationManager.instance.lastDialogOpenTime != null && now.difference(NavigationManager.instance.lastDialogOpenTime!).inMilliseconds < 100) {
      // This fixes a bug in Tray Manager when for some reason, after the image picker dialog is opened via context menu, this gets called immediately after
      return;
    }

    switch (menuItem.key) {
      case ShowWindowMenuKey:
        _showAndFocus();
      case ExitAppMenuKey:
        performShutdown();
      case NavigateHomeMenuKey:
        navigateToMenuKey(NavigationManager.HomeIndex);
      case NavigateLibraryMenuKey:
        navigateToMenuKey(NavigationManager.LibraryIndex);
      case NavigateReleasesMenuKey:
        navigateToMenuKey(NavigationManager.CalendarIndex);
      case NavigateBrowseMenuKey:
        navigateToMenuKey(NavigationManager.BrowseIndex);
      case NavigateTorrentMenuKey:
        navigateToMenuKey(NavigationManager.TorrentIndex);
      case NavigateAccountMenuKey:
        navigateToMenuKey(NavigationManager.AccountsIndex);
      case NavigateSettingsMenuKey:
        navigateToMenuKey(NavigationManager.SettingsIndex);
    }
  }

  static Future<void> performShutdown() async {
    // Ensure rendering is live so any saving dialog below animates even if we
    // were quit straight from the tray while hidden.
    Manager.renderingEnabled.value = true;
    if (Manager.isDatabaseSaving.value) {
      await windowManager.setPreventClose(true);
      logDebug('Shutdown requested while database is saving, waiting...');
      if (!await windowManager.isVisible()) await windowManager.show();

      final shutdownContext = rootNavigatorKey.currentContext;
      if (shutdownContext != null && shutdownContext.mounted && NavigationManager.instance.currentView?.id != 'system:saving-database') {
        final title = 'Saving Database';
        showPaddedDialog(
          shutdownContext,
          navigationItem: DialogNavigationItem(
            id: 'system:saving-database',
            title: title,
            dialogDoPopCheck: () => false,
          ),
          barrierOptions: PaddedBarrierOptions(userDismissable: false),
          closeExistingDialogs: true,
          builder: (ctx, item, options) {
            return PaddedDialog.simple(
              constraints: const BoxConstraints(maxWidth: 400, minWidth: 400, maxHeight: 300),
              navigationItem: item,
              barrierOptions: options,
              title: Text(title, style: Manager.titleStyle),
              content: Text(
                'Please wait while the database is being saved...\n'
                'The program will close automatically once the process is complete.',
              ),
            );
          },
        );
      }

      while (Manager.isDatabaseSaving.value) await Future.delayed(const Duration(milliseconds: 50));
    }
    logDebug('Shutdown requested, saving window state and closing...');
    await WindowStateService.saveWindowState();
    await windowManager.setPreventClose(false);
    await Manager.closeDB();
    await windowManager.close();
    await windowManager.destroy();
    exit(0); // Manually kill the process to prevent bug where process remains alive after window is closed on Windows which prevents the app from being opened without killing the process first
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      if (Manager.settings.suppressCloseWarning) {
        hideToTray();
        return;
      }

      closeAttempts.add(now);
      closeAttempts.removeWhere((time) => now.difference(time).inSeconds > 30);

      if (closeAttempts.length >= 4) {
        closeAttempts.clear();
        final context = rootNavigatorKey.currentContext;
        if (context == null || !context.mounted) return;
        showSimpleTickboxManagedDialog(
          context,
          id: 'system:close-warning',
          title: 'Quit ${Manager.appTitle}?',
          body: 'You have tried to close the application multiple times recently.\n'
              'Do you want to quit the application completely?',
          positiveButtonText: 'Yes, Quit ${Manager.appTitle}',
          negativeButtonText: 'No, Just hide ${Manager.appTitle}',
          isPositiveButtonPrimary: false,
          tickboxLabel: "Don't show this again warning after multiple close attempts",
          onPositive: (_) => performShutdown(),
          onNegative: (tickboxValue) {
            if (tickboxValue) Manager.settings.suppressCloseWarning = true;
            return hideToTray();
          },
        );
      } else {
        hideToTray();
      }
    }
  }

  @override
  void onWindowFocus() {
    Manager.renderingEnabled.value = true;
    update();
    // Fix stuck modifier keys when regaining focus
    ModifierKeyUtils.checkAndFixModifierKeys();
    super.onWindowFocus();
    // logTrace('Window focused');
  }

  @override
  void onWindowBlur() {
    super.onWindowBlur();
    lastFocusTime = now;
    // logTrace('Window lost focus');
  }

  @override
  void onWindowMaximize() {
    update();
    WindowStateService.saveWindowState();
    super.onWindowMaximize();
    // logTrace('Window maximized');
  }

  @override
  void onWindowUnmaximize() {
    update();
    WindowStateService.saveWindowState();
    super.onWindowUnmaximize();
    // logTrace('Window unmaximized');
  }

  @override
  void onWindowMinimize() {
    // A minimized window already stops compositing, but muting tickers also
    // halts the build/animation work that would otherwise keep the CPU busy.
    Manager.renderingEnabled.value = false;
    update();
    super.onWindowMinimize();
  }

  @override
  void onWindowRestore() {
    Manager.renderingEnabled.value = true;
    update();
    super.onWindowRestore();
  }

  @override
  void onWindowResize() {
    final currentDialogId = NavigationManager.instance.currentView?.id;
    if (currentDialogId == 'library:filters' || currentDialogId == 'library:lists') {
      closeDialog();
    }
    super.onWindowResize();
  }

  @override
  void onWindowResized() {
    update();
    libraryScreenKey.currentState?.measureCardSize();
    WindowStateService.saveWindowState();
    super.onWindowResized();
    // logTrace('Window resized');
  }

  // onWindowMove

  // onWindowMoved

  @override
  void onWindowDocked() {
    update();
    super.onWindowDocked();
    logTrace('Window docked');
  }

  @override
  void onWindowUndocked() {
    update();
    super.onWindowUndocked();
    logTrace('Window undocked');
  }
}
