import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:webview_windows/webview_windows.dart';

class WebViewControllerCache {
  static final WebViewControllerCache _instance = WebViewControllerCache._internal();
  factory WebViewControllerCache() => _instance;
  WebViewControllerCache._internal();

  final Map<String, WebviewController> _controllers = {};
  final Map<String, Completer<void>> _initializations = {};
  final Map<String, bool> _isInitializing = {};

  WebviewController getController(String url) {
    if (!_controllers.containsKey(url)) {
      _controllers[url] = WebviewController();
      _initializations[url] = Completer<void>();
      _isInitializing[url] = false;
      // Initialize controller will be done by the widget
    }
    return _controllers[url]!;
  }

  Future<void> ensureInitialized(String url, WebviewController controller) async {
    // If controller is already initialized
    if (controller.value.isInitialized) return;

    // If already initializing, wait for completion
    if (_isInitializing[url] == true) return _initializations[url]!.future;

    if (_initializations[url]!.isCompleted) _initializations[url] = Completer<void>();

    // Mark as initializing to prevent concurrent initialization
    _isInitializing[url] = true;

    try {
      await controller.initialize();
      await controller.setBackgroundColor(Colors.transparent);

      // Complete the initialization
      if (!_initializations[url]!.isCompleted) _initializations[url]!.complete();
    } catch (e) {
      // If initialization fails, make sure we complete with error
      if (!_initializations[url]!.isCompleted) _initializations[url]!.completeError(e);

      rethrow;
    }
  }

  void dispose() {
    for (final controller in _controllers.values) controller.dispose();

    _controllers.clear();
    _initializations.clear();
    _isInitializing.clear();
  }
}
