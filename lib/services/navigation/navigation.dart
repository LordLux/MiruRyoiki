// ignore_for_file: constant_identifier_names

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:miruryoiki/utils/time.dart';

import '../../main.dart';
import '../../manager.dart';
import '../../utils/logging.dart';
import 'dialogs2.dart';

enum NavigationLevel {
  pane, // Top-level navigation items (Library, Settings)
  page, // Secondary screens (Series detail)
  dialog // Overlays on top of pages
}

extension NavigationLevelX on NavigationLevel {
  String get name {
    switch (this) {
      case NavigationLevel.pane:
        return 'Pane';
      case NavigationLevel.page:
        return 'Page';
      case NavigationLevel.dialog:
        return 'Dialog';
    }
  }
}

/// Represents a navigation item in the app's navigation stack.
class NavigationItem {
  /// Unique identifier for the navigation item
  final String id;

  /// Display title for the navigation item
  final String title;

  /// The level of navigation (pane, page, dialog)
  final NavigationLevel level;

  /// Optional data associated with the navigation item
  final Object? data;

  NavigationItem({
    required this.id,
    required this.title,
    required this.level,
    this.data,
  });

  @override
  String toString() => 'NavigationItem(id: $id, title: $title, level: $level, data: $data)';
}

/// Typed definition for a navigation pane (top-level screen).
class PaneDefinition {
  final String id;
  final String title;
  ScrollController? controller;
  PaneDefinition({required this.id, required this.title});
}

class NavigationManager extends ChangeNotifier {
  final GlobalKey<NavigatorState> _navigatorKey;
  NavigationManager(this._navigatorKey);

  static const String HomeId = 'home';
  static const String LibraryId = 'library';
  static const String CalendarId = 'calendar';
  static const String BrowseId = 'search';
  static const String TorrentId = 'torrent';
  static const String AccountsId = 'accounts';
  static const String SettingsId = 'settings';

  static const int HomeIndex = 0;
  static const int LibraryIndex = 1;
  static const int CalendarIndex = 2;
  static const int BrowseIndex = 3;
  static const int TorrentIndex = 4;
  static const int AccountsIndex = 5;
  static const int SettingsIndex = 6;

  static final Map<int, PaneDefinition> _panes = {
    HomeIndex: PaneDefinition(id: HomeId, title: 'Home'),
    LibraryIndex: PaneDefinition(id: LibraryId, title: 'Library'),
    CalendarIndex: PaneDefinition(id: CalendarId, title: 'Releases'),
    BrowseIndex: PaneDefinition(id: BrowseId, title: 'Search'),
    TorrentIndex: PaneDefinition(id: TorrentId, title: 'Torrent'),
    AccountsIndex: PaneDefinition(id: AccountsId, title: 'Account'),
    SettingsIndex: PaneDefinition(id: SettingsId, title: 'Settings'),
  };

  static PaneDefinition get HomePane => _panes[HomeIndex]!;
  static PaneDefinition get LibraryPane => _panes[LibraryIndex]!;
  static PaneDefinition get CalendarPane => _panes[CalendarIndex]!;
  static PaneDefinition get BrowsePane => _panes[BrowseIndex]!;
  static PaneDefinition get TorrentPane => _panes[TorrentIndex]!;
  static PaneDefinition get AccountsPane => _panes[AccountsIndex]!;
  static PaneDefinition get SettingsPane => _panes[SettingsIndex]!;

  static String get HomeTitle => HomePane.title;
  static String get LibraryTitle => LibraryPane.title;
  static String get CalendarTitle => CalendarPane.title;
  static String get SearchTitle => BrowsePane.title;
  static String get TorrentTitle => TorrentPane.title;
  static String get AccountsTitle => AccountsPane.title;
  static String get SettingsTitle => SettingsPane.title;

  static PaneDefinition? getPane(int index) => _panes[index];
  static PaneDefinition? getPaneById(String id) {
    for (final pane in _panes.values) if (pane.id == id) return pane;
    return null;
  }

