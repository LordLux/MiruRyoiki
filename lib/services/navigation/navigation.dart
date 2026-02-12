// ignore_for_file: dead_code, constant_identifier_names

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

  static final Map<int, Map<String, dynamic>> _navigationMap = {
    HomeIndex: {'id': HomeId, 'title': 'Home', 'controller': null},
    LibraryIndex: {'id': LibraryId, 'title': 'Library', 'controller': null},
    CalendarIndex: {'id': CalendarId, 'title': 'Releases', 'controller': null},
    BrowseIndex: {'id': BrowseId, 'title': 'Search', 'controller': null},
    TorrentIndex: {'id': TorrentId, 'title': 'Torrent', 'controller': null},
    AccountsIndex: {'id': AccountsId, 'title': 'Account', 'controller': null},
    SettingsIndex: {'id': SettingsId, 'title': 'Settings', 'controller': null},
  };

  static Map<String, dynamic> get HomeMap => _navigationMap[HomeIndex]!;
  static Map<String, dynamic> get LibraryMap => _navigationMap[LibraryIndex]!;
  static Map<String, dynamic> get CalendarMap => _navigationMap[CalendarIndex]!;
  static Map<String, dynamic> get BrowseMap => _navigationMap[BrowseIndex]!;
  static Map<String, dynamic> get TorrentMap => _navigationMap[TorrentIndex]!;
  static Map<String, dynamic> get AccountsMap => _navigationMap[AccountsIndex]!;
  static Map<String, dynamic> get SettingsMap => _navigationMap[SettingsIndex]!;

  static const int HomeIndex = 0;
  static const int LibraryIndex = 1;
  static const int CalendarIndex = 2;
  static const int BrowseIndex = 3;
  static const int TorrentIndex = 4;
  static const int AccountsIndex = 5;
  static const int SettingsIndex = 6;

  static String get HomeTitle => HomeMap['title'] as String;
  static String get LibraryTitle => LibraryMap['title'] as String;
  static String get CalendarTitle => CalendarMap['title'] as String;
  static String get SearchTitle => BrowseMap['title'] as String;
  static String get TorrentTitle => TorrentMap['title'] as String;
  static String get AccountsTitle => AccountsMap['title'] as String;
  static String get SettingsTitle => SettingsMap['title'] as String;

  static Map<String, dynamic>? getPane(int index) => _navigationMap[index];
  static Map<String, dynamic>? getPaneById(String id) {
    for (final entry in _navigationMap.entries) if (entry.value['id'] == id) return entry.value;
    return null;
  }

  static int? getIndexById(String id) {
    for (final entry in _navigationMap.entries) {
      if (entry.value['id'] == id) return entry.key;
    }
    return null;
  }

  static ScrollController getScrollController(int index) => _navigationMap[index]?['controller'] as ScrollController;
  static void setScrollController(int index, ScrollController controller) => _navigationMap[index]?['controller'] = controller;

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
    final item = getPane(index)!;

    // If we are already at this pane at the top of the stack, don't duplicate
    if (currentView?.level == NavigationLevel.pane && currentView?.id == item['id']) return;

    // Clear Future History
    _forwardStack.clear();

    // Add to Past History
    _pushToStack(NavigationItem(
      id: item['id'],
      title: item['title'],
      level: NavigationLevel.pane,
      data: data,
    ));

    // Visual Navigation
    _navigatorKey.currentState?.pushReplacementNamed('/${item['id']}', arguments: data); // push replacement because we keep the stack ourselves

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
    // _logCurrentStack();
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

  // ignore: unused_element
  void _logCurrentStack() {
    if (kDebugMode) {
      logTrace('----------------------------------------------');
      logTrace('Navigation Stack');
      logTrace(currentStackString, splitLines: false);
      logTrace('----------------------------------------------');
    }
  }

  void navigateToPane(String id) {
    final paneData = getPaneById(id);
    if (paneData != null) {
      // Find index
      int index = -1;
      _navigationMap.forEach((key, value) {
        if (value['id'] == id) index = key;
      });
      if (index != -1) pushPaneIndex(index);
    }
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

bool closeDialog<T>([BuildContext? a]) {
  return Manager.navigation.popDialog();
}
