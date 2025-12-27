// ignore_for_file: dead_code, constant_identifier_names

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:miruryoiki/utils/time.dart';

import '../../main.dart';
import '../../utils/logging.dart';

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

class NavigationItem {
  final String id;
  final String title;
  final NavigationLevel level;
  final Object? data;

  NavigationItem({
    required this.id,
    required this.title,
    required this.level,
    this.data,
  });

  @override
  String toString() => 'NavigationItem(id: $id, title: $title, level: $level)';
}

class NavigationManager extends ChangeNotifier {
  final GlobalKey<NavigatorState> _navigatorKey;
  NavigationManager(this._navigatorKey);

  static final Map<int, Map<String, dynamic>> _navigationMap = {
    HomeIndex: {'id': 'home', 'title': 'Home', 'controller': null},
    LibraryIndex: {'id': 'library', 'title': 'Library', 'controller': null},
    CalendarIndex: {'id': 'calendar', 'title': 'Releases', 'controller': null},
    BrowseIndex: {'id': 'search', 'title': 'Search', 'controller': null},
    TorrentIndex: {'id': 'torrent', 'title': 'Torrent', 'controller': null},
    AccountsIndex: {'id': 'accounts', 'title': 'Account', 'controller': null},
    SettingsIndex: {'id': 'settings', 'title': 'Settings', 'controller': null},
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

  static String get HomeId => HomeMap['id'] as String;
  static String get LibraryId => LibraryMap['id'] as String;
  static String get CalendarId => CalendarMap['id'] as String;
  static String get BrowseId => BrowseMap['id'] as String;
  static String get TorrentId => TorrentMap['id'] as String;
  static String get AccountsId => AccountsMap['id'] as String;
  static String get SettingsId => SettingsMap['id'] as String;

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

  ValueNotifier<bool> stackNotifier = ValueNotifier<bool>(false);

  // Getters
  /// History Stack
  List<NavigationItem> get stack => List.unmodifiable(_stack);

  /// Forward Stack
  List<NavigationItem> get forwardStack => List.unmodifiable(_forwardStack);

  /// Current View
  NavigationItem? get currentView => _stack.isNotEmpty ? _stack.last : null;

  bool get hasPane => _stack.isNotEmpty && _stack.last.level == NavigationLevel.pane;
  bool get hasPage => _stack.isNotEmpty && _stack.last.level == NavigationLevel.page;
  bool get hasDialog => _stack.length > 1 && _stack.last.level == NavigationLevel.dialog;

  bool get canGoBack => _stack.length > 1;
  bool get canGoForward => _forwardStack.isNotEmpty;

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
  void pushDialog(String id, String title, {Object? data}) {
    // We usually don't clear forward stack for dialogs as they are transient
    _pushToStack(NavigationItem(
      id: id,
      title: title,
      level: NavigationLevel.dialog,
      data: data,
    ));
  }

  /// Goes back one step in history.
  /// Handles both visual popping and pane switching.
  bool goBack() {
    if (!canGoBack) return false;

    // 1. Identify what we are removing
    final itemToRemove = _stack.last;

    // 2. Handle Dialogs (Transient)
    // We don't add dialogs to forward history
    if (itemToRemove.level == NavigationLevel.dialog) {
      // We DO NOT remove from stack here. The dialog's 'then' callback (in showManagedDialog)
      // will handle the logical stack removal when the visual pop completes.
      // We just trigger the visual pop.
      if (_navigatorKey.currentState?.canPop() == true) _navigatorKey.currentState?.pop();
      
      return true;
    }

    // 3. Move from Stack -> ForwardStack
    final poppedItem = _stack.removeLast();
    _forwardStack.add(poppedItem);

    // 4. Determine the DESTINATION (The new top of the stack)
    final destination = _stack.last;

    // 5. Visual Navigation Logic
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      _notifyChange();
      return true;
    }

    if (navigator.canPop()) {
      // SCENARIO A: We are in a sub-page (e.g., Home -> Series).
      // The Flutter stack matches our logical stack. Just pop.
      navigator.pop();
    } else {
      // SCENARIO B: We are at a Pane root (e.g., Home -> Library).
      // We cannot 'pop' because pushReplacement was used.
      // We must manually navigate to the previous item.

      if (destination.level == NavigationLevel.pane) {
        navigator.pushReplacementNamed('/${destination.id}', arguments: destination.data);
      } else {
        // Edge Case: Going back to a Page that was lost from Flutter memory
        // (e.g. Home -> Series A -> Library -> Back).
        // The Flutter stack for 'Series A' is gone. We must recreate it.
        // Strategy: Go to the ID directly.
        navigator.pushReplacementNamed(destination.id, arguments: destination.data);
      }
    }

    _notifyChange();
    return true;
  }

  /// Goes forward one step (Re-does the last Back action).
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

  /// Helper specifically for Dialogs
  bool popDialog() {
    if (!hasDialog) return false;
    _stack.removeLast(); // Just remove, don't add to forward stack
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
}
