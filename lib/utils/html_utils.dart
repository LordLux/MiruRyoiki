import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:async';

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
    // Optional: Implement logic to dispose controllers that haven't been used recently
  }
}

class WindowsIframeHtmlExtension extends HtmlExtension {
  const WindowsIframeHtmlExtension();

  @override
  Set<String> get supportedTags => {"iframe"};

  @override
  InlineSpan build(ExtensionContext context) {
    // Extract src attribute from the iframe
    final src = context.attributes['src'];

    if (src == null) return TextSpan(text: "[iframe missing src]");

    // Get width and height attributes with defaults
    final width = double.tryParse(context.attributes['width'] ?? '') ?? 300.0;
    final height = double.tryParse(context.attributes['height'] ?? '') ?? 150.0;

    // Use a unique key based on the URL to maintain widget identity
    final key = ValueKey(src);
    
    return WidgetSpan(
      child: WindowsIframeWidget(
        key: key,
        src: src,
        width: width,
        height: height,
      ),
    );
  }
}

class WindowsIframeWidget extends StatefulWidget {
  final String src;
  final double width;
  final double height;

  const WindowsIframeWidget({
    super.key,
    required this.src,
    required this.width,
    required this.height,
  });

  @override
  State<WindowsIframeWidget> createState() => _WindowsIframeWidgetState();
}

class _WindowsIframeWidgetState extends State<WindowsIframeWidget> with AutomaticKeepAliveClientMixin {
  late WebviewController _controller;
  bool _isWebViewReady = false;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true; // Keep this widget alive when scrolled off screen

  @override
  void initState() {
    super.initState();
    _controller = WebViewControllerCache().getController(widget.src);
    _initWebView();
  }

  Future<void> _initWebView() async {
    if (_isInitialized) return;
    
    try {
      if (!_controller.value.isInitialized) {
        await _controller.initialize();
        await _controller.setBackgroundColor(Colors.transparent);
        await _controller.loadUrl(widget.src);
      }
      
      _isInitialized = true;
      if (mounted) setState(() => _isWebViewReady = true);
    } catch (e) {
      debugPrint('Error initializing WebView: $e');
    }
  }

  @override
  void didUpdateWidget(WindowsIframeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reload if the source URL changed
    if (oldWidget.src != widget.src) {
      _controller = WebViewControllerCache().getController(widget.src);
      _isInitialized = false;
      _isWebViewReady = false;
      _initWebView();
    }
  }

  // Don't dispose the controller here - it's managed by the cache

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return RepaintBoundary(
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            if (_isWebViewReady)
              Webview(
                _controller,
                width: widget.width,
                height: widget.height,
              )
            else
              Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: ProgressRing(
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}