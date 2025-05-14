// ignore_for_file: dead_code

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

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
  final GlobalKey<NavigatorState>? navigatorKey;

  NavigationItem({
    required this.id,
    required this.title,
    required this.level,
    this.data,
    this.navigatorKey,
  });

  @override
  String toString() => 'NavigationItem(id: $id, title: $title, level: $level)';
}

class NavigationManager extends ChangeNotifier {
  final List<NavigationItem> _stack = [];

  // Current state accessors
  List<NavigationItem> get stack => List.unmodifiable(_stack);
  NavigationItem? get currentView => _stack.isNotEmpty ? _stack.last : null;
  bool get hasPane => _stack.isNotEmpty && _stack.last.level == NavigationLevel.pane;
  bool get hasPage => _stack.isNotEmpty && _stack.last.level == NavigationLevel.page;
  bool get hasDialog => _stack.length > 1 && _stack.last.level == NavigationLevel.dialog;
  bool get canGoBack => _stack.length > 1;

  // Navigation methods
  void pushPane(String id, String title, {Object? data, GlobalKey<NavigatorState>? navigatorKey}) {
    // When pushing a pane, remove all other items if coming from another pane
    if (_stack.isNotEmpty && _stack.last.level == NavigationLevel.pane) {
      _stack.clear();
    }

    _push(NavigationItem(
      id: id,
      title: title,
      level: NavigationLevel.pane,
      data: data,
      navigatorKey: navigatorKey,
    ));
  }

  void pushPage(String id, String title, {Object? data, GlobalKey<NavigatorState>? navigatorKey}) {
    _push(NavigationItem(
      id: id,
      title: title,
      level: NavigationLevel.page,
      data: data,
      navigatorKey: navigatorKey,
    ));
  }

  void pushDialog(String id, String title, {Object? data, GlobalKey<NavigatorState>? navigatorKey}) {
    _push(NavigationItem(
      id: id,
      title: title,
      level: NavigationLevel.dialog,
      data: data,
      navigatorKey: navigatorKey,
    ));
  }

  void _push(NavigationItem item) {
    _stack.add(item);
    notifyListeners();
    _logCurrentStack();
  }

  bool goBack() {
    if (!canGoBack) return false;

    _stack.removeLast();
    notifyListeners();
    _logCurrentStack();
    return true;
  }

  void navigateToPane(String id) {
    // Find the pane in the stack
    final paneIndex = _stack.indexWhere((item) => item.level == NavigationLevel.pane && item.id == id);

    if (paneIndex >= 0) {
      // Keep only items up to and including this pane
      _stack.removeRange(paneIndex + 1, _stack.length);
    } else {
      // Push a new pane
      if (_stack.isNotEmpty) _stack.clear();
      _push(NavigationItem(id: id, title: id, level: NavigationLevel.pane));
    }

    notifyListeners();
    _logCurrentStack();
  }

  void clearStack() {
    _stack.clear();
    notifyListeners();
    _logCurrentStack();
  }

  void clearAndPushPane(String id, String title, {Object? data}) {
    _stack.clear();
    pushPane(id, title, data: data);
  }

  void _logCurrentStack() {
    if (false && kDebugMode) {
      logDebug('----------------------------------------------');
      logDebug('Navigation Stack:');
      for (int i = 0; i < _stack.length; i++) {
        final item = _stack.reversed.toList()[i];
        logDebug('  ${i == 0 ? '→' : ' '} ${item.level.name}: ${item.title}');
      }
      logDebug('----------------------------------------------');
    }
  }

  /// Pops the current dialog from the stack and returns true if successful.
  bool popDialog() {
    if (!hasDialog) return false;
    
    return goBack();
  }
}