  static int? getIndexById(String id) {
    for (final entry in _panes.entries) if (entry.value.id == id) return entry.key;
    return null;
  }

  static ScrollController getScrollController(int index) => _panes[index]!.controller!;
  static void setScrollController(int index, ScrollController controller) => _panes[index]?.controller = controller;

  // Scroll offset persistence
  /// Saved scroll offsets keyed by navigation item id
  static final Map<String, double> _savedScrollOffsets = {};

  /// The scroll controller that is currently driving the visible pane's scrollable content
  static ScrollController? _activeScrollController;
  static String? _activePaneId;

  /// Called by [MiruRyoikiTemplatePage] or any screen when its scroll controller becomes available so we can read its offset later
  static void registerActiveScrollController(String paneId, ScrollController controller) {
    _activePaneId = paneId;
    _activeScrollController = controller;
  }

  /// Snapshots the current pane's scroll offset so it can be restored later
  static void saveActiveScrollOffset() {
    if (_activePaneId == null) return;

    // Try the DynMouseScroll-created controller first (template-based screens)
    if (_activeScrollController != null) {
      try {
        if (_activeScrollController!.hasClients) {
          _savedScrollOffsets[_activePaneId!] = _activeScrollController!.offset;
          return;
        }
      } catch (_) {}
    }

    // Fallback: try the main-app-registered controller (Browse, Downloads)
    final paneIndex = getIndexById(_activePaneId!);
    if (paneIndex != null) {
      try {
        final ctrl = getScrollController(paneIndex);
        if (ctrl.hasClients) {
          _savedScrollOffsets[_activePaneId!] = ctrl.offset;
        }
      } catch (_) {}
    }
  }

  /// Returns the saved offset for [paneId], or `null` if none was saved
  static double? getSavedScrollOffset(String paneId) => _savedScrollOffsets[paneId];

  /// Clears a saved offset after a navigation item is popped and we no longer need to restore it
  static void clearSavedScrollOffset(String paneId) => _savedScrollOffsets.remove(paneId);

  /// Restores the scroll offset for the [paneId] on [controller]
  /// Call this from `initState()` in screens that manage their own scroll controller (not via [MiruRyoikiTemplatePage])
  static void restoreScrollOffset(String paneId, ScrollController controller) {
    final saved = getSavedScrollOffset(paneId);
    if (saved == null || saved <= 0) return;
    nextFrame(() {
      if (controller.hasClients) {
        final max = controller.position.maxScrollExtent;
        controller.jumpTo(saved.clamp(0.0, max));
      }
    });
  }

  // State Management
  final List<NavigationItem> _stack = [];
  final List<NavigationItem> _forwardStack = [];
  DialogNavigationItem? _lastPoppedDialog;

  ValueNotifier<bool> stackNotifier = ValueNotifier<bool>(false);

  // Getters
  /// History Stack
  List<NavigationItem> get stack => List.unmodifiable(_stack);

  /// Forward Stack
  List<NavigationItem> get forwardStack => List.unmodifiable(_forwardStack);

  /// Last Popped Dialog
  DialogNavigationItem? get lastPoppedDialog => _lastPoppedDialog;

  /// Current View
  NavigationItem? get currentView => _stack.isNotEmpty ? _stack.last : null;

  bool get hasPane => _stack.isNotEmpty && _stack.last.level == NavigationLevel.pane;
  bool get hasPage => _stack.isNotEmpty && _stack.last.level == NavigationLevel.page;
  bool get hasDialog => _stack.length > 1 && _stack.last.level == NavigationLevel.dialog;
  bool get isDialogLocked => hasDialog && !(_stack.last as DialogNavigationItem).dialogDoPopCheck();

  /// Returns if between the closest pane and the current view there is at least one page.
  bool get isTherePage {
    // Find the last pane index
    final lastPaneIndex = _stack.lastIndexWhere((item) => item.level == NavigationLevel.pane);
    if (lastPaneIndex == -1 || lastPaneIndex == _stack.length - 1) return false;

    // Check if any items between the pane and current view are pages
    return _stack.sublist(lastPaneIndex + 1).any((item) => item.level == NavigationLevel.page);
  }

