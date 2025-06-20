import 'package:webview_windows/webview_windows.dart';

class WebViewControllerCache {
  static final WebViewControllerCache _instance = WebViewControllerCache._internal();
  factory WebViewControllerCache() => _instance;
  WebViewControllerCache._internal();
  
  final Map<String, WebviewController> _controllers = {};
  
  WebviewController getController(String url) {
    if (!_controllers.containsKey(url)) {
      _controllers[url] = WebviewController();
      // Initialize controller will be done by the widget
    }
    return _controllers[url]!;
  }
  
  bool hasController(String url) => _controllers.containsKey(url);
  
  void disposeUnused() {
    _controllers.removeWhere((key, controller) => !controller.value.isInitialized);
  }
}