  bool get canGoBack => _stack.length > 1;
  bool get canGoForward => _forwardStack.isNotEmpty;

  DateTime? _lastDialogOpenTime;
  DateTime? get lastDialogOpenTime => _lastDialogOpenTime;

  /// Pushes a Pane. Adds to history
  void pushPaneIndex(int index, {Object? data}) {
    final pane = getPane(index)!;

    // If we are already at this pane at the top of the stack, don't duplicate
    if (currentView?.level == NavigationLevel.pane && currentView?.id == pane.id) return;

    // Snapshot the current pane's scroll position before replacing the route
    saveActiveScrollOffset();

    // Clear Future History
    _forwardStack.clear();

    // Add to Past History
    _pushToStack(NavigationItem(
      id: pane.id,
      title: pane.title,
      level: NavigationLevel.pane,
      data: data,
    ));

    // Visual Navigation
    _navigatorKey.currentState?.pushReplacementNamed('/${pane.id}', arguments: data); // push replacement because we keep the stack ourselves

    // Specific logic for Calendar
    if (index == CalendarIndex) nextFrame(() => releaseCalendarScreenKey.currentState?.loadReleaseData());
  }

  /// Pushes a Page. Adds to history
  void pushPage(String id, String title, {Object? data}) {
    _forwardStack.clear(); // Wipe future history

    _pushToStack(NavigationItem(
      id: id,
      title: title,
      level: NavigationLevel.page,
      data: data,
    ));

    // Visual Navigation
    _navigatorKey.currentState?.pushNamed(id, arguments: data);
  }

  /// Pushes a Dialog
  bool pushDialog(DialogNavigationItem item) {
    if (isDialogLocked) return false; // Prevent opening new dialog if existing one cannot be closed

    assert(() {
      if (_stack.any((i) => i.id == item.id && i.level == NavigationLevel.dialog)) {
        debugPrint('Warning: duplicate dialog ID "${item.id}"');
      }
      return true;
    }());

    _lastDialogOpenTime = now;
    _pushToStack(item);
    return true;
  }

  void handleDialogPopped(DialogNavigationItem item) {
    // Only remove if it is currently in the stack
    if (_stack.contains(item)) {
      _lastPoppedDialog = item;
      _stack.remove(item);
      item.onDismiss?.call();
      log('[2nd] onDismiss from handleDialogPopped: ${item.id}', color: Colors.white, bgColor: Colors.green);
      item.activeRoute = null; // Cleanup reference
      _notifyChange();
    }
  }

  /// Programmatically pops the top-most dialog
  bool popDialog() {
    if (!hasDialog) return false;
    if (isDialogLocked) return false; // Prevent closing dialog if it cannot be closed

    final item = _stack.last as DialogNavigationItem;

    // Use navigator to pop the route if still active
    if (item.activeRoute != null && item.activeRoute!.isActive) {
      _lastPoppedDialog = item;
      item.activeRoute!.navigator?.pop();
      // route.pop() will trigger the then callback in showManagedDialog which will call _handleDialogPopped
      return true;
    }

    // Fallback if route is lost
    _lastPoppedDialog = item;
    _stack.removeLast();
    _notifyChange();
    return true;
  }

  /// Goes back one step in history.
  /// Handles both visual popping and pane switching.
  bool goBack([bool onlyDialogs = false]) {
    if (!canGoBack) return false;

    // If there's a dialog, try to pop it
    if (hasDialog) return popDialog();

    // If we are only popping dialogs, but the top is not a dialog, do nothing
    if (onlyDialogs) return false;

    // Snapshot scroll position of the current view before navigating away
    saveActiveScrollOffset();

    // Move from Stack to Forward Stack
    final poppedItem = _stack.removeLast();
    _forwardStack.add(poppedItem);

    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      _notifyChange();
      return false; // Navigator not ready
    }

    if (navigator.canPop()) {
      // We are in a sub-page
      // example:
      // |  ⮣ Series
      // |  Library
      // ▼
      navigator.pop();
    } else {
      final destination = _stack.last;
      if (destination.level == NavigationLevel.pane) {
        // We are at a Pane root
        // (e.g., Settings <- Library).
        // example:
        // |  Library
        // |  Settings
        // ▼
        navigator.pushReplacementNamed('/${destination.id}', arguments: destination.data);
      } else {
        // Going back to a Page that was lost from Flutter memory
        // |  Settings
        // |  ⮣ Series A
        // | [Library]
        // ▼
        navigator.pushReplacementNamed(destination.id, arguments: destination.data);
      }
    }

    _notifyChange();
    Manager.setState();
    return true;
  }

  /// Goes forward one step (Re-does the last Back action)
  bool goForward() {
    if (!canGoForward) return false;

    // Snapshot scroll position of the current view before navigating away
    saveActiveScrollOffset();

    // 1. Move from ForwardStack -> Stack
    final itemToRestore = _forwardStack.removeLast();
    _stack.add(itemToRestore);

    // 2. Visual Navigation
    final navigator = _navigatorKey.currentState;

    if (itemToRestore.level == NavigationLevel.pane) {
      // If restoring a Pane, swap to it
      navigator?.pushReplacementNamed('/${itemToRestore.id}', arguments: itemToRestore.data);
    } else {
      // If restoring a Page, push it
      navigator?.pushNamed(itemToRestore.id, arguments: itemToRestore.data);
    }

    _notifyChange();
    return true;
  }

  void _pushToStack(NavigationItem item) {
    _stack.add(item);
    _notifyChange();
  }

  void _notifyChange() {
    nextFrame(delay: 70, () => stackNotifier.value = !stackNotifier.value);
    notifyListeners();
  }

  /// Returns a string representation of the current navigation stack for debugging
  String get currentStackString {
    final buffer = StringBuffer();
    for (int i = 0; i < _forwardStack.length; i++) {
      final item = _forwardStack.reversed.toList()[i];
      buffer.writeln('    ${item.level.name}: ${item.title} (${item.id})');
    }
    for (int i = 0; i < _stack.length; i++) {
      final item = _stack.reversed.toList()[i];
      buffer.writeln('  ${i == 0 ? '→' : ' '} ${item.level.name}: ${item.title} (${item.id})');
    }
    return buffer.toString();
  }

  // TODO: Remove, unused
  @Deprecated('Use pushPaneIndex instead')
  void navigateToPane(String id) {
    final index = getIndexById(id);
    if (index != null) pushPaneIndex(index);
  }

  /// Resets the current pane to its root view by popping all pages on top of it.
  void resetCurrentPane() {
    if (_stack.isEmpty) return;

    // 1. Find the index of the last Pane
    final lastPaneIndex = _stack.lastIndexWhere((item) => item.level == NavigationLevel.pane);
    if (lastPaneIndex == -1) return;

    // If we are already at the pane (and no pages/dialogs on top), do nothing
    if (lastPaneIndex == _stack.length - 1) return;

    // 2. Identify the Pane
    final paneItem = _stack[lastPaneIndex];

    // 3. Update Logical Stack
    // Remove everything after the pane
    _stack.removeRange(lastPaneIndex + 1, _stack.length);

    // Clear forward stack as we are resetting the branch
    _forwardStack.clear();

    // 4. Visual Navigation
    // Pop until we reach the route corresponding to the pane
    _navigatorKey.currentState?.popUntil(ModalRoute.withName('/${paneItem.id}'));

    _notifyChange();
  }

  bool get darkenTitleBar {
    if (!hasDialog) return false;
    final dataAsMap = currentView?.data;
    if (dataAsMap is Map<String, dynamic> && dataAsMap.containsKey('darkenTitleBar')) {
      return (dataAsMap['darkenTitleBar'] as bool);
    }
    return true;
  }

  NavigationItem? get previousView => _stack.length > 1 ? _stack[_stack.length - 2] : null;
  NavigationItem? get nextView => _forwardStack.isNotEmpty ? _forwardStack.last : null;
}

bool closeDialog() => Manager.navigation.popDialog();
